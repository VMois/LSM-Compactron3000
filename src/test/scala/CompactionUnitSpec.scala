package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class CompactionUnitSpec extends AnyFreeSpec with ChiselScalatestTester {
    val statusNotLast2Keys4Values = 0x00040200
    val statusNotLast3Keys4Values = 0x00040300
    val statusNotLast3Keys3Values = 0x00030300
    val statusLast2Keys4Values = 0x00040201
    val statusLast3Keys4Values = 0x00040301

    "Two buffers, short compact" in {
        test(new CompactionUnit(busWidth = 32, numberOfBuffers = 2)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            dut.io.control.busy.expect(false.B)

            dut.clock.step()
            
            // Start compaction
            dut.io.control.start.poke(true.B)
            dut.clock.step()
            dut.io.control.start.poke(false.B)
            dut.io.control.busy.expect(true.B)

            fork {
                // Send data for the first buffer

                // Clock delay for testing purposes
                dut.clock.step(3)

                // KV1
                // Send status
                dut.io.decoders(0).axi_s.tdata.poke(statusNotLast2Keys4Values.U)
                dut.io.decoders(0).axi_s.tready.expect(true.B)
                dut.io.decoders(0).axi_s.tvalid.poke(true.B)
                dut.clock.step()

                // Send key
                for (i <- 0 until 2) {
                    dut.io.decoders(0).axi_s.tready.expect(true.B)
                    dut.io.decoders(0).axi_s.tdata.poke((i + 1000).U)
                    dut.clock.step()
                }

                // Send value
                for (i <- 0 until 4) {
                    dut.io.decoders(0).axi_s.tready.expect(true.B)
                    dut.io.decoders(0).axi_s.tdata.poke((i + 2000).U)
                    dut.clock.step()
                }

                // Wait until decoder is available
                while (dut.io.decoders(0).axi_s.tready.peek().litToBoolean == false) {
                    dut.clock.step()
                }

                // KV2
                // Send status
                dut.io.decoders(0).axi_s.tdata.poke(statusLast3Keys4Values.U)
                dut.io.decoders(0).axi_s.tready.expect(true.B)
                dut.io.decoders(0).axi_s.tvalid.poke(true.B)
                dut.clock.step()

                // Send key
                for (i <- 0 until 3) {
                    dut.io.decoders(0).axi_s.tready.expect(true.B)
                    dut.io.decoders(0).axi_s.tdata.poke((i + 2000).U)
                    dut.clock.step()
                }

                // Send value
                for (i <- 0 until 4) {
                    dut.io.decoders(0).axi_s.tready.expect(true.B)
                    dut.io.decoders(0).axi_s.tdata.poke((i + 3000).U)
                    dut.clock.step()
                }
                dut.io.decoders(0).axi_s.tvalid.poke(false.B)
            }.fork {
                // Send data for the second buffer

                // KV3
                // Send status
                dut.io.decoders(1).axi_s.tdata.poke(statusNotLast3Keys3Values.U)
                dut.io.decoders(1).axi_s.tready.expect(true.B)
                dut.io.decoders(1).axi_s.tvalid.poke(true.B)
                dut.clock.step()

                // Send key
                for (i <- 0 until 3) {
                    dut.io.decoders(1).axi_s.tready.expect(true.B)
                    dut.io.decoders(1).axi_s.tdata.poke((i + 2000).U)
                    dut.clock.step()
                }

                // Send value
                for (i <- 0 until 3) {
                    dut.io.decoders(1).axi_s.tready.expect(true.B)
                    dut.io.decoders(1).axi_s.tdata.poke((i + 5000).U)
                    dut.clock.step()
                }

                // Wait until decoder is available
                while (dut.io.decoders(1).axi_s.tready.peek().litToBoolean == false) {
                    dut.clock.step()
                }

                // KV4
                // Send status
                dut.io.decoders(1).axi_s.tdata.poke(statusLast3Keys4Values.U)
                dut.io.decoders(1).axi_s.tready.expect(true.B)
                dut.io.decoders(1).axi_s.tvalid.poke(true.B)
                dut.clock.step()

                // Send key
                for (i <- 0 until 3) {
                    dut.io.decoders(1).axi_s.tready.expect(true.B)
                    dut.io.decoders(1).axi_s.tdata.poke((i + 4000).U)
                    dut.clock.step()
                }

                // Send value
                for (i <- 0 until 4) {
                    dut.io.decoders(1).axi_s.tready.expect(true.B)
                    dut.io.decoders(1).axi_s.tdata.poke((i + 5000).U)
                    dut.clock.step()
                }
                dut.io.decoders(1).axi_s.tvalid.poke(false.B)
            }.fork {
                // Read data from the encoder

                dut.io.encoder.axi_m.tready.poke(true.B)
                while (dut.io.encoder.axi_m.tvalid.peek().litToBoolean == false) {
                    dut.clock.step()
                }

                // Check KV1
                dut.io.encoder.axi_m.tdata.expect(statusNotLast2Keys4Values.U)
                dut.io.encoder.axi_m.tvalid.expect(true.B)
                dut.io.encoder.axi_m.tlast.expect(false.B)
                dut.clock.step()
                
                for (i <- 0 until 2) {
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tlast.expect(false.B)
                    dut.io.encoder.axi_m.tdata.expect((i + 1000).U)
                    dut.clock.step()
                }

                for (i <- 0 until 4) {
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tdata.expect((i + 2000).U)
                    dut.clock.step()
                }

                // Check KV2
                while (dut.io.encoder.axi_m.tvalid.peek().litToBoolean == false) {
                    dut.clock.step()
                }

                // Add delay for testing purposes
                dut.io.encoder.axi_m.tready.poke(false.B)
                dut.clock.step()
                dut.io.encoder.axi_m.tready.poke(true.B)

                dut.io.encoder.axi_m.tdata.expect(statusNotLast3Keys4Values.U)
                dut.io.encoder.axi_m.tlast.expect(false.B)
                dut.io.encoder.axi_m.tvalid.expect(true.B)
                dut.clock.step()

                for (i <- 0 until 3) {
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tlast.expect(false.B)
                    dut.io.encoder.axi_m.tdata.expect((i + 2000).U)
                    dut.clock.step()
                }

                for (i <- 0 until 4) {
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tdata.expect((i + 3000).U)
                    dut.clock.step()
                }
                
                // Check KV4
                while (dut.io.encoder.axi_m.tvalid.peek().litToBoolean == false) {
                    dut.clock.step()
                }

                dut.io.encoder.axi_m.tdata.expect(statusNotLast3Keys4Values.U)
                dut.io.encoder.axi_m.tvalid.expect(true.B)
                dut.io.encoder.axi_m.tlast.expect(false.B)
                dut.clock.step()

                for (i <- 0 until 3) {
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tlast.expect(false.B)
                    dut.io.encoder.axi_m.tdata.expect((i + 4000).U)
                    dut.clock.step()
                }

                for (i <- 0 until 4) {
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tdata.expect((i + 5000).U)
                    dut.clock.step()
                }

                dut.io.encoder.axi_m.tvalid.expect(true.B)
                dut.io.encoder.axi_m.tlast.expect(true.B)

                // Make sure we stop being busy after some time
                while (dut.io.control.busy.peek().litToBoolean == true) {
                    dut.clock.step()
                }
            }.join()
        }
    }
}
