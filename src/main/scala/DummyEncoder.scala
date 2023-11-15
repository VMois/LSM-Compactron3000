package compaction_unit

import chisel3._
import chisel3.util._


class EncoderControlIO extends Bundle {
    val lastDataIsProcessed = Input(Bool())
}

class EncoderOutputIO(busWidth: Int) extends Bundle {
    val axi_m = new AxiStreamIO(busWidth)
}

class DummyEncoderIO(busWidth: Int) extends Bundle {
    val control = new EncoderControlIO
    val input = Flipped(new KvRingBufferOutputIO(busWidth))
    val output = new EncoderOutputIO(busWidth)
}


class DummyEncoder(busWidth: Int = 32) extends Module {
    assert (busWidth == 32, "Currently only 32 bits bus is supported")

    val io = IO(new DummyEncoderIO(busWidth))

    val idle :: readValueLen :: outputStatus :: readKvPair :: Nil = Enum(4)

    val state = RegInit(idle)
    val status = RegInit(0.U(busWidth.W))

    switch (state) {
        is (idle) {
            when (io.input.metadataValid) {
                status := Cat(status(31, 16), io.input.deq.bits(7, 0), status(7, 0))
                state := readValueLen
            }
        }

        is (readValueLen) {
            when (io.input.metadataValid) {
                status := Cat(status(31, 24), io.input.deq.bits(7, 0), status(15, 0))
            }
            state := outputStatus
        }

        is (outputStatus) {
            when (io.output.axi_m.tready) {
                state := readKvPair
            }
        }

        is (readKvPair) {
            when (io.input.lastOutput && io.output.axi_m.tready) {
                state := idle
            }
        }
    }
    io.input.outputKeyOnly := DontCare
    io.input.deq.ready := state === readKvPair && io.output.axi_m.tready
    io.output.axi_m.tdata := Mux(state === outputStatus, status, io.input.deq.bits)
    io.output.axi_m.tvalid := state === outputStatus | io.input.deq.valid | io.output.axi_m.tlast
    io.output.axi_m.tlast := state === idle && io.control.lastDataIsProcessed
}
