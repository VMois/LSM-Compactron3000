package compaction_unit

import chisel3._
import chisel3.util._


class KvTransferIO(busWidth: Int, numberOfBuffers: Int = 4) extends Bundle {
    // inputs and outputs for receving data from buffers
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val lastInput = Input(Bool())
    val isInputKey = Input(Bool())
    val resetBufferRead = Output(Bool())
    val outputKeyOnly = Output(Bool())

    // select one of the buffers to accept data from
    var bufferSelect = Output(UInt(log2Ceil(numberOfBuffers).W))

    // if false, output to key buffer
    // if true, output to KV output buffer
    var outputSelect = Output(Bool())

    // inputs and outputs for control of the module
    val command = Input(UInt(2.W))
    val stop = Input(Bool())
    // TODO: bufferInputSelect can be replaced with mask
    val bufferInputSelect = Input(UInt(log2Ceil(numberOfBuffers).W))
    val mask = Input(UInt(numberOfBuffers.W))
    val busy = Output(Bool())

    // outputs for key buffer and KV output buffer
    val deq = Decoupled(UInt(busWidth.W))
    val incrKeyBufferPtr = Output(Bool())  // only valid if deq.valid is True
    val clearKeyBuffer = Output(Bool())
    val isOutputKey = Output(Bool())
    val lastOutput = Output(Bool()) // outputs whatever current key chunk is the last one, only valid if deq.valid is True
}


/** A class for KV transfer module. 
 *  This module is used to transfer KV pairs to Comparator module when requested.
 *  The module supports following commands:
 *    Command 0 (b00):
 *      Does nothing, waits for the command.
 *    Command 1 (b01): 
 *      Transfers key chunks from all buffers, one-by-one, until all buffers are empty.
 *    Command 2 (b10):
 *      Transfers KV pair from selected KV Ring Buffer to KV Output buffer.
 *
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param numberOfBuffers, the number of buffers that will be connected to the KV transfer module.
 */
class KvTransfer(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Module {
    assert (busWidth > 0, "Bus width must be greater than 0")
    assert (numberOfBuffers > 0 && (numberOfBuffers & (numberOfBuffers - 1)) == 0, s"numberOfBuffers parameter must be a power of two, but it is $numberOfBuffers")

    val io = IO(new KvTransferIO(busWidth, numberOfBuffers))

    val idle :: clearKeyBuffer :: loadChunk :: waitForTransfer :: resetBufferRead :: transferKvPair :: Nil = Enum(6)

    val state = RegInit(idle)
    val data = RegInit(0.U(busWidth.W))
    val lastKeyChunk = RegInit(false.B)
    val mask = RegInit(0.U(numberOfBuffers.W))

    // Used by command 1 and 2
    val bufferIdx = RegInit(0.U(log2Ceil(numberOfBuffers).W))

    // Used by command 1
    val moreChunksToLoad = RegInit(VecInit(Seq.fill(numberOfBuffers)(true.B)))
    val allBuffersEmpty = Cat(moreChunksToLoad) === 0.U

    val nextIndexSelector = Module(new NextIndexSelector(numberOfBuffers))
    nextIndexSelector.io.mask := moreChunksToLoad.asUInt
    nextIndexSelector.io.currentIndex := bufferIdx

    switch (state) {
        is (idle) {
            // Start command to trasnfer keys to Key Buffer
            when (io.command === "b01".U) {
                bufferIdx := PriorityEncoder(io.mask)
                state := clearKeyBuffer
                mask := io.mask

                // Reset moreChunksToLoad
                for (i <- 0 until numberOfBuffers) {
                    when (io.mask(i) === 0.U) {
                        moreChunksToLoad(i) := false.B
                    } .otherwise {
                        moreChunksToLoad(i) := true.B
                    }
                }
            }

            when (io.command === "b10".U) {
                bufferIdx := io.bufferInputSelect
                state := resetBufferRead
            }
        }
        is (clearKeyBuffer) {
            state := loadChunk
        }
        is (loadChunk) { 
            when (io.stop === false.B && moreChunksToLoad(bufferIdx) === true.B) {
                when (io.enq.valid) {
                    when (io.deq.ready) {
                        bufferIdx := nextIndexSelector.io.nextIndex
                    } .otherwise {
                        // Data is not transferred this clock cycle, store and wait until it will be received.
                        data := io.enq.bits
                        lastKeyChunk := io.lastInput
                        state := waitForTransfer
                    }
                }
            } .otherwise {
                // If all buffers are empty, then command is finished.
                when (allBuffersEmpty) {
                    state := idle
                } .otherwise {
                    // Only this buffer is empty, move to the next one.
                    bufferIdx := nextIndexSelector.io.nextIndex
                }
            }

            // If this is the last input, then we need to stop loading chunks from this buffer.
            when (io.enq.valid && io.lastInput) {
                moreChunksToLoad(bufferIdx) := false.B
            }

            when (io.stop) {
                state := idle
            }
        }
        is (waitForTransfer) {
            when (io.deq.ready && !io.stop) {
                bufferIdx := nextIndexSelector.io.nextIndex
                state := loadChunk
            }

            when (io.stop) {
                state := idle
            }
        }

        is (resetBufferRead) {
            state := transferKvPair
        }

        is (transferKvPair) {
            when (io.enq.valid && io.lastInput && io.deq.ready) {
                state := idle
            }
        }
    }
    
    io.outputSelect := state === transferKvPair
    io.bufferSelect := bufferIdx
    io.isOutputKey := io.isInputKey
    io.outputKeyOnly := (state === loadChunk || state === waitForTransfer) && state =/= transferKvPair
    io.busy := state =/= idle

    // TODO: with io.stop, clearKeyBuffers will be signaled twice to KeyBuffer, not efficient
    //       but we also cannot remove "state === clearKeyBuffer" check as there is a chance 
    //       that KvTransfer will transfer all key chunks and go to idle state by itself
    //       and it will require clearKeyBuffer step when command is issued again.
    //       This can be improved, but, for now, it is not a priority.
    io.clearKeyBuffer := state === clearKeyBuffer || io.stop
    io.lastOutput := Mux(state === waitForTransfer, lastKeyChunk, io.lastInput)

    // input buffers need to be reset when we start loading new chunks, or transfer KV pair
    io.resetBufferRead := state === resetBufferRead || state === clearKeyBuffer

    io.incrKeyBufferPtr := nextIndexSelector.io.overflow && (state === loadChunk || state === waitForTransfer)

    io.enq.ready := (state === loadChunk && moreChunksToLoad(bufferIdx) === true.B) || (state === transferKvPair && io.deq.ready)
    io.deq.bits := Mux(state === waitForTransfer, data, io.enq.bits)
    io.deq.valid := ((state =/= idle && state =/= clearKeyBuffer) && (state === waitForTransfer || (state === loadChunk && (io.enq.valid && moreChunksToLoad(bufferIdx) === true.B)))) || (state === transferKvPair && io.enq.valid)
}


class TopKvTransferIO(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Bundle {
    val enq = Vec(numberOfBuffers, Flipped(Decoupled(UInt(busWidth.W))))

    // deq for Key Buffer
    val deq = Decoupled(UInt(busWidth.W))

    // deq for KV output buffer
    val deqKvPair = Decoupled(UInt(busWidth.W))

    val lastInputs = Input(Vec(numberOfBuffers, Bool()))
    val isInputKey = Input(Vec(numberOfBuffers, Bool()))
    
    // control signals for KvTransfer module
    val command = Input(UInt(2.W))
    val stop = Input(Bool())
    val bufferInputSelect = Input(UInt(log2Ceil(numberOfBuffers).W))
    val busy = Output(Bool())
    val mask = Input(UInt(numberOfBuffers.W))

    // TODO: outputs are copied from KvTransfer module, not good to have duplicate code
    val bufferSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val outputKeyOnly = Output(Bool())
    val incrKeyBufferPtr = Output(Bool())
    val clearKeyBuffer = Output(Bool())
    val lastOutput = Output(Bool())
    val resetBufferRead = Output(Bool())
    val isOutputKey = Output(Bool())
}


/** A top module that connects KV transfer module to multiple buffers. 
 *
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param numberOfBuffers, the number of buffers that will be connected to the KV transfer module.
 */
class TopKvTransfer(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Module {
    val io = IO(new TopKvTransferIO(busWidth, numberOfBuffers))

    val kvTransfer = Module(new KvTransfer(busWidth, numberOfBuffers))

    // kvTransfer controls
    kvTransfer.io.bufferInputSelect <> io.bufferInputSelect
    kvTransfer.io.command <> io.command
    kvTransfer.io.stop <> io.stop
    kvTransfer.io.busy <> io.busy
    kvTransfer.io.mask <> io.mask

    // kvTransfer outputs
    kvTransfer.io.deq <> DontCare
    kvTransfer.io.bufferSelect <> io.bufferSelect
    kvTransfer.io.incrKeyBufferPtr <> io.incrKeyBufferPtr
    kvTransfer.io.clearKeyBuffer <> io.clearKeyBuffer

    // kvTransfer outputs to buffers
    kvTransfer.io.outputKeyOnly <> io.outputKeyOnly
    
    kvTransfer.io.isOutputKey <> io.isOutputKey
    kvTransfer.io.lastOutput <> io.lastOutput
    kvTransfer.io.resetBufferRead <> io.resetBufferRead

    // connect KV transfer module to buffers
    kvTransfer.io.enq <> DontCare
    kvTransfer.io.lastInput <> DontCare
    kvTransfer.io.isInputKey <> DontCare

    for (i <- 0 until numberOfBuffers) {
        when(kvTransfer.io.bufferSelect === i.U) {
            kvTransfer.io.enq <> io.enq(i)
            kvTransfer.io.lastInput := io.lastInputs(i)
            kvTransfer.io.isInputKey := io.isInputKey(i)
        }.otherwise {
            io.enq(i).ready := false.B
            io.enq(i).bits <> DontCare
            io.enq(i).valid <> DontCare
        }
    }

    when (kvTransfer.io.outputSelect) {
        io.deqKvPair <> kvTransfer.io.deq
        io.deq.ready := DontCare
        io.deq.valid := false.B
        io.deq.bits := DontCare
    } .otherwise {
        io.deq <> kvTransfer.io.deq
        io.deqKvPair.ready := DontCare
        io.deqKvPair.bits := DontCare
        io.deqKvPair.valid := false.B
    }
}

object KvTransferMain extends App {
  println("Generating the KV Transfer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KvTransfer(4), Array("--target-dir", "generated"))
  (new chisel3.stage.ChiselStage).emitVerilog(new TopKvTransfer(4), Array("--target-dir", "generated"))
}
