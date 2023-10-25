package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class DummyEncoderSpec extends AnyFreeSpec with ChiselScalatestTester {
    val statusNotLast2Keys4Values = 0x00040200

    "Transfer KV Pair from output buffer to AXI Stream interface" in {
        test(new DummyEncoder).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // Default setup
            dut.io.input.deq.ready.expect(false.B)
            dut.io.output.axi_m.tvalid.expect(false.B)
            dut.io.output.axi_m.tlast.expect(false.B)

            dut.io.output.axi_m.tready.poke(true.B)
            dut.io.input.deq.valid.poke(false.B)

            // Send key length
            dut.io.input.metadataValid.poke(true.B)
            dut.io.input.deq.bits.poke(2.U)
            dut.clock.step()

            // Send value length
            dut.io.output.axi_m.tvalid.expect(false.B)
            dut.io.input.deq.ready.expect(false.B)
            dut.io.input.deq.bits.poke(4.U)
            dut.clock.step()
            dut.io.input.metadataValid.poke(false.B)
            
            // At this point KV buffer will output valid results but we do not read yet 
            dut.io.input.deq.valid.poke(true.B)

            // Read status
            dut.io.input.deq.ready.expect(false.B)
            dut.io.output.axi_m.tvalid.expect(true.B)
            dut.io.output.axi_m.tdata.expect(statusNotLast2Keys4Values.U)
            dut.clock.step()

            // Send some data
            for (i <- 0 until 3) {
                dut.io.input.deq.ready.expect(true.B)
                dut.io.input.deq.bits.poke((i + 1000).U)
                dut.io.output.axi_m.tvalid.expect(true.B)
                dut.io.output.axi_m.tdata.expect((i + 1000).U)
                dut.clock.step()
            }

            // Send rest of the data
            for (i <- 3 until 6) {
                // AXI not ready for one clock
                dut.io.output.axi_m.tready.poke(false.B)
                dut.io.input.deq.ready.expect(false.B)
                dut.clock.step()
                dut.io.output.axi_m.tready.poke(true.B)

                dut.io.input.deq.ready.expect(true.B)
                dut.io.input.deq.bits.poke((i + 1000).U)
                if (i == 5) {
                    dut.io.input.lastOutput.poke(true.B)
                }
                dut.io.output.axi_m.tvalid.expect(true.B)
                dut.io.output.axi_m.tdata.expect((i + 1000).U)
                dut.clock.step()
            }
            dut.io.input.deq.valid.poke(false.B)
            dut.io.input.deq.ready.expect(false.B)
            dut.io.output.axi_m.tvalid.expect(false.B)
        }
    }
}
