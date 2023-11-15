package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class ControllerSpec extends AnyFreeSpec with ChiselScalatestTester {
    val setDefaultValues = (dut: Controller, numberOfBuffers: Int) => {
        // Decoders
        for (i <- 0 until numberOfBuffers) {
            dut.io.decoders(i).lastSeen.poke(false.B)
        }

        // Buffers
        for (i <- 0 until numberOfBuffers) {
            dut.io.inputBuffers(i).status.empty.poke(true.B)
            dut.io.inputBuffers(i).status.halfFull.poke(false.B)
            dut.io.inputBuffers(i).status.full.poke(false.B)
        }

        // KV Transfer
        dut.io.kvTransfer.busy.poke(false.B)

        // Output buffer
        dut.io.outputBuffer.empty.poke(true.B)
        dut.io.outputBuffer.full.poke(false.B)

        // Merger
        dut.io.merger.haveWinner.poke(false.B)
        dut.io.merger.isResultValid.poke(false.B)
        dut.io.merger.winnerIndex.poke(0.U)

        for (i <- 0 until numberOfBuffers) {
            dut.io.merger.nextKvPairsToLoad(i).poke(false.B)
        }
    }

    val buffersControlsCheck = (dut: Controller, numberOfBuffers: Int, moveReadPtrExpect: Boolean) => {
        for (i <- 0 until numberOfBuffers) {
            dut.io.inputBuffers(i).control.moveReadPtr.expect(moveReadPtrExpect.B)
            dut.io.inputBuffers(i).control.resetRead.expect(false.B)
        }
    }

    "Should correctly control modules from beginning to the end" in {
        test(new Controller(numberOfBuffers = 2)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            val numberOfBuffers = 2
            setDefaultValues(dut, numberOfBuffers)
            
            // 1. Controller should be in idle state
            dut.io.control.busy.expect(false.B)
            
            for (i <- 0 until numberOfBuffers) {
                dut.io.decoders(i).readyToAccept.expect(true.B)
            }

            buffersControlsCheck(dut, 2, false)

            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.command.expect(KvTransferCommand.nop)

            // 2. Controller receives command from outside that input is coming
            dut.io.control.start.poke(true.B)
            dut.clock.step()
            dut.io.control.start.poke(false.B)
            dut.io.control.busy.expect(true.B)
            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.command.expect(KvTransferCommand.nop)
            buffersControlsCheck(dut, 2, false)

            // 3. Fill buffers
            dut.clock.step(3)

            // 3.1 Buffers have some data but not yet halfFull
            for (i <- 0 until numberOfBuffers) {
                dut.io.inputBuffers(i).status.empty.poke(false.B)
                dut.io.inputBuffers(i).status.empty.poke(false.B)
            }

            for (i <- 0 until numberOfBuffers) {
                dut.io.inputBuffers(i).control.moveReadPtr.expect(false.B)
                dut.io.inputBuffers(i).control.resetRead.expect(false.B)
            }
            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.command.expect(KvTransferCommand.nop)
            buffersControlsCheck(dut, 2, false)

            dut.clock.step(4)

            // 3.2 Second buffer is halfFull but the first one is not
            dut.io.inputBuffers(1).status.halfFull.poke(true.B)
            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.command.expect(KvTransferCommand.nop)
            buffersControlsCheck(dut, 2, false)

            dut.clock.step(1)

            // 3.3 First buffer is halfFull
            dut.io.inputBuffers(0).status.halfFull.poke(true.B)
            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.command.expect(KvTransferCommand.nop)
            buffersControlsCheck(dut, 2, false)

            dut.clock.step()

            // 4. Keys comparison

            // 4.1 Setup comparison
            dut.io.kvTransfer.stop.expect(true.B)
            buffersControlsCheck(dut, 2, false)
            dut.clock.step()

            // 4.2 Start comparison
            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.mask.expect("b11".U)
            dut.io.kvTransfer.command.expect(KvTransferCommand.transferKeys)
            dut.io.merger.reset.expect(true.B)
            buffersControlsCheck(dut, 2, false)
            dut.clock.step()
            dut.io.kvTransfer.busy.poke(true.B)
            dut.io.merger.reset.expect(false.B)
            buffersControlsCheck(dut, 2, false)

            // 4.3 Wait for comparison
            dut.clock.step(5)
            dut.io.merger.haveWinner.poke(true.B)
            dut.io.merger.isResultValid.poke(true.B)
            // 4.3.1 Winner is a first buffer
            dut.io.merger.winnerIndex.poke(0.U)
            dut.io.merger.nextKvPairsToLoad(0).poke(true.B)
            dut.io.merger.nextKvPairsToLoad(1).poke(false.B)
            dut.clock.step()

            // 4.4 Stop comparison
            dut.io.kvTransfer.stop.expect(true.B)
            dut.io.merger.haveWinner.poke(true.B)
            dut.io.merger.isResultValid.poke(true.B)
            dut.io.kvTransfer.busy.poke(true.B)
            buffersControlsCheck(dut, 2, false)
            dut.clock.step()
            dut.io.kvTransfer.stop.expect(false.B)
            dut.io.kvTransfer.busy.poke(false.B)

            // 5. Transfer KV pair

            // 5.1 Start transfer
            dut.io.kvTransfer.mask.expect("b11".U)
            dut.io.kvTransfer.bufferInputSelect.expect(0.U)
            dut.io.kvTransfer.command.expect(KvTransferCommand.transferKvPair)
            buffersControlsCheck(dut, 2, false)
            dut.clock.step()
            dut.io.kvTransfer.busy.poke(true.B)

            // 5.2 Wait for transfer to happen
            dut.clock.step(3)
            dut.io.outputBuffer.empty.poke(false.B)
            dut.clock.step(2)
            dut.io.kvTransfer.busy.poke(false.B)
            dut.clock.step()

            // 6. Move pointers
            dut.io.inputBuffers(0).control.moveReadPtr.expect(true.B)
            dut.io.inputBuffers(1).control.moveReadPtr.expect(false.B)
            dut.clock.step()
            dut.io.inputBuffers(0).control.moveReadPtr.expect(false.B)
            dut.io.inputBuffers(1).control.moveReadPtr.expect(false.B)
            dut.io.inputBuffers(0).status.halfFull.poke(false.B)
            dut.io.inputBuffers(0).status.empty.poke(true.B)
            dut.io.decoders(0).lastSeen.poke(true.B)

            // 7. Only one active buffer
            dut.clock.step()

            // 8. Transfer remaining KV pairs from buffer
            dut.clock.step()

            // 8.1 Start transfer
            dut.io.kvTransfer.mask.expect("b10".U)
            dut.io.kvTransfer.bufferInputSelect.expect(1.U)
            dut.io.kvTransfer.command.expect(KvTransferCommand.transferKvPair)
            buffersControlsCheck(dut, 2, false)
            dut.clock.step()
            dut.io.kvTransfer.busy.poke(true.B)

            // 8.2 Wait for transfer to happen
            dut.clock.step(3)
            dut.io.outputBuffer.empty.poke(false.B)
            dut.clock.step(2)
            dut.io.kvTransfer.busy.poke(false.B)
            dut.clock.step()

            // 9. Move pointers
            dut.io.inputBuffers(0).control.moveReadPtr.expect(false.B)
            dut.io.inputBuffers(1).control.moveReadPtr.expect(true.B)
            dut.clock.step()
            dut.io.inputBuffers(0).control.moveReadPtr.expect(false.B)
            dut.io.inputBuffers(1).control.moveReadPtr.expect(false.B)
            dut.io.inputBuffers(1).status.halfFull.poke(false.B)
            dut.io.inputBuffers(1).status.empty.poke(true.B)
            dut.io.decoders(1).lastSeen.poke(true.B)

            // 10. Transfer data out of output buffer
            dut.clock.step(2)
            dut.io.outputBuffer.empty.poke(true.B)
            dut.io.control.busy.expect(true.B)
            dut.clock.step()
            dut.io.control.busy.expect(false.B)

            dut.clock.step()
            dut.io.control.busy.expect(false.B)

        }
    }
}
