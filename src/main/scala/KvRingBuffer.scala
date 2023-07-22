package compaction_unit

import chisel3._
import chisel3.util._


class KVRingBufferIO(busWidth: Int) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val deq = Decoupled(UInt(busWidth.W))

    var moveReadPtr = Input(Bool())

    val outputKeyOnly = Input(Bool()) // indicates that only key should be outputted by the buffer
    val lastInput = Input(Bool()) // indicates the last input is presented to the buffer
    val isInputKey = Input(Bool()) // is input value a key or a value

    val lastOutput = Output(Bool()) // indicates the last output is presented by the buffer
    val isOutputKey = Output(Bool()) // is output value a key or a value

    val empty = Output(Bool())
    val full = Output(Bool())
}


/** A class for KV ring buffer. 
 * The buffer to store key and value pairs. Eack KV pair has two metadata values, key and value sizes.
 * A synchronous on-chip memory delivers the result of a read in the next clock cycle.
 *
 *  @param depth, how many KV pairs the buffer can hold.
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param keySize, the maximum size of the key in bits.
 *  @param valueSize, the maximum size of the value in bits.
 *  @param metadataSize, the maximum size of the metadata in bits.
 */
class KVRingBuffer(depth: Int, busWidth: Int = 4, keySize: Int = 8, valueSize: Int = 16, metadataSize: Int = 8) extends Module {
    assert (depth > 1, "The KV buffer depth must be greater than 1")
    assert (busWidth > 0, "Bus width must be greater than 0")
    assert (keySize > 0, "Key size must be greater than 0")
    assert (valueSize > 0, "Value size must be greater than 0")
    assert (metadataSize > 0, "Metadata size must be greater than 0")

    assert (keySize % busWidth == 0, "Key size must be a multiple of bus width")
    assert (valueSize % busWidth == 0, "Value size must be a multiple of bus width")
    assert (metadataSize % busWidth == 0, "Metadata size must be a multiple of bus width")
    assert (metadataSize / busWidth >= 2, "Metadata size must be at least 2 bus widths to store the key and value sizes")

    val io = IO(new KVRingBufferIO(busWidth))

    def counter(depth: Int, incr: Bool): (UInt, UInt) = {
        val cntReg = RegInit(0.U(log2Ceil(depth).W))
        val nextVal = Mux(cntReg === (depth-1).U, 0.U, cntReg + 1.U)
        when (incr) {
            cntReg := nextVal
        }
        (cntReg, nextVal)
    }

    val memSize = depth * (keySize + valueSize + metadataSize)
    val mem = SyncReadMem(memSize, UInt(busWidth.W))

    val keyAddressOffset = keySize / busWidth
    val metadataAddressOffset = metadataSize / busWidth
    val valueAddressOffset = metadataSize / busWidth

    // pointers for KV pairs
    val incrRead = WireInit(false.B)
    val incrWrite = WireInit(false.B)
    val (readPtr, nextRead) = counter(depth, incrRead)
    val (writePtr, nextWrite) = counter(depth, incrWrite)

    // pointers within a single KV pair when writing
    val incrWriteKeyChunk = WireInit(false.B)
    val incrWriteValueChunk = WireInit(false.B)
    val (writeKeyChunkPtr, nextWriteKeyChunk) = counter(busWidth * busWidth, incrWriteKeyChunk)
    val (writeValueChunkPtr, nextWriteValueChunk) = counter(busWidth * busWidth, incrWriteValueChunk)

    // pointers within a single KV pair when reading
    val incrReadKeyChunk = WireInit(false.B)
    val incrReadValueChunk = WireInit(false.B)
    val (readKeyChunkPtr, nextReadKeyChunk) = counter(busWidth * busWidth, incrReadKeyChunk)
    val (readValueChunkPtr, nextReadValueChunk) = counter(busWidth * busWidth, incrReadValueChunk)

    val keyLen = RegInit(0.U(busWidth.W))
    val valueLen = RegInit(0.U(busWidth.W))

    val emptyReg = RegInit(true.B)
    val fullReg = RegInit(false.B)
    val lastInput = RegInit(false.B)

    val requestKeyLen :: requestValueLen :: outputReadKeyLen :: outputReadValueLen :: outputReadKey :: readLastKeyChunk:: outputReadValue :: readLastValueChunk :: Nil = Enum(8)
    val writeData :: inputSaveKeyLen :: inputSaveValueLen :: Nil = Enum(3)

    val inputStateReg = RegInit(writeData)
    val outputStateReg = RegInit(requestKeyLen)

    switch(inputStateReg) {
        is(writeData) {
            when(io.enq.valid && !fullReg) {
                when (io.isInputKey) {
                    mem.write(writePtr * (metadataAddressOffset + keyAddressOffset + valueAddressOffset).U + metadataAddressOffset.U + writeKeyChunkPtr, io.enq.bits)
                    writeKeyChunkPtr := writeKeyChunkPtr + 1.U
                } otherwise {
                    mem.write(writePtr * (metadataAddressOffset + keyAddressOffset + valueAddressOffset).U + (metadataAddressOffset + keyAddressOffset).U + writeValueChunkPtr, io.enq.bits)
                    writeValueChunkPtr := writeValueChunkPtr + 1.U

                    when(io.lastInput) {
                        inputStateReg := inputSaveKeyLen
                    }
                }
            }
        }

        is(inputSaveKeyLen) {
            mem.write(writePtr * (metadataAddressOffset + keyAddressOffset + valueAddressOffset).U, writeKeyChunkPtr)
            inputStateReg := inputSaveValueLen
        }

        is(inputSaveValueLen) {
            mem.write(writePtr * (metadataAddressOffset + keyAddressOffset + valueAddressOffset).U + 1.U, writeValueChunkPtr)
            emptyReg := false.B
            incrWrite := true.B
            fullReg := nextWrite === readPtr

            // reset state
            inputStateReg := writeData
            writeKeyChunkPtr := 0.U
            writeValueChunkPtr := 0.U
        }
    }

    when (io.moveReadPtr) {
        incrRead := true.B
        outputStateReg := requestKeyLen
    }

    val readFullPtr = readPtr * (metadataAddressOffset + keyAddressOffset + valueAddressOffset).U + readValueChunkPtr + readKeyChunkPtr
    val data = mem.read(readFullPtr)

    switch(outputStateReg) {
        is(requestKeyLen) { 
            when(!emptyReg) {
                readKeyChunkPtr := 0.U
                readValueChunkPtr := 0.U
                outputStateReg := requestValueLen
            }
        }

        is(requestValueLen) {
            outputStateReg := outputReadKeyLen
            readKeyChunkPtr := 1.U
        }

        is(outputReadKeyLen) {
            keyLen := data

            readKeyChunkPtr := 0.U
            readValueChunkPtr := metadataAddressOffset.U
            outputStateReg := outputReadValueLen
        }

        is(outputReadValueLen) {
            valueLen := data

            when(keyLen === 1.U) {
                readValueChunkPtr := 0.U
                readKeyChunkPtr := (metadataAddressOffset + keyAddressOffset).U
                outputStateReg := readLastKeyChunk
            } otherwise {
                // request 2nd chunk of a key
                readKeyChunkPtr := 1.U
                outputStateReg := outputReadKey
            }
        }

        is(outputReadKey) {
            when(io.deq.ready) {
                when (readKeyChunkPtr === keyLen - 1.U) {
                    outputStateReg := readLastKeyChunk
                    emptyReg := nextRead === writePtr
                    readValueChunkPtr := 0.U
                    readKeyChunkPtr := (metadataAddressOffset + keyAddressOffset).U
                } otherwise {
                    readKeyChunkPtr := readKeyChunkPtr + 1.U
                }
            }
        }

        is(readLastKeyChunk) {
            when(io.deq.ready) {
                when(io.outputKeyOnly) {
                     outputStateReg := requestKeyLen
                } otherwise {
                    when(valueLen === 1.U) {
                        outputStateReg := readLastValueChunk
                    } otherwise {
                        outputStateReg := outputReadValue
                        readValueChunkPtr := 1.U
                    }
                }
            }
        }

        is(outputReadValue) {
            when(io.deq.ready) {
                when(readValueChunkPtr === valueLen - 1.U) {
                    outputStateReg := readLastValueChunk
                    emptyReg := nextRead === writePtr
                } otherwise {
                    readValueChunkPtr := readValueChunkPtr + 1.U
                }
            }
        }

        is(readLastValueChunk) {
            when(io.deq.ready) {
                outputStateReg := requestKeyLen
            }
        }
    }

    io.enq.ready := (inputStateReg === writeData) && !fullReg
    io.deq.valid := outputStateReg === outputReadKey || outputStateReg === readLastKeyChunk || outputStateReg === outputReadValue || outputStateReg === readLastValueChunk
    io.deq.bits := data
    io.isOutputKey := outputStateReg === outputReadKey || outputStateReg === readLastKeyChunk
    io.lastOutput := outputStateReg === readLastValueChunk || (outputStateReg === readLastKeyChunk && io.outputKeyOnly)
    io.empty := emptyReg
    io.full := fullReg
}

object KvRingBufferMain extends App {
  println("Generating the KV Ring Buffer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KVRingBuffer(8), Array("--target-dir", "generated"))
}
