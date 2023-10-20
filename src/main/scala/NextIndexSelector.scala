package compaction_unit

import chisel3._
import chisel3.util._


/** A class for combinational NextIndexSelector
 * This module is used to select next index based on current index and mask.
 * More examples of how this module works can be found in the tests.
 *
 *  @param n, number of indexes.
 */
class NextIndexSelector(n: Int) extends Module {
    val io = IO(new Bundle {
        val mask = Input(UInt(n.W))
        val currentIndex = Input(UInt(log2Ceil(n).W))

        val nextIndex = Output(UInt(log2Ceil(n).W))
        val overflow = Output(Bool())
    })

    // Disable all indexes that are less than currentIndex
    val modifiedMask = Wire(Vec(n, Bool()))
    for (i <- 0 until n) {
        when (i.U <= io.currentIndex) {
            modifiedMask(i) := false.B
        }.otherwise {
            modifiedMask(i) := io.mask(i)
        }
    }

    // We do not have any indexes on the left side of currentIndex, use original mask
    when (Cat(modifiedMask).asUInt === 0.U) {
        io.nextIndex := PriorityEncoder(io.mask)
        io.overflow := true.B
    }.otherwise {
        io.nextIndex := PriorityEncoder(modifiedMask.asUInt)
        io.overflow := false.B
    }
}
