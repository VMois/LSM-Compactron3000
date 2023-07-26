package compaction_unit

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._


class ComparatorSpec extends AnyFreeSpec with ChiselScalatestTester {
    "Should return a correct index" in {
        test(new Comparator(4, 4)) { dut =>
            val testCases = Seq(
                (1, 2, 3, 4, 0), // Smallest value at index 0
                (3, 2, 4, 5, 1), // Smallest value at index 1
                (5, 4, 3, 6, 2), // Smallest value at index 2
                (9, 8, 7, 6, 3), // Smallest value at index 3
                (7, 7, 7, 7, 0), // Smallest value at index 0 (prioritize lower index in case of equal values)
                (8, 7, 7, 9, 1)  // Smallest value at index 1
            )

            for ((in0, in1, in2, in3, expected) <- testCases) {
                dut.io.in(0).poke(in0.U)
                dut.io.in(1).poke(in1.U)
                dut.io.in(2).poke(in2.U)
                dut.io.in(3).poke(in3.U)
                dut.clock.step()
                dut.io.out.expect(expected.U)
            }
        }
    }
}
