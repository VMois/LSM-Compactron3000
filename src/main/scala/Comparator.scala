package compaction_unit

import chisel3._
import chisel3.util._


/** A class for priority Comparator. 
 * The module takes a list of numbers and returns index of the smallest number. 
 * If two numbers are equal, the one with lower index gets returned.
 *
 *  @param busWidth, the number of bits that each number has.
 *  @param n, how many numbers will be compared.
 */
class Comparator(busWidth: Int = 4, n: Int = 4) extends Module {
    val io = IO(new Bundle {
        val in = Input(Vec(n, UInt(busWidth.W)))
        val out = Output(UInt(log2Ceil(n).W))
    })

    val indexesArray = VecInit(Seq.tabulate(n)(i => i.U(log2Ceil(n).W)))

    io.out := indexesArray.reduce { (indexA, indexB) =>
        Mux(io.in(indexA) <= io.in(indexB), indexA, indexB)
    }
}
