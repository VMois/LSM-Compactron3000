package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KvRingBufferSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should be empty when constructed" in {
        test(new KVRingBuffer(4)) { dut =>
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should be not ready when full" in {
        test(new KVRingBuffer(2, busWidth = 4, keySize = 8, valueSize = 8, metadataSize = 8)) { dut =>
            // Default values for all signals
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.isInputKey.poke(false.B)
            dut.io.full.expect(false.B)
            dut.clock.step()

            // Write KV pair 1
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()
            dut.io.enq.valid.poke(false.B)

            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }

            // Write KV pair 2
            dut.io.enq.bits.poke(0xB.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step(3) // wait for metadata to write

            dut.io.full.expect(true.B)
            dut.io.empty.expect(false.B)
            dut.io.enq.ready.expect(false.B)
        }
    }

    "Should put a single KV value and read it back" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // Default values for all signals
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.isInputKey.poke(false.B)
            dut.clock.step()

            // Write a key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0xB.U)
            dut.clock.step()

            // Write a value
            dut.io.isInputKey.poke(false.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xE.U)
            dut.io.lastInput.poke(true.B)
            dut.clock.step()

            // Wait for KV data to be written to memory
            dut.io.enq.valid.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.clock.step(2)
            dut.io.empty.expect(false.B)
            dut.io.enq.ready.expect(true.B)

            // delay to read metadata
            dut.clock.step(2)
            
            dut.io.enq.ready.expect(true.B)
            
            // Start reading KV pair
            dut.io.deq.ready.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xB.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xC.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xD.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xE.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should read only key" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // Default values for all signals
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.isInputKey.poke(false.B)
            dut.clock.step()

            // Write a key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0xB.U)
            dut.clock.step()

            // Write a value
            dut.io.isInputKey.poke(false.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xE.U)
            dut.io.lastInput.poke(true.B)
            dut.clock.step()

            // Wait for KV data to be written to memory
            dut.io.enq.valid.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.ready.expect(false.B)

            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }
            
            // Start reading key only
            dut.io.deq.ready.poke(true.B)
            dut.io.outputKeyOnly.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should write two KV pairs and read one back" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // Default values for all signals
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.isInputKey.poke(false.B)
            dut.io.outputKeyOnly.poke(false.B)
            dut.clock.step()

            // Write KV pair 1
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()
            dut.io.enq.valid.poke(false.B)

            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }

            // Write KV pair 2
            dut.io.enq.bits.poke(0xB.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step()
            dut.io.enq.valid.poke(false.B)

            // Start reading KV pair
            dut.io.deq.ready.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xC.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(false.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should move to read the next KV pair" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // Default values for all signals
            dut.io.enq.bits.poke(0.U)
            dut.io.enq.valid.poke(false.B)
            dut.io.deq.ready.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.isInputKey.poke(false.B)
            dut.io.outputKeyOnly.poke(false.B)
            dut.clock.step()

            // Write KV pair 1
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()
            dut.io.enq.valid.poke(false.B)

            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }

            // Write KV pair 2
            dut.io.enq.bits.poke(0xB.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step()

            dut.io.moveReadPtr.poke(true.B)
            dut.clock.step()
            dut.io.moveReadPtr.poke(false.B)

            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.ready.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xD.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()
            dut.io.deq.valid.expect(false.B)
        }
    }
}
