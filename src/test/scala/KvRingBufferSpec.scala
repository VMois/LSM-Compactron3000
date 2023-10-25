package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KvRingBufferSpec extends AnyFreeSpec with ChiselScalatestTester {

    val setDefaultValues = (dut: KVRingBuffer) => {
        dut.io.enq.bits.poke(0.U)
        dut.io.enq.valid.poke(false.B)
        dut.io.deq.ready.poke(false.B)
        dut.io.lastInput.poke(false.B)
        dut.io.isInputKey.poke(false.B)
        dut.io.outputKeyOnly.poke(false.B)
        dut.io.moveReadPtr.poke(false.B)
    }

    "Check default output values" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 8, valueSize = 8, metadataSize = 8)) { dut =>
            setDefaultValues(dut)
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should be not ready when full" in {
        test(new KVRingBuffer(2, busWidth = 4, keySize = 8, valueSize = 8, metadataSize = 8)) { dut =>
            setDefaultValues(dut)
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
            setDefaultValues(dut)
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

            dut.io.enq.valid.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.ready.expect(false.B)

            // wait for metadata to be ready
            while (dut.io.metadataValid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.empty.expect(false.B)

            // read key len
            dut.io.deq.bits.expect(2.U)
            dut.io.deq.valid.expect(false.B)
            dut.io.metadataValid.expect(true.B)
            dut.clock.step()

            // read value len
            dut.io.deq.bits.expect(3.U)
            dut.io.deq.valid.expect(false.B)
            dut.io.metadataValid.expect(true.B)
            dut.clock.step()
            
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
            setDefaultValues(dut)
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
            setDefaultValues(dut)
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

    "Should write two KV pairs and read two back" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8, autoReadNextPair = true)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            setDefaultValues(dut)
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

            // Start reading KV pairs
            dut.io.deq.ready.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }
            
            // Read first KV pair
            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xC.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            // Read second KV pair
            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xD.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should move to read the next KV pair" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            setDefaultValues(dut)
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

    "Should wait until 'ready' asserted to provide next Key chunk" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            setDefaultValues(dut)
            dut.clock.step()

            // Write KV pair
            // Write key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0xB.U)
            dut.clock.step()

            // Write value
            dut.io.isInputKey.poke(false.B)
            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()
            dut.io.enq.valid.poke(false.B)

            // Reading key with delay
            dut.io.deq.ready.poke(false.B)
            dut.io.outputKeyOnly.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.ready.poke(true.B)
            dut.clock.step()

            dut.io.deq.ready.poke(false.B)
            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.ready.poke(true.B)

            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should wait until 'ready' asserted to provide next Key or Value chunk" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            setDefaultValues(dut)
            dut.clock.step()

            // Write KV pair
            // Write key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0xB.U)
            dut.clock.step()

            // Write value
            dut.io.isInputKey.poke(false.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step()

            dut.io.lastInput.poke(true.B)
            dut.io.enq.bits.poke(0xE.U)
            dut.clock.step()

            dut.io.lastInput.poke(false.B)
            dut.io.enq.valid.poke(false.B)

            // Reading KV pair with delay
            dut.io.deq.ready.poke(false.B)
            dut.io.outputKeyOnly.poke(false.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.ready.poke(true.B)
            dut.clock.step()

            dut.io.deq.ready.poke(false.B)
            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.ready.poke(true.B)
            dut.clock.step()

            // Check if first value chunk is kept until 'ready' asserted
            dut.io.deq.ready.poke(false.B)
            dut.io.deq.bits.expect(0xC.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xC.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xC.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.ready.poke(true.B)  
            dut.clock.step()

            // Check if second value chunk is kept until 'ready' asserted
            dut.io.deq.ready.poke(false.B)
            dut.io.deq.bits.expect(0xD.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xD.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.ready.poke(true.B)
            dut.io.deq.bits.expect(0xD.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            // Check if third value chunk is kept until 'ready' asserted
            dut.io.deq.ready.poke(false.B)
            dut.io.deq.bits.expect(0xE.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xE.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()

            dut.io.deq.ready.poke(true.B)
            dut.io.deq.bits.expect(0xE.U)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.io.deq.valid.expect(true.B)
            dut.clock.step()
            
            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should move read pointer when requested" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            setDefaultValues(dut)
            dut.clock.step()

            // Write a first key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0xB.U)
            dut.clock.step()

            // Write a first value
            dut.io.isInputKey.poke(false.B)
            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xD.U)
            dut.io.lastInput.poke(true.B)
            dut.clock.step()

            // Wait for KV pair to be written
            dut.io.enq.valid.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.empty.expect(true.B)
            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }
            dut.io.empty.expect(false.B)

            // Write a second key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0x2.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0x3.U)
            dut.clock.step()

            // Write a second value
            dut.io.isInputKey.poke(false.B)
            dut.io.enq.bits.poke(0x6.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0x7.U)
            dut.io.lastInput.poke(true.B)
            dut.clock.step()

            dut.io.lastInput.poke(false.B)
            
            // Start reading first KV pair
            dut.io.deq.ready.poke(true.B)

            while (dut.io.deq.valid.peek().litToBoolean == false) {
                dut.clock.step()
            }

            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            // Move read pointer to the second KV pair
            dut.io.moveReadPtr.poke(true.B)
            dut.clock.step()

            // buffer reads metadata for the second KV pair, need to wait
            dut.io.moveReadPtr.poke(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step(3)

            // Read second key
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0x2.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0x3.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            // Read second value
            dut.io.deq.bits.expect(0x6.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0x7.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()
            
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }

    "Should reset reading to the beginning of KV pair when requested" in {
        test(new KVRingBuffer(4, busWidth = 4, keySize = 12, valueSize = 12, metadataSize = 8)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            setDefaultValues(dut)
            dut.clock.step()

            // Write a key
            dut.io.enq.ready.expect(true.B)
            dut.io.enq.bits.poke(0xA.U)
            dut.io.enq.valid.poke(true.B)
            dut.io.isInputKey.poke(true.B)
            dut.clock.step()

            dut.io.enq.bits.poke(0xB.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xC.U)
            dut.clock.step()

            // Write a value
            dut.io.isInputKey.poke(false.B)
            dut.io.enq.bits.poke(0xD.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xE.U)
            dut.clock.step()

            dut.io.enq.bits.poke(0xF.U)
            dut.io.lastInput.poke(true.B)
            dut.clock.step()

            // Wait for KV pair to be written
            dut.io.enq.valid.poke(false.B)
            dut.io.lastInput.poke(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.empty.expect(true.B)
            while (dut.io.enq.ready.peek().litToBoolean == false) {
                dut.clock.step()
            }
            dut.io.empty.expect(false.B)
            
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
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)

            // Start reading from the beginning of KV pair
            dut.io.resetRead.poke(true.B)
            dut.clock.step()

            // buffer reads metadata for KV pair, need to wait
            dut.io.resetRead.poke(false.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.valid.expect(false.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step(3)

            // Read key
            dut.io.deq.valid.expect(true.B)
            dut.io.deq.bits.expect(0xA.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xB.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xC.U)
            dut.io.isOutputKey.expect(true.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            // Read value
            dut.io.deq.bits.expect(0xD.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xE.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(false.B)
            dut.clock.step()

            dut.io.deq.bits.expect(0xF.U)
            dut.io.deq.valid.expect(true.B)
            dut.io.isOutputKey.expect(false.B)
            dut.io.lastOutput.expect(true.B)
            dut.clock.step()
            
            dut.io.enq.ready.expect(true.B)
            dut.io.deq.valid.expect(false.B)
            dut.io.empty.expect(true.B)
            dut.io.full.expect(false.B)
        }
    }
}
