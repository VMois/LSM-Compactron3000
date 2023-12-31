package compaction_unit

import chisel3._
import chisel3.util._
import chisel3.experimental.FlatIO


class CompactionUnitIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val control = new ControllerControlIO
    val encoder = new EncoderOutputIO(busWidth)
    val decoders = Vec(numberOfBuffers, new DecoderInputIO(busWidth))
}

class CompactionUnit(busWidth: Int, numberOfBuffers: Int) extends Module {
    val io = IO(new CompactionUnitIO(busWidth, numberOfBuffers))

    val bufferDepth = 9
    val maxKeySizeBits = 256
    val maxValueSizeBits = 896
    val maxMetadataSizeBits = 64

    // Init all modules
    val encoder = Module(new DummyEncoder(busWidth))
    val decoders = Array.fill(numberOfBuffers) { 
        Module(new DummyDecoder(busWidth))
    }
    val inputBuffers = Array.fill(numberOfBuffers) { 
        Module(new KVRingBuffer(depth = bufferDepth, busWidth = busWidth, keySize = maxKeySizeBits, valueSize = maxValueSizeBits, metadataSize = maxMetadataSizeBits))
    }
    val kvTransfer = Module(new TopKvTransfer(busWidth, numberOfBuffers))
    val keyBuffer = Module(new KeyBuffer(busWidth, numberOfBuffers, maximumKeySize = maxKeySizeBits))
    val merger = Module(new Merger(busWidth, numberOfBuffers))
    val outputBuffer = Module(new KVRingBuffer(depth = bufferDepth, busWidth = busWidth, keySize = maxKeySizeBits, valueSize = maxValueSizeBits, metadataSize = maxMetadataSizeBits, autoReadNextPair = true))
    val controller = Module(new Controller(numberOfBuffers))

    // Connect encoder to output buffer
    encoder.io.output.axi_m <> io.encoder.axi_m
    encoder.io.input.deq <> outputBuffer.io.deq
    encoder.io.input.isOutputKey <> outputBuffer.io.isOutputKey
    encoder.io.input.lastOutput <> outputBuffer.io.lastOutput
    encoder.io.input.metadataValid <> outputBuffer.io.metadataValid
    encoder.io.input.outputKeyOnly <> outputBuffer.io.outputKeyOnly

    // Connect decoders to input buffers
    for (i <- 0 until numberOfBuffers) {
        io.decoders(i) <> decoders(i).io.input
        decoders(i).io.output.enq <> inputBuffers(i).io.enq
        decoders(i).io.output.isInputKey <> inputBuffers(i).io.isInputKey
        decoders(i).io.output.lastInput <> inputBuffers(i).io.lastInput
    }

    // Connect KV Transfer to input buffers
    for (i <- 0 until numberOfBuffers) {
        kvTransfer.io.resetBufferRead <> inputBuffers(i).io.control.resetRead
        kvTransfer.io.outputKeyOnly <> inputBuffers(i).io.outputKeyOnly
        kvTransfer.io.lastInputs(i) <> inputBuffers(i).io.lastOutput
        kvTransfer.io.isInputKey(i) <> inputBuffers(i).io.isOutputKey
        kvTransfer.io.enq(i) <> inputBuffers(i).io.deq
    }

    // Connect KV Transfer to key buffer
    keyBuffer.io.enq <> kvTransfer.io.deq
    keyBuffer.io.bufferInputSelect <> kvTransfer.io.bufferSelect   
    keyBuffer.io.incrWritePtr <> kvTransfer.io.incrKeyBufferPtr
    keyBuffer.io.clearBuffer <> kvTransfer.io.clearKeyBuffer
    keyBuffer.io.lastInput <> kvTransfer.io.lastOutput

    // Connect Key buffer to Merger
    merger.io.enq <> keyBuffer.io.deq
    merger.io.lastInput <> keyBuffer.io.lastOutput
    merger.io.bufferInputSelect <> keyBuffer.io.bufferOutputSelect

    // Connect output of KvTransfer to input of Output Buffer
    outputBuffer.io.enq <> kvTransfer.io.deqKvPair
    outputBuffer.io.lastInput <> kvTransfer.io.lastOutput
    outputBuffer.io.isInputKey <> kvTransfer.io.isOutputKey

    // Connect controller to io.control
    controller.io.control.start <> io.control.start
    io.control.busy <> controller.io.control.busy

    // Connect controller to decoders
    for (i <- 0 until numberOfBuffers) {
        controller.io.decoders(i).readyToAccept <> decoders(i).io.control.readyToAccept
        controller.io.decoders(i).lastSeen <> decoders(i).io.control.lastKvPairSeen
    }

    // Connect controller to input buffers
    for (i <- 0 until numberOfBuffers) {
        controller.io.inputBuffers(i).status.empty <> inputBuffers(i).io.status.empty
        controller.io.inputBuffers(i).status.full <> inputBuffers(i).io.status.full
        controller.io.inputBuffers(i).status.halfFull := inputBuffers(i).io.status.halfFull
        controller.io.inputBuffers(i).control.moveReadPtr <> inputBuffers(i).io.control.moveReadPtr
        controller.io.inputBuffers(i).control.resetRead <> DontCare
    }

    // Connect controller to KV Transfer
    controller.io.kvTransfer.busy <> kvTransfer.io.control.busy
    controller.io.kvTransfer.stop <> kvTransfer.io.control.stop
    controller.io.kvTransfer.command <> kvTransfer.io.control.command
    controller.io.kvTransfer.mask <> kvTransfer.io.control.mask
    controller.io.kvTransfer.bufferInputSelect <> kvTransfer.io.control.bufferInputSelect

    // Connect controller to merger
    controller.io.merger.haveWinner <> merger.io.control.haveWinner
    controller.io.merger.isResultValid <> merger.io.control.isResultValid
    controller.io.merger.winnerIndex <> merger.io.control.winnerIndex
    controller.io.merger.nextKvPairsToLoad <> merger.io.control.nextKvPairsToLoad
    controller.io.merger.reset <> merger.io.control.reset
    controller.io.merger.mask <> merger.io.control.mask

    // Connect controller to output buffer
    controller.io.outputBuffer.empty <> outputBuffer.io.status.empty
    controller.io.outputBuffer.full <> outputBuffer.io.status.full
    controller.io.outputBuffer.halfFull <> outputBuffer.io.status.halfFull
    outputBuffer.io.control.moveReadPtr <> DontCare
    outputBuffer.io.control.resetRead <> DontCare

    // Connect controller to encoder
    controller.io.encoder.lastDataIsProcessed <> encoder.io.control.lastDataIsProcessed
}


class TopCompactionUnitIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val control = new Bundle with AxiIO
    val encoder = new EncoderOutputIO(busWidth)
    val decoders = Vec(numberOfBuffers, new DecoderInputIO(busWidth))
}


/** A top level module for CompactionUnit that is used in the Vivado project.
 *  It wraps CompactionUnit and adds AXI Lite interface to provide access to the configuration.
 * 
 *  @param busWidth, the number of bits that can be read from bus at once.
 *  @param numberOfBuffers, the number of ways/files that CompactionUnit supports.
 */
class TopCompactionUnit(busWidth: Int, numberOfBuffers: Int) extends Module {
    val io = IO(new TopCompactionUnitIO(busWidth, numberOfBuffers))

    val controlAdapter = Module(new ControlAdapterVerilog)
    val compactionUnit = Module(new CompactionUnit(busWidth, numberOfBuffers))

    compactionUnit.io.decoders <> io.decoders
    compactionUnit.io.encoder <> io.encoder

    // Connect control adapter to CompactionUnit
    val startSignal = controlAdapter.io.control(0)
    compactionUnit.io.control.start := startSignal
    controlAdapter.io.status := Cat(0.U((busWidth - 1).W), compactionUnit.io.control.busy)

    // Map AXI Lite signals one by one
    // Not great but this is only solution that works for now
    controlAdapter.io.S_AXI_ACLK := io.control.S_AXI_ACLK
    controlAdapter.io.S_AXI_ARESETN := io.control.S_AXI_ARESETN
    controlAdapter.io.S_AXI_AWADDR := io.control.S_AXI_AWADDR
    controlAdapter.io.S_AXI_AWPROT := io.control.S_AXI_AWPROT
    controlAdapter.io.S_AXI_AWVALID := io.control.S_AXI_AWVALID
    io.control.S_AXI_AWREADY := controlAdapter.io.S_AXI_AWREADY
    controlAdapter.io.S_AXI_WDATA := io.control.S_AXI_WDATA
    controlAdapter.io.S_AXI_WSTRB := io.control.S_AXI_WSTRB
    controlAdapter.io.S_AXI_WVALID := io.control.S_AXI_WVALID
    io.control.S_AXI_WREADY := controlAdapter.io.S_AXI_WREADY
    io.control.S_AXI_BRESP := controlAdapter.io.S_AXI_BRESP
    io.control.S_AXI_BVALID := controlAdapter.io.S_AXI_BVALID
    controlAdapter.io.S_AXI_BREADY := io.control.S_AXI_BREADY
    controlAdapter.io.S_AXI_ARADDR := io.control.S_AXI_ARADDR
    controlAdapter.io.S_AXI_ARPROT := io.control.S_AXI_ARPROT
    controlAdapter.io.S_AXI_ARVALID := io.control.S_AXI_ARVALID
    io.control.S_AXI_ARREADY := controlAdapter.io.S_AXI_ARREADY
    io.control.S_AXI_RDATA := controlAdapter.io.S_AXI_RDATA
    io.control.S_AXI_RRESP := controlAdapter.io.S_AXI_RRESP
    io.control.S_AXI_RVALID := controlAdapter.io.S_AXI_RVALID
    controlAdapter.io.S_AXI_RREADY := io.control.S_AXI_RREADY

}

object TopCompactionUnit extends App {
    println("Generating the TopCompactionUnit Verilog...")
    (new chisel3.stage.ChiselStage).emitVerilog(new TopCompactionUnit(busWidth = 32, numberOfBuffers = 2), Array("--target-dir", "Vivado/ip_repo/compaction_unit/CompactionUnit.srcs/sources_1/new/src", "--target:fpga"))
}