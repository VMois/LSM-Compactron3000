/*
  This is a test file to verify that various modules operate correctly.
  This is a less of unit test and more of integration test.
*/

package compaction_unit

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


// TODO: inputs for modules are copied from the modules IO classes. I think it can be done better.
class TestKvRingBufferIO(busWidth: Int) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))

    var moveReadPtr = Input(Bool())

    val outputKeyOnly = Input(Bool())
    val lastInput = Input(Bool())
    val isInputKey = Input(Bool())
}

class TestKvTransferIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val bufferInputSelect = Input(UInt(log2Ceil(numberOfBuffers).W))
    val command = Input(UInt(2.W))
    val stop = Input(Bool())
    val busy = Output(Bool())
    val mask = Input(UInt(numberOfBuffers.W))
}

class TestKeyBufferIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val deq = Decoupled(UInt(busWidth.W))

    val bufferOutputSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val empty = Output(Bool())
    val lastOutput = Output(Bool())
}

class TestMergerIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val reset = Input(Bool())
    val mask = Input(UInt(numberOfBuffers.W))

    val isResultValid = Output(Bool())
    val haveWinner = Output(Bool())
    val winnerIndex = Output(UInt(log2Ceil(numberOfBuffers).W))
    val nextKvPairsToLoad = Output(Vec(numberOfBuffers, Bool()))
}

class TestKvOutputBufferIO(busWidth: Int) extends Bundle {
    var moveReadPtr = Input(Bool())
    var resetRead = Input(Bool())
    val deq = Decoupled(UInt(busWidth.W))
    val outputKeyOnly = Input(Bool())

    val lastOutput = Output(Bool())
    val isOutputKey = Output(Bool())
}

/** A top class to integrate several KvRingBuffers, TopKvTransfer, and KeyBuffer.
 *
 */
class TopTestModule(busWidth: Int, numberOfBuffers: Int) extends Module {
    val io = IO(new Bundle {
        val buffers = Vec(numberOfBuffers, new TestKvRingBufferIO(busWidth))
        val kvTransfer = new TestKvTransferIO(busWidth, numberOfBuffers)
        val keyBuffer = new TestKeyBufferIO(busWidth, numberOfBuffers)
    })
    val depthOfBuffer = 4
    val keySize = busWidth * 3
    val valueSize = busWidth * 3
    val metadataSize = 8

    val kvRingBuffers = Array.fill(numberOfBuffers) { 
        Module(new KVRingBuffer(depthOfBuffer, busWidth, keySize, valueSize, metadataSize))
    }
    val topKvTransfer = Module(new TopKvTransfer(busWidth, numberOfBuffers))
    val keyBuffer = Module(new KeyBuffer(busWidth, numberOfBuffers, keySize))

    // connects KV ring buffers to TopKvTransfer
    for (i <- 0 until numberOfBuffers) {
        io.buffers(i).enq <> kvRingBuffers(i).io.enq
        io.buffers(i).lastInput <> kvRingBuffers(i).io.lastInput
        io.buffers(i).moveReadPtr <> kvRingBuffers(i).io.moveReadPtr
        io.buffers(i).outputKeyOnly <> kvRingBuffers(i).io.outputKeyOnly
        io.buffers(i).isInputKey <> kvRingBuffers(i).io.isInputKey

        topKvTransfer.io.resetBufferRead <> kvRingBuffers(i).io.resetRead
        topKvTransfer.io.outputKeyOnly <> kvRingBuffers(i).io.outputKeyOnly
        topKvTransfer.io.lastInputs(i) <> kvRingBuffers(i).io.lastOutput
        topKvTransfer.io.isInputKey(i) <> kvRingBuffers(i).io.isOutputKey
        topKvTransfer.io.enq(i) <> kvRingBuffers(i).io.deq
    }

    topKvTransfer.io.bufferInputSelect <> io.kvTransfer.bufferInputSelect
    topKvTransfer.io.stop <> io.kvTransfer.stop
    topKvTransfer.io.command <> io.kvTransfer.command
    topKvTransfer.io.busy <> io.kvTransfer.busy
    topKvTransfer.io.mask <> io.kvTransfer.mask
    topKvTransfer.io.deqKvPair <> DontCare

    // connect TopKvTransfer to KeyBuffer
    keyBuffer.io.enq <> topKvTransfer.io.deq
    keyBuffer.io.bufferInputSelect <> topKvTransfer.io.bufferSelect   
    keyBuffer.io.incrWritePtr <> topKvTransfer.io.incrKeyBufferPtr
    keyBuffer.io.clearBuffer <> topKvTransfer.io.clearKeyBuffer
    keyBuffer.io.lastInput <> topKvTransfer.io.lastOutput

    // Connect output of KeyBuffer to output of TopTestModule
    io.keyBuffer.deq <> keyBuffer.io.deq
    io.keyBuffer.bufferOutputSelect <> keyBuffer.io.bufferOutputSelect
    io.keyBuffer.empty <> keyBuffer.io.empty
    io.keyBuffer.lastOutput <> keyBuffer.io.lastOutput
}

/** A top class to integrate several KvRingBuffers, TopKvTransfer, KeyBuffer and Merger.
 *
 */
class TopTestMergerModule(busWidth: Int, numberOfBuffers: Int) extends Module {
    val io = IO(new Bundle {
        val buffers = Vec(numberOfBuffers, new TestKvRingBufferIO(busWidth))
        val kvTransfer = new TestKvTransferIO(busWidth, numberOfBuffers)
        val merger = new TestMergerIO(busWidth, numberOfBuffers)
        val kvOutput = new TestKvOutputBufferIO(busWidth)
    })
    val depthOfBuffer = 4
    val keySize = busWidth * 3
    val valueSize = busWidth * 3
    val metadataSize = 8

    val kvRingBuffers = Array.fill(numberOfBuffers) { 
        Module(new KVRingBuffer(depthOfBuffer, busWidth, keySize, valueSize, metadataSize))
    }
    val kvOutputBuffer = Module(new KVRingBuffer(depthOfBuffer * 2, busWidth, keySize, valueSize, metadataSize))
    val topKvTransfer = Module(new TopKvTransfer(busWidth, numberOfBuffers))
    val keyBuffer = Module(new KeyBuffer(busWidth, numberOfBuffers, keySize))
    val merger = Module(new Merger(busWidth, numberOfBuffers))

    // connects KV ring buffers to TopKvTransfer
    for (i <- 0 until numberOfBuffers) {
        io.buffers(i).enq <> kvRingBuffers(i).io.enq
        io.buffers(i).lastInput <> kvRingBuffers(i).io.lastInput
        io.buffers(i).moveReadPtr <> kvRingBuffers(i).io.moveReadPtr
        io.buffers(i).outputKeyOnly <> kvRingBuffers(i).io.outputKeyOnly
        io.buffers(i).isInputKey <> kvRingBuffers(i).io.isInputKey

        topKvTransfer.io.resetBufferRead <> kvRingBuffers(i).io.resetRead
        topKvTransfer.io.outputKeyOnly <> kvRingBuffers(i).io.outputKeyOnly
        topKvTransfer.io.lastInputs(i) <> kvRingBuffers(i).io.lastOutput
        topKvTransfer.io.isInputKey(i) <> kvRingBuffers(i).io.isOutputKey
        topKvTransfer.io.enq(i) <> kvRingBuffers(i).io.deq
    }

    topKvTransfer.io.bufferInputSelect <> io.kvTransfer.bufferInputSelect
    topKvTransfer.io.stop <> io.kvTransfer.stop
    topKvTransfer.io.command <> io.kvTransfer.command
    topKvTransfer.io.busy <> io.kvTransfer.busy
    topKvTransfer.io.mask <> io.kvTransfer.mask

    // connect TopKvTransfer to KeyBuffer
    keyBuffer.io.enq <> topKvTransfer.io.deq
    keyBuffer.io.bufferInputSelect <> topKvTransfer.io.bufferSelect   
    keyBuffer.io.incrWritePtr <> topKvTransfer.io.incrKeyBufferPtr
    keyBuffer.io.clearBuffer <> topKvTransfer.io.clearKeyBuffer
    keyBuffer.io.lastInput <> topKvTransfer.io.lastOutput

    // Connect KeyBuffer to input of Merger
    merger.io.enq <> keyBuffer.io.deq
    merger.io.lastInput <> keyBuffer.io.lastOutput
    merger.io.bufferInputSelect <> keyBuffer.io.bufferOutputSelect

    // Connect io of Merger to io of TopTestModule
    io.merger.isResultValid <> merger.io.isResultValid
    io.merger.haveWinner <> merger.io.haveWinner
    io.merger.winnerIndex <> merger.io.winnerIndex
    io.merger.nextKvPairsToLoad <> merger.io.nextKvPairsToLoad
    io.merger.reset <> merger.io.reset
    io.merger.mask <> merger.io.mask

    // Connect output of KvTransfer to input of KVOutputBuffer
    kvOutputBuffer.io.enq <> topKvTransfer.io.deqKvPair
    kvOutputBuffer.io.lastInput <> topKvTransfer.io.lastOutput
    kvOutputBuffer.io.isInputKey <> topKvTransfer.io.isOutputKey
    kvOutputBuffer.io.outputKeyOnly <> io.kvOutput.outputKeyOnly
    io.kvOutput.deq <> kvOutputBuffer.io.deq
    io.kvOutput.lastOutput <> kvOutputBuffer.io.lastOutput
    io.kvOutput.isOutputKey <> kvOutputBuffer.io.isOutputKey
    io.kvOutput.moveReadPtr <> kvOutputBuffer.io.moveReadPtr
    io.kvOutput.resetRead <> kvOutputBuffer.io.resetRead
}


class KvRingBuffersAndKvTransferAndKeyBufferSpec extends AnyFreeSpec with ChiselScalatestTester {
    val busWidth = 4
    val numberOfBuffers = 4
    
    "Should transfer rows of key chunks from buffers" in {
        test(new TopTestModule(busWidth, numberOfBuffers)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default input values
            dut.io.keyBuffer.deq.ready.poke(false.B)
            for (i <- 0 until 4) {
                dut.io.buffers(i).enq.bits.poke(0.U)
                dut.io.buffers(i).enq.valid.poke(false.B)
                dut.io.buffers(i).lastInput.poke(false.B)
                dut.io.buffers(i).isInputKey.poke(false.B)
            }
            dut.clock.step()

            // Write two KV pairs to each buffer
            for (i <- 0 until 2) {

                // Write first keys to each buffer
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke((i + 0 + k).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(true.B)
                }

                dut.clock.step()

                // Write second keys to buffers
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke((i + 4 + k).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(true.B)
                }

                dut.clock.step()

                // Write first values to each buffer
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke((8 + k).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(false.B)
                }

                dut.clock.step()

                // Write second values to buffers
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke((12 + k).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(false.B)
                    dut.io.buffers(k).lastInput.poke(true.B)
                }

                dut.clock.step()

                for (k <- 0 until 4) {
                    dut.io.buffers(k).lastInput.poke(false.B)
                    while (dut.io.buffers(k).enq.ready.peek().litToBoolean == false) {
                        dut.clock.step()
                    }
                }
            }

            // Send command to KvTransfer to start filling KeyBuffer with chunks
            dut.io.kvTransfer.command.poke("b01".U)
            dut.io.kvTransfer.mask.poke("b1111".U)
            dut.clock.step()
            dut.io.kvTransfer.command.poke("b00".U)

            // Wait for key chunks to be available in KeyBuffer
            while (dut.io.keyBuffer.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.keyBuffer.empty.expect(false.B)
            dut.io.keyBuffer.deq.ready.poke(true.B)

            // Read first row of key chunks
            for (i <- 0 until 4) {
                dut.io.keyBuffer.deq.valid.expect(true.B)
                dut.io.keyBuffer.lastOutput.expect(false.B)
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((0 + i).U)
                dut.clock.step()
            }

            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.keyBuffer.deq.valid.expect(true.B)
                dut.io.keyBuffer.lastOutput.expect(true.B)
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((4 + i).U)
                dut.clock.step()
            }

            dut.io.keyBuffer.empty.expect(true.B)
            dut.io.keyBuffer.deq.ready.poke(false.B)
            dut.io.keyBuffer.deq.valid.expect(false.B)

            // Move read pointer to the next KV pair
            for (k <- 0 until 4) {
                dut.io.buffers(k).moveReadPtr.poke(true.B)
            }
            dut.clock.step()
            for (k <- 0 until 4) {
                dut.io.buffers(k).moveReadPtr.poke(false.B)
            }

            // Send command to KvTransfer to start filling KeyBuffer with chunks
            dut.io.kvTransfer.command.poke("b01".U)
            dut.clock.step()
            dut.io.kvTransfer.command.poke("b00".U)

            // Wait for key chunks to be available in KeyBuffer
            while (dut.io.keyBuffer.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.keyBuffer.deq.ready.poke(true.B)
            // Read first row of key chunks
            for (i <- 0 until 4) {
                dut.io.keyBuffer.deq.valid.expect(true.B)
                dut.io.keyBuffer.lastOutput.expect(false.B)
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((1 + i).U)
                dut.clock.step()
            }

            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.keyBuffer.deq.valid.expect(true.B)
                dut.io.keyBuffer.lastOutput.expect(true.B)
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((5 + i).U)
                dut.clock.step()
            }
            dut.io.keyBuffer.empty.expect(true.B)
            dut.io.keyBuffer.deq.valid.expect(false.B)
            dut.io.keyBuffer.deq.ready.poke(false.B)

            dut.clock.step()

            dut.io.keyBuffer.empty.expect(true.B)
            dut.io.keyBuffer.deq.valid.expect(false.B)
        }
    }

    "Should correctly select winner buffers and read KV pairs from output buffer" in {
        test(new TopTestMergerModule(busWidth, numberOfBuffers)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // setup default input values
            for (i <- 0 until 4) {
                dut.io.buffers(i).enq.bits.poke(0.U)
                dut.io.buffers(i).enq.valid.poke(false.B)
                dut.io.buffers(i).lastInput.poke(false.B)
                dut.io.buffers(i).isInputKey.poke(false.B)
            }
            dut.io.merger.reset.poke(true.B)
            dut.io.merger.mask.poke("b1111".U)
            dut.clock.step()
            dut.io.merger.reset.poke(false.B)

            val kvPairs = List(
                // kvPair 1
                List(
                    // kvPair 1, for buffers from 0 to 3
                    List(0xA, 0xC, 2, 3),
                    List(0xC, 0xA, 4, 5),
                    List(0xB, 0xB, 6, 7),
                    List(0xD, 0xB, 8, 9),
                ),
                // kvPair 2
                List(
                    // kvPair 2, for buffers from 0 to 3
                    List(0xD, 0xC, 2, 3),
                    List(0xB, 0xA, 4, 5),
                    List(0xA, 0xB, 6, 7),
                    List(0xD, 0xA, 8, 9),
                )
            )

            // Write two KV pairs to each buffer
            for (i <- 0 until 2) {

                // Write first keys to each buffer
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke(kvPairs(i)(k)(0).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(true.B)
                }

                dut.clock.step()

                // Write second keys to buffers
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke(kvPairs(i)(k)(1).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(true.B)
                }

                dut.clock.step()

                // Write first values to each buffer
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke(kvPairs(i)(k)(2).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(false.B)
                }

                dut.clock.step()

                // Write second values to buffers
                for (k <- 0 until 4) {
                    dut.io.buffers(k).enq.ready.expect(true.B)
                    dut.io.buffers(k).enq.bits.poke(kvPairs(i)(k)(3).U)
                    dut.io.buffers(k).enq.valid.poke(true.B)
                    dut.io.buffers(k).isInputKey.poke(false.B)
                    dut.io.buffers(k).lastInput.poke(true.B)
                }

                dut.clock.step()

                for (k <- 0 until 4) {
                    dut.io.buffers(k).lastInput.poke(false.B)
                    dut.io.buffers(k).enq.valid.poke(false.B)
                }

                for (k <- 0 until 4) {
                    while (dut.io.buffers(k).enq.ready.peek().litToBoolean == false) {
                        dut.clock.step()
                    }
                }
            }

            // Send command to KvTransfer to start filling KeyBuffer with chunks
            dut.io.kvTransfer.command.poke("b01".U)
            dut.io.kvTransfer.mask.poke("b1111".U)
            dut.clock.step()
            dut.io.kvTransfer.command.poke("b00".U)

            // Wait for merger result to be available
            while (!(dut.io.merger.isResultValid.peek().litToBoolean == true && dut.io.merger.haveWinner.peek().litToBoolean == true)) {
                dut.clock.step()
            }

            dut.io.merger.haveWinner.expect(true.B)
            dut.io.merger.isResultValid.expect(true.B)
            dut.io.merger.winnerIndex.expect(0.U)
            dut.io.merger.nextKvPairsToLoad(0).expect(true.B)
            dut.io.merger.nextKvPairsToLoad(1).expect(false.B)
            dut.io.merger.nextKvPairsToLoad(2).expect(false.B)
            dut.io.merger.nextKvPairsToLoad(3).expect(false.B)

            dut.clock.step()

            // Winner results should remain the same until reset
            dut.io.merger.haveWinner.expect(true.B)
            dut.io.merger.isResultValid.expect(true.B)
            dut.io.merger.winnerIndex.expect(0.U)
            dut.io.merger.nextKvPairsToLoad(0).expect(true.B)
            dut.io.merger.nextKvPairsToLoad(1).expect(false.B)
            dut.io.merger.nextKvPairsToLoad(2).expect(false.B)
            dut.io.merger.nextKvPairsToLoad(3).expect(false.B)

            // Stop transfer of keys from buffers
            dut.io.kvTransfer.stop.poke(true.B)
            dut.clock.step()
            dut.io.kvTransfer.stop.poke(false.B)

            // Start transferring winner KV pair to KV output buffer
            dut.io.kvTransfer.command.poke("b10".U)
            dut.io.kvTransfer.bufferInputSelect.poke(0.U)
            dut.clock.step()
            dut.io.kvTransfer.command.poke("b00".U)
            dut.io.kvTransfer.busy.expect(true.B)

            // Wait until KV pair is transferred to KV output buffer
            while (dut.io.kvTransfer.busy.peek().litToBoolean == true) {
                dut.clock.step()
            }
            // Move read pointer to the next KV pair on winner buffer
            dut.io.buffers(0).moveReadPtr.poke(true.B)
            dut.clock.step()
            dut.io.buffers(0).moveReadPtr.poke(false.B)

            // Start next round of comparison, transfer keys from buffers to Key buffer
            dut.io.merger.reset.poke(true.B)
            dut.io.kvTransfer.command.poke("b01".U)
            dut.clock.step()
            dut.io.kvTransfer.command.poke("b00".U)
            dut.io.merger.reset.poke(false.B)
            dut.clock.step()

            // Wait for merger result to be available
            while (!(dut.io.merger.isResultValid.peek().litToBoolean == true && dut.io.merger.haveWinner.peek().litToBoolean == true)) {
                dut.clock.step()
            }

            dut.io.merger.haveWinner.expect(true.B)
            dut.io.merger.isResultValid.expect(true.B)
            dut.io.merger.winnerIndex.expect(2.U)
            dut.io.merger.nextKvPairsToLoad(0).expect(false.B)
            dut.io.merger.nextKvPairsToLoad(1).expect(false.B)
            dut.io.merger.nextKvPairsToLoad(2).expect(true.B)
            dut.io.merger.nextKvPairsToLoad(3).expect(false.B)

            // Stop transfer of keys from buffers
            dut.io.kvTransfer.stop.poke(true.B)
            dut.clock.step()
            dut.io.kvTransfer.stop.poke(false.B)

            // Start transferring winner KV pair to KV output buffer
            dut.io.kvTransfer.command.poke("b10".U)
            dut.io.kvTransfer.bufferInputSelect.poke(2.U)
            dut.clock.step()
            dut.io.kvTransfer.command.poke("b00".U)
            dut.io.kvTransfer.busy.expect(true.B)

            // Wait until KV pair is transferred to KV output buffer
            while (dut.io.kvTransfer.busy.peek().litToBoolean == true) {
                dut.clock.step()
            }

            // Move read pointer to the next KV pair on winner buffer
            dut.io.buffers(2).moveReadPtr.poke(true.B)
            dut.clock.step()
            dut.io.buffers(2).moveReadPtr.poke(false.B)

            // Read first KV pair
            dut.io.kvOutput.deq.ready.poke(true.B)
            dut.io.kvOutput.outputKeyOnly.poke(false.B)
            while (dut.io.kvOutput.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }
            dut.io.kvOutput.deq.bits.expect(0xA.U)
            dut.io.kvOutput.isOutputKey.expect(true.B)
            dut.io.kvOutput.lastOutput.expect(false.B)
            dut.clock.step()
            dut.io.kvOutput.deq.valid.expect(true.B)
            dut.io.kvOutput.isOutputKey.expect(true.B)
            dut.io.kvOutput.deq.bits.expect(0xC.U)
            dut.io.kvOutput.lastOutput.expect(false.B)
            dut.clock.step()
            dut.io.kvOutput.deq.valid.expect(true.B)
            dut.io.kvOutput.isOutputKey.expect(false.B)
            dut.io.kvOutput.deq.bits.expect(2.U)
            dut.io.kvOutput.lastOutput.expect(false.B)
            dut.clock.step()
            dut.io.kvOutput.deq.valid.expect(true.B)
            dut.io.kvOutput.isOutputKey.expect(false.B)
            dut.io.kvOutput.deq.bits.expect(3.U)
            dut.io.kvOutput.lastOutput.expect(true.B)

            // Read second KV pair
            dut.io.kvOutput.moveReadPtr.poke(true.B)
            dut.clock.step()
            dut.io.kvOutput.moveReadPtr.poke(false.B)

            while (dut.io.kvOutput.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }
            dut.io.kvOutput.deq.bits.expect(0xB.U)
            dut.io.kvOutput.isOutputKey.expect(true.B)
            dut.io.kvOutput.lastOutput.expect(false.B)
            dut.clock.step()
            dut.io.kvOutput.deq.valid.expect(true.B)
            dut.io.kvOutput.isOutputKey.expect(true.B)
            dut.io.kvOutput.deq.bits.expect(0xB.U)
            dut.io.kvOutput.lastOutput.expect(false.B)
            dut.clock.step()
            dut.io.kvOutput.deq.valid.expect(true.B)
            dut.io.kvOutput.isOutputKey.expect(false.B)
            dut.io.kvOutput.deq.bits.expect(6.U)
            dut.io.kvOutput.lastOutput.expect(false.B)
            dut.clock.step()
            dut.io.kvOutput.deq.valid.expect(true.B)
            dut.io.kvOutput.isOutputKey.expect(false.B)
            dut.io.kvOutput.deq.bits.expect(7.U)
            dut.io.kvOutput.lastOutput.expect(true.B)
        }
    }
}
