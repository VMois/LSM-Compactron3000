package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class DummyKvPairFifoSpec extends AnyFreeSpec with ChiselScalatestTester {
    val statusNotLast2Keys4Values = 0x00040200

    "AXI S to KV output buffer to AXI M" in {
        test(new DummyKvPairFifo).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // Send status data
            dut.io.axi_s.tdata.poke(statusNotLast2Keys4Values.U)
            dut.io.axi_s.tready.expect(true.B)
            dut.io.axi_s.tvalid.poke(true.B)
            dut.clock.step()
            
            // Send key
            for (i <- 0 until 2) {
                dut.io.axi_s.tready.expect(true.B)
                dut.io.axi_s.tdata.poke((i + 1000).U)
                dut.clock.step()
            }

            // Send value
            for (i <- 0 until 4) {
                dut.io.axi_s.tready.expect(true.B)
                dut.io.axi_s.tdata.poke((i + 2000).U)
                if (i == 3) {
                    dut.io.axi_s.tlast.poke(true.B)
                }
                dut.clock.step()
            }
            dut.io.axi_s.tvalid.poke(false.B)
            dut.io.axi_s.tlast.poke(false.B)

            // Wait for AXI M to be ready
            dut.io.axi_m.tready.poke(true.B)
            while (dut.io.axi_m.tvalid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            // Read status
            dut.io.axi_m.tdata.expect(statusNotLast2Keys4Values.U)
            dut.clock.step()

            // Read key
            for (i <- 0 until 2) {
                dut.io.axi_m.tvalid.expect(true.B)
                dut.io.axi_m.tdata.expect((i + 1000).U)
                dut.clock.step()
            }
            
            // One clock cycle output is not ready
            dut.io.axi_m.tready.poke(false.B)
            dut.clock.step()
            dut.io.axi_m.tready.poke(true.B)

            // Read value
            for (i <- 0 until 4) {
                dut.io.axi_m.tvalid.expect(true.B)
                dut.io.axi_m.tdata.expect((i + 2000).U)
                dut.clock.step()
            }
            dut.io.axi_m.tvalid.expect(false.B)
            dut.io.axi_m.tlast.expect(false.B)

            // imagine output still wants to read
            dut.io.axi_m.tready.poke(true.B)
            dut.clock.step()
            dut.io.axi_m.tvalid.expect(false.B)
            dut.io.axi_m.tlast.expect(false.B)
        }
    }
}
