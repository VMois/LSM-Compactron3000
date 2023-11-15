package compaction_unit

import chisel3._
import chisel3.util._

// TODO: use this bundle in KvRingBuffer class
class KvRingBufferInputIO(busWidth: Int) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val lastInput = Input(Bool())
    val isInputKey = Input(Bool())
}

// TODO: use this bundle in KvRingBuffer class
class KvRingBufferOutputIO(busWidth: Int) extends Bundle {
    val deq = Decoupled(UInt(busWidth.W))
    val outputKeyOnly = Input(Bool()) 
    val lastOutput = Output(Bool())
    val isOutputKey = Output(Bool())

    // hack to output key and value len
    val metadataValid = Output(Bool())
}

class KvRingBufferStatusIO extends Bundle {
    val empty = Output(Bool())
    val full = Output(Bool())
    val halfFull = Output(Bool())
}

// Control inputs for Controller module
class KvRingBufferControlIO extends Bundle {
    val moveReadPtr = Input(Bool()) // request buffer to stop reading and move read pointer to the next KV pair
    val resetRead = Input(Bool()) // request buffer to start reading current KV pair from the beginning
}

class KVRingBufferIO(busWidth: Int) extends Bundle {
    // Input for KV pairs
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val lastInput = Input(Bool()) // indicates the last input is presented to the buffer
    val isInputKey = Input(Bool()) // is input value a key or a value

    val control = new KvRingBufferControlIO

    // Outputs
    val deq = Decoupled(UInt(busWidth.W))
    val outputKeyOnly = Input(Bool()) // indicates that only key should be outputted by the buffer
    val lastOutput = Output(Bool()) // indicates the last output is presented by the buffer
    val isOutputKey = Output(Bool()) // is output value a key or a value

    // Outputs, hack to output key and value len
    val metadataValid = Output(Bool())

    val status = new KvRingBufferStatusIO
}


/** A class for KV Ring Buffer. 
 * It is a circular buffer that temporary stores key and value (KV) pairs from the Decoder. 
 * The buffer uses a synchronous on-chip memory that expects result of a read in the next clock cycle.
 * Each KV pair has metadata values. Current implementation stores only key and value sizes.
 *
 * The buffer implements a modified ready/valid handshake protocol, with `lastInput` and `lastOuput` signals. 
 * The `lastInput` signal is asserted by the sender to indicate to the ring buffer that the current valid value is the last chunk.
 * The similar approach is taken by the ring buffer to output a KV pair.
 * 
 * The write pointer is moved forward when a new KV pair is written to the buffer unless buffer is full.
 * The read pointer is moved forward by asserting `moveReadPtr` input signal.
 *
 * The buffer outputs key value only if `outputKeyOnly` input signal is asserted. 
 * If not, it will transfer both key and value on a bus.
 *
 *  @param depth, how many KV pairs the buffer can hold.
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param keySize, the maximum size of the key in bits.
 *  @param valueSize, the maximum size of the value in bits.
 *  @param metadataSize, the maximum size of the metadata in bits.
 *  @param autoReadNextPair, if set to true, the read pointer is moved forward automatically when the last chunk of a KV pair is read.
 */
class KVRingBuffer(depth: Int, busWidth: Int = 4, keySize: Int = 8, valueSize: Int = 16, metadataSize: Int = 8, autoReadNextPair: Boolean = false) extends Module {
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
    val valueAddressOffset = valueSize / busWidth

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

    val distanceBetweenPtrs = Mux(writePtr >= readPtr, writePtr - readPtr, depth.U - readPtr + writePtr)

    // Output states
    val requestKeyLen :: requestValueLen :: outputReadKeyLen :: outputReadValueLen :: outputReadKey :: waitForReadKey :: readLastKeyChunk :: waitForReadLastKeyChunk :: outputReadValue :: waitForReadValue :: readLastValueChunk :: waitForReadLastValueChunk :: Nil = Enum(12)

    // Input states
    val writeData :: inputSaveKeyLen :: inputSaveValueLen :: Nil = Enum(3)

    val inputStateReg = RegInit(writeData)
    val outputStateReg = RegInit(requestKeyLen)

    val writeReg = RegInit(0.U(busWidth.W))

    val offset = (metadataAddressOffset + keyAddressOffset + valueAddressOffset).U
    val writeDataPtr = Mux(inputStateReg === writeData, Mux(io.isInputKey, metadataAddressOffset.U, (metadataAddressOffset + keyAddressOffset).U) + Mux(io.isInputKey, writeKeyChunkPtr, writeValueChunkPtr), 0.U)
    val metadataOffsetPtr = Mux(inputStateReg === inputSaveValueLen, 1.U, 0.U)
    val writeFullPtr = writePtr * offset + writeDataPtr + metadataOffsetPtr

    when (io.enq.valid || inputStateReg === inputSaveKeyLen || inputStateReg === inputSaveValueLen) {
        mem.write(writeFullPtr, Mux(inputStateReg === writeData, io.enq.bits, writeReg))
    }

    switch(inputStateReg) {
        is(writeData) {
            when(io.enq.valid && !fullReg) {
                when (io.isInputKey) {
                    writeKeyChunkPtr := writeKeyChunkPtr + 1.U
                } otherwise {
                    writeValueChunkPtr := writeValueChunkPtr + 1.U
                    when(io.lastInput) {
                        inputStateReg := inputSaveKeyLen
                        writeReg := writeKeyChunkPtr
                        emptyReg := false.B
                    }
                }
            }
        }

        is(inputSaveKeyLen) {
            inputStateReg := inputSaveValueLen
            writeReg := writeValueChunkPtr
        }

        is(inputSaveValueLen) {
            incrWrite := true.B
            fullReg := nextWrite === readPtr

            // reset state
            inputStateReg := writeData
            writeKeyChunkPtr := 0.U
            writeValueChunkPtr := 0.U
        }
    }

    val writeIsIncoming = (inputStateReg === inputSaveKeyLen || inputStateReg === inputSaveValueLen)

    def moveReadPtr() = {
        incrRead := true.B
        emptyReg := nextRead === writePtr && ~writeIsIncoming
    }

    val moveOrResetRequested = io.control.moveReadPtr || io.control.resetRead
    when (moveOrResetRequested) {
        outputStateReg := requestKeyLen
        when (io.control.moveReadPtr) {
            moveReadPtr()
        }
    }

    val readFullPtr = readPtr * offset + readValueChunkPtr + readKeyChunkPtr
    val data = mem.read(readFullPtr)
    val shadowReg = RegInit(0.U(busWidth.W))

    switch(outputStateReg) {
        is(requestKeyLen) {
            // If write is incoming and buffer is empty it is still fine to request a key len
            // This is fine because by the time we read the key len in the next cycle, thr write will be done 
            when(!emptyReg && !moveOrResetRequested) {
                readKeyChunkPtr := 0.U
                readValueChunkPtr := 0.U
                outputStateReg := requestValueLen
            }
        }

        is(requestValueLen) {
            when (!moveOrResetRequested) {
                outputStateReg := outputReadKeyLen
                // request value length, just reusing a register
                readKeyChunkPtr := 1.U
            }
        }

        is(outputReadKeyLen) {
            when (!moveOrResetRequested) {
                keyLen := data

                // request first chunk of a Key
                readKeyChunkPtr := 0.U
                readValueChunkPtr := metadataAddressOffset.U
                outputStateReg := outputReadValueLen
            }
        }

        is(outputReadValueLen) {
            valueLen := data
            when (!moveOrResetRequested) {
                when(keyLen === 1.U) {
                    // request first chunk of a Value
                    readValueChunkPtr := 0.U
                    readKeyChunkPtr := (metadataAddressOffset + keyAddressOffset).U

                    outputStateReg := readLastKeyChunk
                } otherwise {
                    // request 2nd chunk of a Key
                    readKeyChunkPtr := 1.U
                    outputStateReg := outputReadKey
                }
            }
        }

        is(outputReadKey) {
            when (!moveOrResetRequested) {
                when(io.deq.ready) {
                    when (readKeyChunkPtr === keyLen - 1.U) {
                        outputStateReg := readLastKeyChunk
                        readValueChunkPtr := 0.U
                        readKeyChunkPtr := (metadataAddressOffset + keyAddressOffset).U
                    } otherwise {
                        readKeyChunkPtr := readKeyChunkPtr + 1.U
                    }
                }
                .otherwise {
                    shadowReg := data
                    outputStateReg := waitForReadKey
                }
            }
        }

        is(waitForReadKey) {
            when(io.deq.ready && !moveOrResetRequested) {
                when (readKeyChunkPtr === keyLen - 1.U) {
                    outputStateReg := readLastKeyChunk
                    readValueChunkPtr := 0.U
                    readKeyChunkPtr := (metadataAddressOffset + keyAddressOffset).U
                } otherwise {
                    outputStateReg := outputReadKey
                    readKeyChunkPtr := readKeyChunkPtr + 1.U
                } 
            }
        }

        is(readLastKeyChunk) {
            when (!moveOrResetRequested) {
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
                }.otherwise {
                    shadowReg := data
                    outputStateReg := waitForReadLastKeyChunk
                }
            }
        }

        is(waitForReadLastKeyChunk) {
            when(io.deq.ready && !moveOrResetRequested) {
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
            when (!moveOrResetRequested) {
                when(io.deq.ready) {
                    when(readValueChunkPtr === valueLen - 1.U) {
                        outputStateReg := readLastValueChunk
                    } otherwise {
                        readValueChunkPtr := readValueChunkPtr + 1.U
                    }
                }
                .otherwise {
                    shadowReg := data
                    outputStateReg := waitForReadValue
                }
            }
        }

        is(waitForReadValue) {
            when(io.deq.ready && !moveOrResetRequested) {
                when(readValueChunkPtr === valueLen - 1.U) {
                    outputStateReg := readLastValueChunk
                } otherwise {
                    outputStateReg := outputReadValue
                    readValueChunkPtr := readValueChunkPtr + 1.U
                }
            }
        }

        is(readLastValueChunk) {
            when (!moveOrResetRequested) {
                when(io.deq.ready) {
                    outputStateReg := requestKeyLen
                    if (autoReadNextPair) {
                        moveReadPtr()
                    }
                }
                .otherwise {
                    shadowReg := data
                    outputStateReg := waitForReadLastValueChunk
                }
            }
        }

        is(waitForReadLastValueChunk) {
            when(io.deq.ready && !moveOrResetRequested) {
                outputStateReg := requestKeyLen
                if (autoReadNextPair) {
                    moveReadPtr()
                }
            }
        }
    }

    io.enq.ready := (inputStateReg === writeData) && !fullReg
    io.deq.valid := outputStateReg === outputReadKey || outputStateReg === readLastKeyChunk || outputStateReg === waitForReadKey || outputStateReg === waitForReadLastKeyChunk || outputStateReg === outputReadValue || outputStateReg === readLastValueChunk || outputStateReg === waitForReadValue || outputStateReg === waitForReadLastValueChunk
    io.deq.bits := Mux(outputStateReg === waitForReadKey || outputStateReg === waitForReadLastKeyChunk || outputStateReg === waitForReadValue || outputStateReg === waitForReadLastValueChunk, shadowReg, data)
    io.isOutputKey := outputStateReg === outputReadKey || outputStateReg === readLastKeyChunk || outputStateReg === waitForReadKey || outputStateReg === waitForReadLastKeyChunk
    io.lastOutput := (outputStateReg === readLastValueChunk || outputStateReg === waitForReadLastValueChunk) || ((outputStateReg === readLastKeyChunk || outputStateReg === waitForReadLastKeyChunk) && io.outputKeyOnly)
    io.status.empty := emptyReg
    io.status.full := fullReg
    io.status.halfFull := distanceBetweenPtrs >= (depth / 2).U || io.status.full

    io.metadataValid := outputStateReg === outputReadKeyLen || outputStateReg === outputReadValueLen
}

object KvRingBufferMain extends App {
  println("Generating the KV Ring Buffer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KVRingBuffer(8), Array("--target-dir", "generated"))
}
