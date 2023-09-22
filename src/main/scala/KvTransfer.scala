package compaction_unit

import chisel3._
import chisel3.util._


class KvTransferIO(busWidth: Int, numberOfBuffers: Int = 4) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val deq = Decoupled(UInt(busWidth.W))

    val command = Input(UInt(2.W))
    val lastInput = Input(Bool())
    val stop = Input(Bool())

    var bufferSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val outputKeyOnly = Output(Bool())
    val busy = Output(Bool())
    val incrKeyBufferPtr = Output(Bool())
}


/** A class for KV transfer module. 
 *  This module is used to transfer KV pairs to Comparator module when requested.
 *  The module supports following commands:
 *    01: 
 *      Transfers key chunks from all buffers, one-by-one, until all buffers are empty.
 *
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param numberOfBuffers, the number of buffers that will be connected to the KV transfer module.
 */
class KvTransfer(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Module {
    assert (busWidth > 0, "Bus width must be greater than 0")
    assert (numberOfBuffers > 0 && (numberOfBuffers & (numberOfBuffers - 1)) == 0, s"numberOfBuffers parameter must be a power of two, but it is $numberOfBuffers")

    val io = IO(new KvTransferIO(busWidth, numberOfBuffers))

    val idle :: loadChunk :: waitForTransfer :: Nil = Enum(3)

    val state = RegInit(idle)
    val data = RegInit(0.U(busWidth.W))

    // Command 01: variables, etc.
    val bufferIdx = RegInit(0.U(log2Ceil(numberOfBuffers).W))
    val moreChunksToLoad = RegInit(VecInit(Seq.fill(numberOfBuffers)(true.B)))
    val allBuffersEmpty = Cat(moreChunksToLoad) === 0.U

    switch (state) {
        is (idle) {
            when (io.command === "b01".U) {
                state := loadChunk
            }
        }
        is (loadChunk) { 
            when (io.stop === false.B && moreChunksToLoad(bufferIdx) === true.B) {
                when (io.enq.valid) {
                    when (io.deq.ready) {
                        bufferIdx := bufferIdx + 1.U
                    } .otherwise {
                        // Data is not transferred this clock cycle, store and wait until it will be received.
                        data := io.enq.bits
                        state := waitForTransfer
                    }
                }
            } .otherwise {
                // If all buffers are empty, then command is finished.
                when (allBuffersEmpty) {
                    state := idle
                    bufferIdx := 0.U
                } .otherwise {
                    // Only this buffer is empty, move to the next one.
                    bufferIdx := bufferIdx + 1.U
                }
            }

            // If this is the last input, then we need to stop loading chunks from this buffer.
            when (io.enq.valid && io.lastInput) {
                moreChunksToLoad(bufferIdx) := false.B
            }

            when (io.stop) {
                state := idle
                bufferIdx := 0.U
                moreChunksToLoad.foreach(_ := true.B)
            }
        }
        is (waitForTransfer) {
            when (io.deq.ready) {
                bufferIdx := bufferIdx + 1.U
                state := loadChunk
            }

            when (io.stop) {
                state := idle
                bufferIdx := 0.U
                moreChunksToLoad.foreach(_ := true.B)
            }
        }
    }
    
    io.bufferSelect := bufferIdx
    io.outputKeyOnly := state === loadChunk || state === waitForTransfer
    io.busy := state =/= idle

    // this works when we iterate over all buffers, 
    // but it will not work if we want to load only non-empty buffers
    // because buffer with index 3 might be skipped.
    io.incrKeyBufferPtr := bufferIdx === (numberOfBuffers-1).U && (state === loadChunk || state === waitForTransfer)

    io.enq.ready := state === loadChunk && moreChunksToLoad(bufferIdx) === true.B
    io.deq.bits := Mux(state === waitForTransfer, data, io.enq.bits)
    io.deq.valid := state =/= idle && (state === waitForTransfer || (io.enq.valid && moreChunksToLoad(bufferIdx) === true.B))
}


class TopKvTransferIO(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Bundle {
    val enq = Vec(numberOfBuffers, Flipped(Decoupled(UInt(busWidth.W))))
    val deq = Decoupled(UInt(busWidth.W))

    val lastInputs = Input(Vec(numberOfBuffers, Bool()))
    val command = Input(UInt(2.W))
    val stop = Input(Bool())

    val bufferSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val outputKeyOnly = Output(Bool())
    val busy = Output(Bool())
    val incrKeyBufferPtr = Output(Bool())
}


/** A top module that connects KV transfer module to multiple buffers. 
 *
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param numberOfBuffers, the number of buffers that will be connected to the KV transfer module.
 */
class TopKvTransfer(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Module {
    val io = IO(new TopKvTransferIO(busWidth, numberOfBuffers))

    val kvTransfer = Module(new KvTransfer(busWidth, numberOfBuffers))

    kvTransfer.io.enq <> DontCare
    kvTransfer.io.lastInput <> DontCare
    kvTransfer.io.stop <> io.stop
    kvTransfer.io.deq <> io.deq

    kvTransfer.io.bufferSelect <> io.bufferSelect
    kvTransfer.io.command <> io.command
    kvTransfer.io.outputKeyOnly <> io.outputKeyOnly
    kvTransfer.io.busy <> io.busy
    kvTransfer.io.incrKeyBufferPtr <> io.incrKeyBufferPtr

    for (i <- 0 until numberOfBuffers) {
        when(kvTransfer.io.bufferSelect === i.U) {
            kvTransfer.io.enq <> io.enq(i)
            kvTransfer.io.lastInput := io.lastInputs(i)
        }.otherwise {
            io.enq(i).ready := false.B
            io.enq(i).bits <> DontCare
            io.enq(i).valid <> DontCare
        }
    }
}

object KvTransferMain extends App {
  println("Generating the KV Transfer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KvTransfer(4), Array("--target-dir", "generated"))
  (new chisel3.stage.ChiselStage).emitVerilog(new TopKvTransfer(4), Array("--target-dir", "generated"))
}
