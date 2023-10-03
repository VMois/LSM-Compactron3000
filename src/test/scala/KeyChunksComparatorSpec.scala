package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class KeyChunksComparatorSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Different input combinations produce correct results" in {
        test(new KeyChunksComparator(busWidth = 4, n = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            val testCases = Seq(
                // in3, in2, in1, in0, maskIn, lastChunks, maskOut, expectedWinner, shouldLoadChunks
                // single winner, more chunks are available
                (0xD, 0xC, 0xB, 0xA, "b1111", "b0000", "b0001", true, 0),
                (0xD, 0xC, 0xA, 0xB, "b1111", "b0000", "b0010", true, 1),
                (0xD, 0xA, 0xC, 0xB, "b1111", "b0000", "b0100", true, 2),
                (0xA, 0xB, 0xD, 0xB, "b1111", "b0000", "b1000", true, 3),

                (0xD, 0xB, 0xC, 0xA, "b1100", "b0000", "b0100", true, 2),
                (0xD, 0xB, 0xA, 0xC, "b0111", "b0000", "b0010", true, 1),

                // single winner, some chunks are available
                (0xA, 0xA, 0xA, 0xA, "b1111", "b0100", "b0100", true, 2),
                (0xA, 0xA, 0xA, 0xA, "b1011", "b0001", "b0001", true, 0),

                // multiple winners, happens only when there are no more chunks available
                (0xB, 0xA, 0xA, 0xA, "b1111", "b1111", "b0111", true, 0),
                (0xB, 0xA, 0xA, 0xA, "b1011", "b0011", "b0011", true, 0),
                (0xA, 0xA, 0xA, 0xA, "b1111", "b1111", "b1111", true, 0),
                (0xC, 0xA, 0xA, 0xB, "b0110", "b0110", "b0110", true, 1),

                // should load new chunks
                (0xD, 0xC, 0xA, 0xA, "b1111", "b0000", "b0011", false, 0),
                (0xD, 0xA, 0xB, 0xA, "b1111", "b0000", "b0101", false, 0),
                (0xD, 0xA, 0xA, 0xA, "b1101", "b0000", "b0101", false, 0),
                (0xA, 0xA, 0xA, 0xA, "b1111", "b0000", "b1111", false, 0),
                (0xA, 0xA, 0xA, 0xA, "b1011", "b0100", "b1011", false, 0),
                (0xA, 0xB, 0xA, 0xC, "b1110", "b0100", "b1010", false, 1),
            )

            for ((in3, in2, in1, in0, maskIn, lastChunks, maskOut, expectedWinner, winnerIndex) <- testCases) {
                dut.io.in(0).poke(in0.U)
                dut.io.in(1).poke(in1.U)
                dut.io.in(2).poke(in2.U)
                dut.io.in(3).poke(in3.U)

                dut.io.lastChunksMask.poke(lastChunks.U)
                dut.io.maskIn.poke(maskIn.U)

                dut.io.maskOut.expect(maskOut.U)
                dut.io.haveWinner.expect(expectedWinner.B)
                dut.io.winnerIndex.expect(winnerIndex.U)
            }
        }
    }
}
