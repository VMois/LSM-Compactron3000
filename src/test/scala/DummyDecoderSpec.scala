package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class DummyDecoderSpec extends AnyFreeSpec with ChiselScalatestTester {
    val statusIsLast2Keys4Values = 0x00040201
    val statusNotLast2Keys4Values = 0x00040200

    "Transfer last KV Pair from AXI to buffer" in {
        test(new DummyDecoder).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.control.readyToAccept.poke(true.B)
            dut.io.input.axi_s.tvalid.poke(true.B)

            dut.io.output.enq.ready.poke(true.B)
            dut.io.input.axi_s.tready.expect(true.B)
            
            // Send status data
            dut.io.input.axi_s.tdata.poke(statusIsLast2Keys4Values.U)
            dut.io.control.lastKvPairSeen.expect(false.B)
            dut.io.output.enq.valid.expect(false.B)
            dut.clock.step()
            
            // Send key
            for (i <- 0 until 2) {
                dut.io.input.axi_s.tready.expect(true.B)
                dut.io.input.axi_s.tdata.poke((i + 1000).U)
                dut.io.output.enq.valid.expect(true.B)
                dut.io.output.enq.bits.expect((i + 1000).U)
                dut.io.output.isInputKey.expect(true.B)
                dut.io.output.lastInput.expect(false.B)
                dut.clock.step()
            }

            // Send value
            for (i <- 0 until 4) {
                dut.io.input.axi_s.tready.expect(true.B)
                dut.io.input.axi_s.tdata.poke((i + 2000).U)
                dut.io.output.enq.valid.expect(true.B)
                dut.io.output.enq.bits.expect((i + 2000).U)
                dut.io.output.isInputKey.expect(false.B)
                if (i == 3) {
                    dut.io.output.lastInput.expect(true.B)
                } else {
                    dut.io.output.lastInput.expect(false.B)
                }
                dut.clock.step()
            }
            dut.io.output.enq.valid.expect(false.B)
            dut.io.control.lastKvPairSeen.expect(true.B)
        }
    }
}
