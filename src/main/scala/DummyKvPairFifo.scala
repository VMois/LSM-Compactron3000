package compaction_unit

import chisel3._
import chisel3.util._
import chisel3.experimental.FlatIO


class DummyKvPairFifo(busWidth: Int = 32) extends Module {
    assert (busWidth == 32, "Currently only 32 bits bus is supported")

    val io = IO(new Bundle {
        val axi_s = Flipped(new AxiStreamIO(busWidth))
        val axi_m = new AxiStreamIO(busWidth)
    })

    val encoder = Module(new DummyEncoder(busWidth))
    val decoder = Module(new DummyDecoder(busWidth))
    val kvOutputBuffer = Module(new KVRingBuffer(4, busWidth, 4 * busWidth, 4 * busWidth, 2 * busWidth, autoReadNextPair = true))

    kvOutputBuffer.io.full <> DontCare
    kvOutputBuffer.io.empty <> DontCare
    kvOutputBuffer.io.resetRead := false.B
    kvOutputBuffer.io.moveReadPtr <> DontCare


    encoder.io.input.deq <> kvOutputBuffer.io.deq
    encoder.io.input.isOutputKey <> kvOutputBuffer.io.isOutputKey
    encoder.io.input.lastOutput <> kvOutputBuffer.io.lastOutput
    encoder.io.input.metadataValid <> kvOutputBuffer.io.metadataValid
    encoder.io.input.outputKeyOnly <> kvOutputBuffer.io.outputKeyOnly

    encoder.io.output.axi_m <> io.axi_m
    decoder.io.input.axi_s <> io.axi_s

    decoder.io.readyToAccept := true.B
    decoder.io.output.enq <> kvOutputBuffer.io.enq
    decoder.io.output.isInputKey <> kvOutputBuffer.io.isInputKey
    decoder.io.output.lastInput <> kvOutputBuffer.io.lastInput
}

object DummyKvPairFifoMain extends App {
  println("Generating the dummy KV pair FIFO Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new DummyKvPairFifo, Array("--target-dir", "Vivado/src/hdl", "--target:fpga"))
}
