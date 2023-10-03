package compaction_unit

import chisel3._
import chisel3.util._


/** A class for combinational Key Chunks Comparator
 * This module is used to compare key chunks and decide whatever more chunks should be loaded or there is a winner.
 * "mastIn" is mask that indicates which inputs should be included in the comparison.
 * "maskOut" is an updated mask that needs to be passed for the next comparison.
 * 
 * Note: "maskOut" can be used to determine which chunks to load from memory in the next round.
 *       Because only those chunks will be needed for comparison.
 *
 * More details about how this module works can be found in the tests.
 *
 *  @param busWidth, the number of bits that each number has.
 *  @param n, how many numbers will be compared.
 */
class KeyChunksComparator(busWidth: Int = 4, n: Int = 4) extends Module {
    val io = IO(new Bundle {
        val in = Input(Vec(n, UInt(busWidth.W)))
        val maskIn = Input(UInt(n.W))
        val lastChunksMask = Input(Vec(n, Bool()))

        val maskOut = Output(UInt(n.W))
        val haveWinner = Output(Bool())
        val winnerIndex = Output(UInt(log2Ceil(n).W))
    })
    // 1. Apply mask to inputs to include/exclude certain inputs from the comparison based on maskIn value.
    val modifiedInputs = Wire(Vec(n, UInt((busWidth + 1).W)))

    io.in.zipWithIndex.map { case (input, index) =>
        modifiedInputs(index) := Mux(io.maskIn(index) === 1.U, "b0".U ## input, "b1".U ## input)
    }

    // 2. Get the index of a smallest key chunk
    val smallestIndex = Wire(UInt(log2Ceil(n).W))
    val indexesArray = VecInit(Seq.tabulate(n)(i => i.U(log2Ceil(n).W)))

    smallestIndex := indexesArray.reduce { (indexA, indexB) =>
        Mux(modifiedInputs(indexA) <= modifiedInputs(indexB), indexA, indexB)
    }

    // 3. Compare all inputs with a smallest key chunk
    val equalityMask = Wire(Vec(n, Bool()))

    for (i <- 0 until n) {
        equalityMask(i) := Mux(modifiedInputs(smallestIndex) === modifiedInputs(i), true.B, false.B)
    }

    // 4. If there is only one input that is equal to a smallest key chunk, then we have a winner.
    // TODO: how efficient is PopCount?
    val countOnes = PopCount(equalityMask.asUInt)
    val hasOnlyOneOne = countOnes === 1.U

    // 5. If there more than one input that is equal to a smallest key chunk
    //    then we need to check if there are more chunks available for those inputs.
    // 6. If some chunks (equal to smallest key chunk) do not have more chunks available,
    //    then those chunks will be considered as a winner because they are the shortest.
    val andResult = equalityMask.asUInt & io.lastChunksMask.asUInt
    val andResultEqualsZero = andResult === 0.U

    io.maskOut := Mux(hasOnlyOneOne || andResultEqualsZero, equalityMask.asUInt, andResult)
    io.haveWinner := hasOnlyOneOne || ~andResultEqualsZero

    // 7. The index of a winner is a position of the first least-significant "1" in maskOut
    io.winnerIndex := PriorityEncoder(io.maskOut)
}
