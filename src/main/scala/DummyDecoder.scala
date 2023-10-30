package compaction_unit

import chisel3._
import chisel3.util._


class DecoderInputIO(busWidth: Int) extends Bundle {
    val axi_s = Flipped(new AxiStreamIO(busWidth))
}


class DummyDecoder(busWidth: Int = 32) extends Module {
    assert (busWidth == 32, "Currently only 32 bits bus is supported")

    val io = IO(new Bundle {
        val input = new DecoderInputIO(busWidth)
        val output = Flipped(new KvRingBufferInputIO(busWidth))

        val readyToAccept = Input(Bool())
        val lastKvPairSeen = Output(Bool())
    })

    // TODO: do not care about it for now but it might need a fix
    io.input.axi_s.tlast <> DontCare

    val idle :: readKey :: readValue :: Nil = Enum(3)
    val state = RegInit(idle)
    val status = RegInit(0.U(busWidth.W))
    val lastSeen = RegInit(false.B)

    // 8-bit counter is enough to count up to 256 * 4 bytes (32-bits) = 1 KB
    val counter = RegInit(0.U(8.W))

    // First data from AXI is status
    val keyLen = status(15, 8) - 1.U
    val valueLen = status(23, 16) - 1.U
    val isLastKvPair = status(0)

    switch (state) {
        is (idle) {
            when (io.input.axi_s.tvalid) {
                state := readKey
                status := io.input.axi_s.tdata
            }
        }

        is (readKey) {
            when (io.input.axi_s.tvalid && io.output.enq.ready) {
                counter := counter + 1.U

                when (counter === keyLen) {
                    state := readValue
                    counter := 0.U
                }
            }
        }

        is (readValue) {
            when (io.input.axi_s.tvalid && io.output.enq.ready) {
                counter := counter + 1.U

                when (counter === valueLen) {
                    state := idle
                    counter := 0.U
                    lastSeen := isLastKvPair
                }
            }
        }
    }

    // TODO: readyToAccept maybe needs to be saved in register
    io.input.axi_s.tready := io.readyToAccept && io.output.enq.ready
    io.lastKvPairSeen := isLastKvPair

    io.output.enq.valid := (state === readKey || state === readValue) && io.input.axi_s.tvalid
    io.output.enq.bits := io.input.axi_s.tdata
    io.output.isInputKey := state === readKey
    io.output.lastInput := state === readValue && counter === valueLen
}

object Decoder extends App {
  println("Generating the Decoder Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new DummyDecoder(32), Array("--target-dir", "generated"))
}