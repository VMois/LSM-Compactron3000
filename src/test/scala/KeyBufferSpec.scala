package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KeyBufferSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should load key chunks rows and read them back" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.incrWritePtr.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.mask.poke("b1111".U)

            // clear key buffer before loading
            dut.io.clearBuffer.poke(true.B)
            dut.clock.step()
            dut.io.clearBuffer.poke(false.B)

            // Write two rows of key chunks
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0xA + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x3 + i).U) 
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.io.lastInput.poke(true.B)
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(true.B)

            // Read two rows of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0xA + i).U)
                dut.io.lastOutput.expect(false.B)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x3 + i).U)
                dut.io.lastOutput.expect(true.B)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.empty.expect(true.B)

            // Clear buffer
            dut.io.clearBuffer.poke(true.B)
            dut.clock.step()

            dut.io.clearBuffer.poke(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)

            // Write one row of key chunks
            dut.io.lastInput.poke(true.B)
            dut.io.enq.valid.poke(true.B)
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x8 + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)

            dut.clock.step()

            dut.io.deq.ready.poke(true.B)

            // Read one row of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x8 + i).U)
                dut.io.lastOutput.expect(true.B)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }
        }
    }

    "Should write key chunks rows with some chunks shorter and read them back" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 12)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.incrWritePtr.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.mask.poke("b1111".U)

            // clear key buffer before loading
            dut.io.clearBuffer.poke(true.B)
            dut.clock.step()
            dut.io.clearBuffer.poke(false.B)

            // Write first row of key chunks
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x3 + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            // Write second row of key chunks
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0xA + i).U) 
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }

                // Set last input to true for some chunks
                if (i == 2 || i == 3) {
                    dut.io.lastInput.poke(true.B)
                } else {
                    dut.io.lastInput.poke(false.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            // Write third row of key chunks
            dut.io.lastInput.poke(true.B)
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x8 + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }

                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)

            // Read first row of key chunks
            dut.io.deq.ready.poke(true.B)
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x3 + i).U)
                dut.io.lastOutput.expect(false.B)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0xA + i).U)
                if (i == 2 || i == 3) {
                    dut.io.lastOutput.expect(true.B)
                } else {
                    dut.io.lastOutput.expect(false.B)
                }
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            // Read third row of key chunks
            for (i <- 0 until 2) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x8 + i).U)
                dut.io.lastOutput.expect(true.B)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            for (i <- 2 until 4) {
                dut.io.deq.valid.expect(false.B)
                dut.io.deq.bits.expect((0x8 + i).U)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }
            dut.io.deq.ready.poke(false.B)

            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.empty.expect(true.B)
        }
    }

    "Should write key chunks rows and read them back with no delay" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.incrWritePtr.poke(false.B)
            dut.io.empty.expect(true.B)
            dut.io.lastInput.poke(false.B)
            dut.io.mask.poke("b1111".U)

            // clear key buffer before loading
            dut.io.clearBuffer.poke(true.B)
            dut.clock.step()
            dut.io.clearBuffer.poke(false.B)

            // Write one row of key chunks
            for (i <- 0 until 4) {
                dut.io.empty.expect(true.B)
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0xA + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            dut.io.deq.ready.poke(true.B)
            dut.io.empty.expect(false.B)

            for (i <- 0 until 4) {
                // Write second row of key chunks
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x3 + i).U) 
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(true.B)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
                dut.io.lastInput.poke(false.B)

                // Read first row of key chunks
                dut.io.empty.expect(false.B)
                dut.io.deq.valid.expect(true.B)
                dut.io.lastOutput.expect(false.B)
                dut.io.deq.bits.expect((0xA + i).U)
                dut.io.bufferOutputSelect.expect(i.U)
            }

            dut.io.enq.valid.poke(false.B)
            dut.io.empty.expect(false.B)
            dut.clock.step()

            // Read second row of key chunks
            for (i <- 0 until 4) {
                if (i == 3) {
                    // No key chunk rows left after this row
                    dut.io.empty.expect(true.B)
                } else {
                    dut.io.empty.expect(false.B)
                }
                dut.io.deq.valid.expect(true.B)
                dut.io.lastOutput.expect(true.B)
                dut.io.deq.bits.expect((0x3 + i).U)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            dut.io.deq.ready.poke(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.empty.expect(true.B)
        }
    }

    "Should reset buffer" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.empty.expect(true.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.incrWritePtr.poke(false.B)
            dut.io.mask.poke("b1111".U)

            // clear key buffer before loading
            dut.io.clearBuffer.poke(true.B)
            dut.clock.step()
            dut.io.clearBuffer.poke(false.B)

            // Write one row of key chunks
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.empty.expect(true.B)
                dut.io.enq.bits.poke((0xA + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            dut.io.clearBuffer.poke(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.empty.expect(false.B)
            dut.clock.step()

            dut.io.clearBuffer.poke(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
        }
    }

    "Should load key chunks rows and read them back with delay" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 12)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.lastInput.poke(false.B)
            dut.io.mask.poke("b1111".U)

            // clear key buffer before loading
            dut.io.clearBuffer.poke(true.B)
            dut.clock.step()
            dut.io.clearBuffer.poke(false.B)

            // Write first row of key chunks
            for (i <- 0 until 4) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0xA + i).U)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            dut.io.empty.expect(false.B)
            dut.io.enq.valid.poke(false.B)
            
            // wait
            dut.clock.step(3)
            dut.io.deq.ready.poke(true.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.empty.expect(false.B)

            for (i <- 0 until 4) {
                // Read first row
                dut.io.deq.valid.expect(true.B)
                dut.io.lastOutput.expect(false.B)
                dut.io.deq.bits.expect((0xA + i).U)
                dut.io.bufferOutputSelect.expect(i.U)

                // Write second row
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x3 + i).U) 
                dut.io.lastInput.poke(true.B)
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.lastInput.poke(false.B)
                dut.io.incrWritePtr.poke(false.B)
            }

            dut.io.enq.valid.poke(false.B)
            dut.io.empty.expect(false.B)

            // TODO: one clock delay is needed here
            dut.clock.step()
            
            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.lastOutput.expect(true.B)
                dut.io.deq.bits.expect((0x3 + i).U)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            dut.io.deq.ready.poke(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(true.B)
        }
    }
}
