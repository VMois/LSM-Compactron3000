package compaction_unit

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KvTransferSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should stop loading key chunks when requested" in {
        test(new KvTransfer(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // set inputs to default
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.control.stop.poke(false.B)
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.control.command.poke("b01".U)
            dut.clock.step()

            // wait for Key Buffer to clear
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.control.command.poke("b00".U)

            dut.clock.step()

            // load two chunks with delay
            for (i <- 0 until 2) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(false.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)
                dut.io.lastOutput.expect(false.B)

                dut.clock.step()

                // delayed read by one clock
                dut.io.bufferSelect.expect(i.U)
                dut.io.control.busy.expect(true.B)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)
                dut.io.lastOutput.expect(false.B)

                dut.clock.step()

                // delayed read by two clocks
                dut.io.deq.ready.poke(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.control.busy.expect(true.B)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.lastOutput.expect(false.B)

                dut.clock.step()
            }

            dut.io.control.stop.poke(true.B)
            dut.io.lastOutput.expect(false.B)

            dut.clock.step()
            
            dut.io.control.stop.poke(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.lastOutput.expect(false.B)

            dut.io.control.command.poke("b01".U)
            dut.clock.step()

            // wait to clear the key buffer
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
            dut.io.enq.ready.expect(false.B)
            dut.clock.step()

            // reset command to "neutral"
            dut.io.control.command.poke("b00".U)

            for (i <- 0 until 2) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)
                dut.io.lastOutput.expect(false.B)

                dut.clock.step()
            }

            dut.io.control.stop.poke(true.B)
            dut.io.clearKeyBuffer.expect(true.B)

            dut.clock.step()
            
            dut.io.control.stop.poke(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
        }
    }

    "Should load a single key chunk with delayed ready" in {
        test(new KvTransfer(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // set inputs to default
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.control.stop.poke(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.control.command.poke("b01".U)
            dut.clock.step()

            dut.io.control.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            for (i <- 0 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(false.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.lastOutput.expect(false.B)
                
                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()

                // delayed read by one clock
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.lastOutput.expect(false.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()

                // delayed read by two clocks
                dut.io.deq.ready.poke(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.lastOutput.expect(false.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
                dut.io.enq.valid.poke(false.B)
            }

            dut.io.lastInput.poke(true.B)

            for (i <- 0 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(false.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.lastOutput.expect(true.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()

                // one clock delay
                dut.io.enq.ready.expect(false.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.lastOutput.expect(true.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()

                // delayed read by two clocks
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(false.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.lastOutput.expect(true.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
                dut.io.enq.valid.poke(false.B)
            }

            // all buffers are empty, command is finished
            dut.io.control.busy.expect(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()

            dut.io.control.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
        }
    }

    "Should load a single key chunk with on-time ready" in {
        test(new KvTransfer(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.control.stop.poke(false.B)
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.control.command.poke("b01".U)
            dut.clock.step()

            // reset command to "neutral"
            dut.io.control.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            for (i <- 0 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.lastOutput.expect(false.B)
                dut.io.deq.bits.expect((0x1 + i).U)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            // half buffers have last input set to true
            dut.io.lastInput.poke(true.B)

            for (i <- 0 until 2) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x6 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x6 + i).U)
                dut.io.lastOutput.expect(true.B)
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            // last two buffers still have some chunks left
            dut.io.lastInput.poke(false.B)

            for (i <- 2 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x6 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x6 + i).U)
                dut.io.lastOutput.expect(false.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            // remaining buffers have last input set to true
            dut.io.lastInput.poke(true.B)

            for (i <- 2 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0xA + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0xA + i).U)
                dut.io.lastOutput.expect(true.B)

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            // all buffers are empty, command is finished
            dut.io.control.busy.expect(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()

            dut.io.control.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
        }
    }

    "Should transfer key chunks from selected buffers to deq" in {
        test(new KvTransfer(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.control.stop.poke(false.B)

            // Select only buffers 1 and 2
            dut.io.control.mask.poke("b0110".U)
            dut.clock.step()
            
            // send transfer command
            dut.io.control.command.poke("b01".U)
            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.clock.step()

            // reset command to "neutral"
            dut.io.control.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            // Load first chunks from selected buffers
            for (i <- List(1, 2)) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.lastOutput.expect(false.B)
                dut.io.deq.bits.expect((0x1 + i).U)

                // on last buffer, we should increment key buffer pointer
                if (i == 2) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }
            
            // Buffer 1 will have last key chunk
            // Buffer 2 still has some chunks left
            for (i <- List(1, 2)) {
                if (i == 1) {
                    dut.io.lastInput.poke(true.B)
                } else {
                    dut.io.lastInput.poke(false.B)
                }
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x6 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x6 + i).U)

                if (i == 1) {
                    dut.io.lastOutput.expect(true.B)
                } else {
                    dut.io.lastOutput.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }
            
            // Last key chunk for buffer 2
            dut.io.lastInput.poke(true.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.enq.bits.poke(0xE.U)
            dut.io.deq.ready.poke(true.B)

            dut.io.enq.ready.expect(true.B)
            dut.io.control.busy.expect(true.B)
            dut.io.bufferSelect.expect(2.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xE.U)
            dut.io.lastOutput.expect(true.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)

            // All buffers are empty, need one cycle to check and finish command
            dut.io.control.busy.expect(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()
            
            // Ready to accept new commands
            dut.io.control.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
        }
    }

    "Should output deq.valid == false when clearing Key Buffer" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // set inputs to default
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.control.stop.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.io.control.command.poke("b01".U)
            dut.clock.step()

            // enq outputs valid results but KvTransfer is not ready yet
            dut.io.enq.valid.poke(true.B)
            dut.io.enq.ready.expect(false.B)

            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.control.command.poke("b00".U)

            dut.clock.step()

            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.control.stop.poke(true.B)

            dut.clock.step()
            
            dut.io.control.stop.poke(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
        }
    }

    "Should transfer KV pair from selected buffer to deq output" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.enq.bits.poke(0.U)
            dut.io.control.bufferInputSelect.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.control.stop.poke(false.B)
            dut.io.isInputKey.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.resetBufferRead.expect(false.B)
            dut.io.control.command.poke("b10".U)
            dut.io.control.bufferInputSelect.poke(1.U)
            dut.clock.step()

            // reset command to "neutral"
            dut.io.control.command.poke("b00".U)
            dut.io.control.bufferInputSelect.poke(0.U)
            dut.io.resetBufferRead.expect(true.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.bufferSelect.expect(1.U)
            dut.io.control.busy.expect(true.B)
            dut.clock.step()

            // wait for one cycle to make sure the module can handle it
            dut.io.resetBufferRead.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.bufferSelect.expect(1.U)
            dut.io.deq.valid.expect(false.B)
            dut.io.deq.ready.poke(true.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.control.busy.expect(true.B)
            dut.io.outputSelect.expect(true.B)

            dut.clock.step()

            // Start data transfer
            for (i <- 0 until 5) {
                // first two chunks are keys, last three are values
                if (i >= 2) {
                    dut.io.isInputKey.poke(false.B)
                } else {
                    dut.io.isInputKey.poke(true.B)
                }
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x5 + i).U)

                if (i == 4) {
                    dut.io.lastInput.poke(true.B)
                } else {
                    dut.io.lastInput.poke(false.B)
                }

                dut.io.enq.ready.expect(true.B)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.control.busy.expect(true.B)
                dut.io.bufferSelect.expect(1.U)

                // read output
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x5 + i).U)
                if (i == 4) {
                    dut.io.lastOutput.expect(true.B)
                } else {
                    dut.io.lastOutput.expect(false.B)
                }
                if (i >= 2) {
                    dut.io.isOutputKey.expect(false.B)
                } else {
                    dut.io.isOutputKey.expect(true.B)
                }
                dut.io.outputSelect.expect(true.B)
                dut.clock.step()
            }

            // KvTransfer ready for next command
            dut.io.control.busy.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
        }
    }
}

class TopKvTransferSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should load key chunks from all mock buffers" in {
        test(new TopKvTransfer).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default input values
            dut.io.deq.ready.poke(false.B)
            for (i <- 0 until 4) {
                dut.io.enq(i).bits.poke(0.U)
                dut.io.enq(i).valid.poke(false.B)
            }
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()

            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            // send command to start transfer of key chunks
            dut.io.control.command.poke("b01".U)
            dut.clock.step()

            dut.io.control.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            dut.io.control.busy.expect(true.B)
            dut.io.bufferSelect.expect(0.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)

            // deq is not ready, so data is not transferred this clock
            dut.io.enq(0).ready.expect(true.B)
            dut.io.enq(0).valid.poke(true.B)
            dut.io.lastInputs(0).poke(true.B)
            dut.io.enq(0).bits.poke(0xA.U)
            dut.clock.step()

            // Transfer a key chunk from 1st buffer
            dut.io.deq.ready.poke(true.B)

            dut.io.control.busy.expect(true.B)
            dut.io.enq(0).ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)

            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            // Transfer a key chunk from 2nd buffer
            dut.io.control.busy.expect(true.B)
            dut.io.bufferSelect.expect(1.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.io.enq(1).ready.expect(true.B)
            dut.io.lastInputs(1).poke(true.B)
            dut.io.enq(1).valid.poke(true.B)
            dut.io.enq(1).bits.poke(0xB.U)

            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xB.U)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            // Transfer a key chunk from 3rd buffer
            dut.io.control.busy.expect(true.B)
            dut.io.bufferSelect.expect(2.U)
            dut.io.enq(2).ready.expect(true.B)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.io.lastInputs(2).poke(true.B)
            dut.io.enq(2).valid.poke(true.B)
            dut.io.enq(2).bits.poke(0xC.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xC.U)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            // Transfer a key chunk from 4th buffer
            dut.io.bufferSelect.expect(3.U)
            dut.io.enq(3).ready.expect(true.B)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(true.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.control.busy.expect(true.B)

            dut.io.lastInputs(3).poke(true.B)
            dut.io.enq(3).valid.poke(true.B)
            dut.io.enq(3).bits.poke(0xD.U)

            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xD.U)
            dut.io.lastOutput.expect(true.B)

            dut.clock.step()

            // check if all buffers are empty, need one cycle
            dut.io.control.busy.expect(true.B)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)

            dut.clock.step()

            dut.io.outputKeyOnly.expect(false.B)
            dut.io.control.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)

            // wait for the command to be issed to start transfer
            dut.io.enq(0).ready.expect(false.B)
        }
    }
}
