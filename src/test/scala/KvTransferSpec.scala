package compaction_unit

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KvTransferSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should load key chunks from all mock buffers" in {
        test(new TopKvTransfer).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default input values
            dut.io.deq.ready.poke(false.B)
            for (i <- 0 until 4) {
                dut.io.enq(i).bits.poke(0.U)
                dut.io.enq(i).valid.poke(false.B)
            }
            dut.clock.step()

            dut.io.command.poke("b01".U)
            dut.clock.step()

            dut.io.command.poke("b00".U)
            dut.io.bufferSelect.expect(0.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.enq(0).ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)

            dut.io.enq(0).valid.poke(true.B)
            dut.io.enq(0).bits.poke(0xA.U)

            dut.clock.step()

            dut.io.enq(0).ready.expect(false.B)
            dut.io.bufferSelect.expect(0.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.io.deq.ready.poke(true.B)

            dut.clock.step()

            dut.io.bufferSelect.expect(1.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.enq(1).ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)

            dut.io.enq(1).valid.poke(true.B)
            dut.io.enq(1).bits.poke(0xB.U)

            dut.clock.step()

            dut.io.enq(1).ready.expect(false.B)
            dut.io.bufferSelect.expect(1.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xB.U)
            dut.io.deq.ready.poke(true.B)

            dut.clock.step()

            dut.io.bufferSelect.expect(2.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.enq(2).ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)

            dut.io.enq(2).valid.poke(true.B)
            dut.io.enq(2).bits.poke(0xC.U)

            dut.clock.step()

            dut.io.enq(2).ready.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xC.U)
            dut.io.bufferSelect.expect(2.U)
            dut.io.outputKeyOnly.expect(true.B)

            dut.clock.step()

            dut.io.bufferSelect.expect(3.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.enq(3).ready.expect(true.B)
            dut.io.enq(3).valid.poke(true.B)
            dut.io.enq(3).bits.poke(0xD.U)
            dut.io.deq.valid.expect(false.B)

            dut.clock.step()

            dut.io.bufferSelect.expect(3.U)
            dut.io.outputKeyOnly.expect(true.B)
            dut.io.enq(3).ready.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xD.U)
            dut.io.bufferSelect.expect(3.U)
            
            dut.clock.step()
            dut.io.bufferSelect.expect(0.U)
            dut.io.outputKeyOnly.expect(false.B)

            // wait for the command to be issed to start transfer
            dut.io.enq(0).ready.expect(false.B)
        }
    }

    "Should load a single key chunk with delayed ready" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.command.poke("b01".U)
            dut.clock.step()

            dut.io.bufferSelect.expect(0.U)

            dut.io.command.poke("b00".U)
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.valid.poke(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.clock.step(2)

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.ready.poke(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.io.bufferSelect.expect(0.U)

            dut.clock.step()
            dut.io.deq.ready.poke(false.B)
            dut.io.bufferSelect.expect(1.U)
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
        }
    }

    "Should load a single key chunk with on-time ready" in {
        test(new KvTransfer(4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.command.poke("b01".U)
            dut.clock.step()

            dut.io.bufferSelect.expect(0.U)

            dut.io.command.poke("b00".U)
            dut.io.enq.valid.poke(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.deq.ready.poke(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.io.bufferSelect.expect(0.U)

            dut.clock.step()

            dut.io.deq.ready.poke(false.B)
            dut.io.bufferSelect.expect(1.U)
            dut.io.enq.ready.expect(true.B)
        }
    }
}
