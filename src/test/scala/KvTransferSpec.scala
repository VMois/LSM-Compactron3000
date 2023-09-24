package compaction_unit

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KvTransferSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should stop loading key chunks when requested" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // set inputs to default
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.stop.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.command.poke("b01".U)
            dut.clock.step()

            // wait for Key Buffer to clear
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.command.poke("b00".U)

            dut.clock.step()

            // load two chunks with delay
            for (i <- 0 until 2) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(false.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()

                // delayed read by one clock
                dut.io.bufferSelect.expect(i.U)
                dut.io.busy.expect(true.B)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()

                // delayed read by two clocks
                dut.io.deq.ready.poke(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.busy.expect(true.B)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)

                dut.clock.step()
            }

            dut.io.stop.poke(true.B)

            dut.clock.step()
            
            dut.io.stop.poke(false.B)
            dut.io.busy.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.io.command.poke("b01".U)
            dut.clock.step()

            // wait to clear the key buffer
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
            dut.io.enq.ready.expect(false.B)
            dut.clock.step()

            // reset command to "neutral"
            dut.io.command.poke("b00".U)

            for (i <- 0 until 2) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            dut.io.stop.poke(true.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()
            
            dut.io.stop.poke(false.B)
            dut.io.busy.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
        }
    }

    "Should load a single key chunk with delayed ready" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // set inputs to default
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.stop.poke(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.busy.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.command.poke("b01".U)
            dut.clock.step()

            dut.io.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            for (i <- 0 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(false.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)
                
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

                // on last buffer, we should increment key buffer pointer
                if (i == 3) {
                    dut.io.incrKeyBufferPtr.expect(true.B)
                } else {
                    dut.io.incrKeyBufferPtr.expect(false.B)
                }
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            dut.io.lastInput.poke(true.B)

            for (i <- 0 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(false.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x1 + i).U)

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
            dut.io.busy.expect(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
            dut.io.deq.valid.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()

            dut.io.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
        }
    }

    "Should load a single key chunk with on-time ready" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.stop.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.busy.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.command.poke("b01".U)
            dut.clock.step()

            // reset command to "neutral"
            dut.io.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            for (i <- 0 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0x1 + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
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
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x6 + i).U)
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
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x6 + i).U)

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

            // buffers that are already empty should be skipped
            for (i <- 0 until 2) {
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(false.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(false.B)
                dut.io.incrKeyBufferPtr.expect(false.B)
                dut.io.clearKeyBuffer.expect(false.B)

                dut.clock.step()
            }

            for (i <- 2 until 4) {
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke((0xA + i).U)
                dut.io.deq.ready.poke(true.B)

                dut.io.enq.ready.expect(true.B)
                dut.io.busy.expect(true.B)
                dut.io.bufferSelect.expect(i.U)
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0xA + i).U)

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
            dut.io.busy.expect(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
            dut.io.deq.valid.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()

            dut.io.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
        }
    }

    "Should not output deq.valid == true when clearing Key Buffer" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // set inputs to default
            dut.io.enq.bits.poke(0.U)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.stop.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.io.command.poke("b01".U)
            dut.clock.step()

            // enq outputs valid results but KvTransfer is not ready yet
            dut.io.enq.valid.poke(true.B)
            dut.io.enq.ready.expect(false.B)

            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.command.poke("b00".U)

            dut.clock.step()

            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.stop.poke(true.B)

            dut.clock.step()
            
            dut.io.stop.poke(false.B)
            dut.io.busy.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
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
            dut.clock.step()

            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            // send command to start transfer of key chunks
            dut.io.command.poke("b01".U)
            dut.clock.step()

            dut.io.command.poke("b00".U)
            dut.io.clearKeyBuffer.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            dut.io.busy.expect(true.B)
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

            // Start transfer of data
            dut.io.deq.ready.poke(true.B)

            dut.io.busy.expect(true.B)
            dut.io.enq(0).ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)

            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.clock.step()

            // Transfer a key chunk from 2nd buffer
            dut.io.busy.expect(true.B)
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
            dut.clock.step()

            // Transfer a key chunk from 3rd buffer
            dut.io.busy.expect(true.B)
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
            dut.clock.step()

            // Transfer a key chunk from 4th buffer
            dut.io.bufferSelect.expect(3.U)
            dut.io.enq(3).ready.expect(true.B)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(true.B)
            dut.io.clearKeyBuffer.expect(false.B)
            dut.io.busy.expect(true.B)

            dut.io.lastInputs(3).poke(true.B)
            dut.io.enq(3).valid.poke(true.B)
            dut.io.enq(3).bits.poke(0xD.U)

            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xD.U)

            dut.clock.step()

            // check if all buffers are empty, need one cycle
            dut.io.bufferSelect.expect(0.U)
            dut.io.busy.expect(true.B)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.incrKeyBufferPtr.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            dut.clock.step()

            dut.io.outputKeyOnly.expect(false.B)
            dut.io.busy.expect(false.B)
            dut.io.clearKeyBuffer.expect(false.B)

            // wait for the command to be issed to start transfer
            dut.io.enq(0).ready.expect(false.B)
        }
    }
}
