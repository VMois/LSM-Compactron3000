/*
  This is a test file to verify that KvRingBuffers, KvTransfer and KeyBuffer modules are integrated correctly.
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
    var resetRead = Input(Bool())

    val outputKeyOnly = Input(Bool())
    val lastInput = Input(Bool())
    val isInputKey = Input(Bool())
}

class TestKvTransferIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val command = Input(UInt(2.W))
    val stop = Input(Bool())
}

class TestKeyBufferIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val deq = Decoupled(UInt(busWidth.W))

    val bufferOutputSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val empty = Output(Bool())
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
        io.buffers(i).resetRead <> kvRingBuffers(i).io.resetRead
        io.buffers(i).outputKeyOnly <> kvRingBuffers(i).io.outputKeyOnly
        io.buffers(i).isInputKey <> kvRingBuffers(i).io.isInputKey

        topKvTransfer.io.outputKeyOnly <> kvRingBuffers(i).io.outputKeyOnly
        topKvTransfer.io.lastInputs(i) <> kvRingBuffers(i).io.lastOutput
        topKvTransfer.io.enq(i) <> kvRingBuffers(i).io.deq
    }

    topKvTransfer.io.stop <> io.kvTransfer.stop
    topKvTransfer.io.command <> io.kvTransfer.command

    // connect TopKvTransfer to KeyBuffer
    keyBuffer.io.enq <> topKvTransfer.io.deq
    keyBuffer.io.bufferInputSelect <> topKvTransfer.io.bufferSelect   
    keyBuffer.io.incrWritePtr <> topKvTransfer.io.incrKeyBufferPtr
    keyBuffer.io.clearBuffer <> topKvTransfer.io.clearKeyBuffer

    // Connect output of KeyBuffer to output of TopTestModule
    io.keyBuffer.deq <> keyBuffer.io.deq
    io.keyBuffer.bufferOutputSelect <> keyBuffer.io.bufferOutputSelect
    io.keyBuffer.empty <> keyBuffer.io.empty
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
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((0 + i).U)
                dut.clock.step()
            }

            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.keyBuffer.deq.valid.expect(true.B)
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((4 + i).U)
                dut.clock.step()
            }

            dut.io.keyBuffer.empty.expect(true.B)
            dut.io.keyBuffer.deq.ready.poke(false.B)

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
                dut.io.keyBuffer.bufferOutputSelect.expect(i.U)
                dut.io.keyBuffer.deq.bits.expect((1 + i).U)
                dut.clock.step()
            }

            // Read second row of key chunks
            for (i <- 0 until 4) {
                dut.io.keyBuffer.deq.valid.expect(true.B)
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
}
