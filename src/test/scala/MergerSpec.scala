package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


case class TestInput(value: Int, lastInput: Boolean)


class MergerSpec extends AnyFreeSpec with ChiselScalatestTester {
    "One buffer wins and advances" in {
        test(new Merger(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // reset Merger for a new comparison round
            dut.io.control.reset.poke(true.B)
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()
            dut.io.control.reset.poke(false.B)

            // buffer 0 and 2 are equal, we do not care about buffer 1 and 3
            val firstRow = List[TestInput](
                TestInput(0xA, false),
                TestInput(0xB, false),
                TestInput(0xA, false),
                TestInput(0xD, false),
            )

            for ((input, i) <- firstRow.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            // buffer 0 and 2 are still equal
            val secondRow = List[TestInput](
                TestInput(0xA, false),
                TestInput(0xA, true),
                TestInput(0xA, false),
                TestInput(0xA, false),
            )

            for ((input, i) <- secondRow.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            // buffer 2 should win
            val thirdRow = List[TestInput](
                TestInput(0xB, true),
                TestInput(0xA, false),
                TestInput(0xA, false),
                TestInput(0xA, false),
            )

            for ((input, i) <- thirdRow.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)
                dut.clock.step()
            }

            dut.io.enq.ready.expect(false.B)
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(2.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(false.B)
            dut.io.control.nextKvPairsToLoad(2).expect(true.B)
            dut.io.control.nextKvPairsToLoad(3).expect(false.B)
            dut.clock.step()

            // Output winning results until module is reset
            dut.io.enq.ready.expect(false.B)
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(2.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(false.B)
            dut.io.control.nextKvPairsToLoad(2).expect(true.B)
            dut.io.control.nextKvPairsToLoad(3).expect(false.B)
        }
    }

    "Some buffers are equal, both advance" in {
        test(new Merger(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // reset Merger for a new comparison round
            dut.io.control.reset.poke(true.B)
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()
            dut.io.control.reset.poke(false.B)
            
            // buffers 1 and 3 are equal, we ignore buffers 0 and 2
            val firstRow = List[TestInput](
                TestInput(0xB, false),
                TestInput(0xA, false),
                TestInput(0xD, false),
                TestInput(0xA, false),
            )

            for ((input, i) <- firstRow.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            // buffer 1 and 3 are still equal
            val secondRow = List[TestInput](
                TestInput(0xA, true),
                TestInput(0xA, false),
                TestInput(0xA, true),
                TestInput(0xA, false),
            )

            for ((input, i) <- secondRow.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            // buffer 1 and 3 should advance, buffer 1 wins
            val thirdRow = List[TestInput](
                TestInput(0xB, false),
                TestInput(0xA, true),
                TestInput(0xA, false),
                TestInput(0xA, true),
            )

            for ((input, i) <- thirdRow.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)
                dut.clock.step()
            }
            
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(1.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(true.B)
            dut.io.control.nextKvPairsToLoad(2).expect(false.B)
            dut.io.control.nextKvPairsToLoad(3).expect(true.B)

        }
    }

    "Works correctly after having a winner and starting a new comparison round" in {
        test(new Merger(busWidth = 4, numberOfBuffers = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            // reset Merger for a new comparison round
            dut.io.control.reset.poke(true.B)
            dut.io.control.mask.poke("b1111".U)
            dut.clock.step()
            dut.io.control.reset.poke(false.B)
            
            val firstRow1stRound = List[TestInput](
                TestInput(0xB, false),
                TestInput(0xC, false),
                TestInput(0xA, false),
                TestInput(0xA, false),
            )

            for ((input, i) <- firstRow1stRound.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            val secondRow1stRound = List[TestInput](
                TestInput(0x0, false),
                TestInput(0x0, false),
                TestInput(0xA, true),
                TestInput(0xA, false),
            )

            for ((input, i) <- secondRow1stRound.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            dut.io.enq.ready.expect(false.B)
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(2.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(false.B)
            dut.io.control.nextKvPairsToLoad(2).expect(true.B)
            dut.io.control.nextKvPairsToLoad(3).expect(false.B)
            dut.clock.step()

            dut.io.enq.valid.poke(false.B)
            dut.io.enq.ready.expect(false.B)
            dut.io.control.isResultValid.expect(true.B)
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(2.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(false.B)
            dut.io.control.nextKvPairsToLoad(2).expect(true.B)
            dut.io.control.nextKvPairsToLoad(3).expect(false.B)

            // reset Merger module for a new comparison round
            dut.io.control.reset.poke(true.B)
            dut.clock.step()
            dut.io.control.reset.poke(false.B)

            // start a new comparison round
            val firstRow2ndRound = List[TestInput](
                TestInput(0xA, false),
                TestInput(0xA, false),
                TestInput(0xD, false),
                TestInput(0xC, false),
            )

            for ((input, i) <- firstRow2ndRound.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)

                dut.clock.step()
            }

            val secondRow2ndRound = List[TestInput](
                TestInput(0xB, false),
                TestInput(0xA, false),
                TestInput(0xA, false),
                TestInput(0xA, false),
            )

            for ((input, i) <- secondRow2ndRound.zipWithIndex) {
                dut.io.enq.ready.expect(true.B)
                dut.io.enq.valid.poke(true.B)
                dut.io.enq.bits.poke(input.value.U)
                dut.io.bufferInputSelect.poke(i.U)
                dut.io.lastInput.poke(input.lastInput.B)

                dut.io.control.haveWinner.expect(false.B)
                dut.clock.step()
            }

            dut.io.enq.ready.expect(false.B)
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(1.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(true.B)
            dut.io.control.nextKvPairsToLoad(2).expect(false.B)
            dut.io.control.nextKvPairsToLoad(3).expect(false.B)

            dut.clock.step()

            dut.io.enq.ready.expect(false.B)
            dut.io.control.isResultValid.expect(true.B)
            dut.io.control.haveWinner.expect(true.B)
            dut.io.control.winnerIndex.expect(1.U)
            dut.io.control.nextKvPairsToLoad(0).expect(false.B)
            dut.io.control.nextKvPairsToLoad(1).expect(true.B)
            dut.io.control.nextKvPairsToLoad(2).expect(false.B)
            dut.io.control.nextKvPairsToLoad(3).expect(false.B)
        }
    }
}
