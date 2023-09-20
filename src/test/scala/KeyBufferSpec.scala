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
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(true.B)

            // Read two rows of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0xA + i).U)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0x3 + i).U)
                dut.io.bufferOutputSelect.expect(i.U)
                dut.clock.step()
            }

            dut.io.deq.valid.expect(false.B)
            dut.io.enq.ready.expect(true.B)
        }
    }

    "Should reset buffer" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.incrWritePtr.poke(false.B)

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

            dut.io.clearBuffer.poke(true.B)
            dut.io.enq.ready.expect(false.B)
            dut.clock.step()

            dut.io.clearBuffer.poke(false.B)
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
        }
    }

    "Should load key chunks rows and read them back with delay" in {
        test(new KeyBuffer(busWidth = 4, numberOfBuffers = 4, maximumKeySize = 12)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default values
            dut.io.deq.ready.poke(false.B)
            dut.io.enq.valid.poke(true.B)

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

            dut.io.enq.valid.poke(false.B)
            
            // wait
            dut.clock.step(3)
            dut.io.deq.ready.poke(true.B)
            dut.io.enq.valid.poke(true.B)

            // Write second row and read first row of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
                dut.io.deq.bits.expect((0xA + i).U)
                dut.io.bufferOutputSelect.expect(i.U)

                dut.io.enq.ready.expect(true.B)
                dut.io.enq.bits.poke((0x3 + i).U) 
                dut.io.bufferInputSelect.poke(i.U)
                if (i == 3) {
                    dut.io.incrWritePtr.poke(true.B)
                }
                dut.clock.step()
                dut.io.incrWritePtr.poke(false.B)
            }

            dut.io.enq.valid.poke(false.B)

            // TODO: one clock delay is needed here
            dut.clock.step()
            
            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.deq.valid.expect(true.B)
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
