package compaction_unit

import chisel3._
import chisel3.util._


class MergerIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))

    val bufferInputSelect = Input(UInt(log2Ceil(numberOfBuffers).W))
    val lastInput = Input(Bool())

    val reset = Input(Bool())

    val isResultValid = Output(Bool())

    val haveWinner = Output(Bool())
    val winnerIndex = Output(UInt(log2Ceil(numberOfBuffers).W))

    val nextKvPairsToLoad = Output(Vec(numberOfBuffers, Bool()))
}


/** A class for Merger module
 * This module encapsulates KeyChunksComparator and provides a way to load new key chunks until winner is found.
 *
 * The module compares key chunks in alphabetical order, character by character (of a busWidth size).
 * Most significant characters need to be compared firts. 
 * For example, if busWidth is two chars and key is "ABCD".
 *   It needs to be split into "AB" and "CD".
 *   Where "A" and "C" parts are most significant in their respective chunks.
 *   This must also be reflected in their numerical values.
 *
 * nextKvPairsToLoad is a vector of booleans that indicates which buffers need to load new KV pair.
 * index of a buffer will map to a boolean value in the vector.
 *
 * Important: the results of comparison are valid only when isResultValid is true.
 * 
 * Important: the module expects that bufferIndex will be always incremented by 1.
 *            No buffer should be skipped. It is not efficient, but this is basic implementation.
 *
 * Important: after the winner is found, the module will not allow any changes to the inputs.
 *            It will keep returning the winning results and wait for reset signal.
 *            The outside module is responsible for resetting the Merger module.
 *
 *  @param busWidth, the number of bits .
 *  @param numberOfBuffers, how many buffers will be compared.
 */
class Merger(busWidth: Int, numberOfBuffers: Int) extends Module {
    assert (busWidth > 0, "Bus width must be greater than 0")
    assert (numberOfBuffers > 0, "numberOfBuffers must be greater than 0")

    val io = IO(new MergerIO(busWidth, numberOfBuffers))

    val keyChunks = Reg(Vec(numberOfBuffers, UInt(busWidth.W)))
    val lastKeyChunks = RegInit(VecInit(Seq.fill(numberOfBuffers)(false.B)))
    val haveWinner = RegInit(false.B)

    // default value for mask is all ones, which means that all buffers are included in the comparison
    val mask = RegInit(((1 << numberOfBuffers) - 1).U(numberOfBuffers.W))

    val isLastRowChunkLoaded = io.bufferInputSelect === (numberOfBuffers - 1).U

    val keyChunksComparator = Module(new KeyChunksComparator(busWidth, numberOfBuffers))
    keyChunksComparator.io.maskIn := mask

    // connecting inputs to combinational KeyChunksComparator module
    for (i <- 0 until numberOfBuffers) {
        // because register takes one cycle to save result,
        // we need to directly connect inputs for comparison
        if (i == numberOfBuffers - 1) {
            keyChunksComparator.io.in(i) := Mux(io.enq.valid && io.bufferInputSelect === i.U, io.enq.bits, keyChunks(i))
            keyChunksComparator.io.lastChunksMask(i) := Mux(io.enq.valid && io.bufferInputSelect === i.U, io.lastInput, lastKeyChunks(i))
        } else {
            keyChunksComparator.io.in(i) := keyChunks(i)
            keyChunksComparator.io.lastChunksMask(i) := lastKeyChunks(i)
        }
    }

    // If there is a winner, do not allow any changes
    when (io.enq.valid && ~haveWinner) {
        keyChunks(io.bufferInputSelect) := io.enq.bits

        // after last key chunk signal is observed for a buffer,
        // we do not allow any consecutive changes, it remains true.
        when (~lastKeyChunks(io.bufferInputSelect)) {
            lastKeyChunks(io.bufferInputSelect) := io.lastInput
        }
    }

    // If there is a winner, do not allow any changes
    when (isLastRowChunkLoaded && ~haveWinner) {
        mask := keyChunksComparator.io.maskOut
        haveWinner := io.haveWinner
    }

    when (io.reset) {
        mask := ((1 << numberOfBuffers) - 1).U(numberOfBuffers.W)
        haveWinner := false.B
    }

    io.isResultValid := Mux(haveWinner, true.B, isLastRowChunkLoaded)
    io.haveWinner := Mux(haveWinner, haveWinner, keyChunksComparator.io.haveWinner)
    io.nextKvPairsToLoad := keyChunksComparator.io.maskOut.asBools
    io.winnerIndex := keyChunksComparator.io.winnerIndex
    io.enq.ready := ~haveWinner
}
