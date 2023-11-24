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

    val buffer1Data = Seq(
        0x00030100,
        0x41416B00,
        0x50704B5A,
        0x4E4E516B,
        0x45490000,

        0x00030100,
        0x414B4900,
        0x4A544353,
        0x47726465,
        0x74440000,

        0x00030300,
        0x42655663,
        0x65727A42,
        0x71000000,
        0x4876744E,
        0x69655865,
        0x6D470000,

        0x00030300,
        0x43735765,
        0x4C4F4C42,
        0x59000000,
        0x4B4D4473,
        0x72644966,
        0x7A770000,

        0x00030300,
        0x4545706E,
        0x4D414B6F,
        0x73000000,
        0x63767143,
        0x54654769,
        0x45620000,

        0x00030300,
        0x45666A65,
        0x46554A74,
        0x58000000,
        0x70516777,
        0x59574256,
        0x657A0000,

        0x00030100,
        0x48526900,
        0x78516955,
        0x4A536748,
        0x77420000,

        0x00030300,
        0x49514554,
        0x61737578,
        0x73410000,
        0x464B4151,
        0x56424F74,
        0x4C6D0000,

        0x00030100,
        0x496F7541,
        0x53557057,
        0x4566566C,
        0x4D680000,

        0x00030100,
        0x4A6A685A,
        0x5366675A,
        0x676B4E4A,
        0x64770000,

        0x00030300,
        0x4C585762,
        0x5844656D,
        0x58000000,
        0x48457A42,
        0x78517642,
        0x766C0000,

        0x00030300,
        0x4D475A72,
        0x4C4D6568,
        0x4E000000,
        0x4E6E7777,
        0x7A487963,
        0x54420000,

        0x00030101,
        0x5048486E,
        0x666C464B,
        0x4A797450,
        0x61520000,
    )

    val buffer2Data = Seq(
        0x00030100,
        0x41416B00,
        0x50704B5A,
        0x4E4E516B,
        0x45491100,

        0x00030100,
        0x414B4900,
        0x4A544353,
        0x47726465,
        0x74442200,

        0x00030200,
        0x43506161,
        0x77424C69,
        0x73546344,
        0x6D615761,
        0x71470000,

        0x00030100,
        0x44626D66,
        0x416A654A,
        0x6944694B,
        0x6F760000,

        0x00030100,
        0x48526900,
        0x78516955,
        0x4A536748,
        0x77421100,

        0x00030300,
        0x49514554,
        0x61737578,
        0x73410000,
        0x464B4151,
        0x56424F74,
        0x4C6D1100,

        0x00030300,
        0x4C585762,
        0x5844656D,
        0x58000000,
        0x48457A42,
        0x78517642,
        0x766C0000,

        0x00030200,
        0x50426C73,
        0x6B794E00,
        0x50527378,
        0x48715477,
        0x6F6F0000,

        0x00030100,
        0x5048486E,
        0x666C464B,
        0x4A797450,
        0x61520000,

        0x00030100,
        0x54536800,
        0x79544C65,
        0x706D5654,
        0x496F0000,

        0x00030100,
        0x56574300,
        0x4441726E,
        0x61615647,
        0x42630000,

        0x00030200,
        0x584E4759,
        0x4E580000,
        0x634F4B45,
        0x7261424E,
        0x43580000,

        0x00030200,
        0x58537465,
        0x4A495100,
        0x774A7443,
        0x4D576C48,
        0x62680000,

        0x00030300,
        0x5A4F756E,
        0x75474A44,
        0x61000000,
        0x61736942,
        0x70486269,
        0x64610000,

        0x00030100,
        0x626D4300,
        0x4A654F67,
        0x7755744E,
        0x43620000,

        0x00030201,
        0x634C4C62,
        0x66000000,
        0x41564E78,
        0x786C5242,
        0x43790000,
    )

    val mergedData = Seq(
        0x00030100,
        0x41416B00,
        0x50704B5A,
        0x4E4E516B,
        0x45490000,

        0x00030100,
        0x414B4900,
        0x4A544353,
        0x47726465,
        0x74440000,

        0x00030300,
        0x42655663,
        0x65727A42,
        0x71000000,
        0x4876744E,
        0x69655865,
        0x6D470000,

        0x00030200,
        0x43506161,
        0x77424C69,
        0x73546344,
        0x6D615761,
        0x71470000,

        0x00030300,
        0x43735765,
        0x4C4F4C42,
        0x59000000,
        0x4B4D4473,
        0x72644966,
        0x7A770000,

        0x00030100,
        0x44626D66,
        0x416A654A,
        0x6944694B,
        0x6F760000,

        0x00030300,
        0x4545706E,
        0x4D414B6F,
        0x73000000,
        0x63767143,
        0x54654769,
        0x45620000,
        
        0x00030300,
        0x45666A65,
        0x46554A74,
        0x58000000,
        0x70516777,
        0x59574256,
        0x657A0000,

        0x00030100,
        0x48526900,
        0x78516955,
        0x4A536748,
        0x77420000,

        0x00030300,
        0x49514554,
        0x61737578,
        0x73410000,
        0x464B4151,
        0x56424F74,
        0x4C6D0000,

        0x00030100,
        0x496F7541,
        0x53557057,
        0x4566566C,
        0x4D680000,

        0x00030100,
        0x4A6A685A,
        0x5366675A,
        0x676B4E4A,
        0x64770000,

        0x00030300,
        0x4C585762,
        0x5844656D,
        0x58000000,
        0x48457A42,
        0x78517642,
        0x766C0000,

        0x00030300,
        0x4D475A72,
        0x4C4D6568,
        0x4E000000,
        0x4E6E7777,
        0x7A487963,
        0x54420000,

        0x00030200,
        0x50426C73,
        0x6B794E00,
        0x50527378,
        0x48715477,
        0x6F6F0000,

        0x00030100,
        0x5048486E,
        0x666C464B,
        0x4A797450,
        0x61520000,

        0x00030100,
        0x54536800,
        0x79544C65,
        0x706D5654,
        0x496F0000,

        0x00030100,
        0x56574300,
        0x4441726E,
        0x61615647,
        0x42630000,

        0x00030200,
        0x584E4759,
        0x4E580000,
        0x634F4B45,
        0x7261424E,
        0x43580000,

        0x00030200,
        0x58537465,
        0x4A495100,
        0x774A7443,
        0x4D576C48,
        0x62680000,

        0x00030300,
        0x5A4F756E,
        0x75474A44,
        0x61000000,
        0x61736942,
        0x70486269,
        0x64610000,

        0x00030100,
        0x626D4300,
        0x4A654F67,
        0x7755744E,
        0x43620000,

        0x00030200,
        0x634C4C62,
        0x66000000,
        0x41564E78,
        0x786C5242,
        0x43790000,
    )


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

    "Two buffers, long compact" in {
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
                for (i <- 0 until buffer1Data.length) {
                    while (dut.io.decoders(0).axi_s.tready.peek().litToBoolean == false) {
                        dut.clock.step()
                    }
                    dut.io.decoders(0).axi_s.tdata.poke(buffer1Data(i).U)
                    dut.io.decoders(0).axi_s.tvalid.poke(true.B)
                    dut.clock.step()
                }
                dut.io.decoders(0).axi_s.tvalid.poke(false.B)
            }.fork {
                // Clock delay for testing purposes
                dut.clock.step(5)

                // Send data for the second buffer
                for (i <- 0 until buffer2Data.length) {
                    while (dut.io.decoders(1).axi_s.tready.peek().litToBoolean == false) {
                        dut.clock.step()
                    }
                    dut.io.decoders(1).axi_s.tdata.poke(buffer2Data(i).U)
                    dut.io.decoders(1).axi_s.tvalid.poke(true.B)
                    dut.clock.step()
                }
                dut.io.decoders(1).axi_s.tvalid.poke(false.B)
            }.fork {
                // Read data from the encoder
                dut.io.encoder.axi_m.tready.poke(true.B)
                for (i <- 0 until mergedData.length) {
                    while (dut.io.encoder.axi_m.tvalid.peek().litToBoolean == false) {
                        dut.clock.step()
                    }
                    dut.io.encoder.axi_m.tdata.expect(mergedData(i).U)
                    dut.io.encoder.axi_m.tvalid.expect(true.B)
                    dut.io.encoder.axi_m.tlast.expect(false.B)
                    dut.clock.step()
                }

                // Get last signal asserted with junk data
                dut.io.encoder.axi_m.tready.poke(false.B)
                dut.io.encoder.axi_m.tlast.expect(true.B)
                dut.io.encoder.axi_m.tvalid.expect(true.B)
                dut.clock.step()

                // Make sure no more data is coming
                dut.io.encoder.axi_m.tlast.expect(false.B)
                dut.io.encoder.axi_m.tvalid.expect(false.B)

                // Make sure we stop being busy after some time
                while (dut.io.control.busy.peek().litToBoolean == true) {
                    dut.clock.step()
                }
            }.join()
        }
    }
}
