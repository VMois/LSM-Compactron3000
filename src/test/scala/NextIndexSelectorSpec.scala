package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class NextIndexSelectorSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Different inputs produce correct outputs" in {
        test(new NextIndexSelector(n = 4)).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
            val testCases = Seq(
                // mask, currentIndex, nextIndex, overflow
                ("b1111", 0, 1, false),
                ("b1111", 1, 2, false),
                ("b1111", 2, 3, false),
                ("b1111", 3, 0, true),

                ("b1001", 0, 3, false),
                ("b0100", 2, 2, true),
                ("b1000", 3, 3, true),
                ("b0110", 2, 1, true),
                ("b0110", 1, 2, false),
                
                // If mask is there, the last index is always selected
                ("b0000", 0, 3, true),
                ("b0000", 1, 3, true),
                ("b0000", 2, 3, true),
                ("b0000", 3, 3, true),
            )

            for ((mask, currentIndex, nextIndex, overflow) <- testCases) {
                dut.io.mask.poke(mask.U)
                dut.io.currentIndex.poke(currentIndex.U)
                dut.io.nextIndex.expect(nextIndex.U)
                dut.io.overflow.expect(overflow.B)
            }
        }
    }
}
