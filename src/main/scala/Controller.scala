package compaction_unit

import chisel3._
import chisel3.util._


class ControllerControlIO extends Bundle {
    // TODO: consider adding reset signal
    val start = Input(Bool())
    val busy = Output(Bool())
}


class ControllerIO(numberOfBuffers: Int) extends Bundle {
    val control = new ControllerControlIO

    val decoders = Vec(numberOfBuffers, new Bundle {
        val lastSeen = Input(Bool())
        val readyToAccept = Output(Bool())
    })
    val inputBuffers = Vec(numberOfBuffers, new Bundle {
        val status = Flipped(new KvRingBufferStatusIO)
        val control = Flipped(new KvRingBufferControlIO)
    })
    val outputBuffer = Flipped(new KvRingBufferStatusIO)
    val kvTransfer = Flipped(new KvTransferControlIO(numberOfBuffers))
    val merger = Flipped(new MergerControlIO(numberOfBuffers))
    val encoder = Flipped(new EncoderControlIO)
}

class Controller(numberOfBuffers: Int) extends Module {
    val io = IO(new ControllerIO(numberOfBuffers))

    val idle :: fillBuffers :: setupComparison :: startComparison :: waitForComparison :: stopComparison :: startKvTransfer :: waitForKvTransfer :: movePointers :: waitForOutputBuffer :: Nil = Enum(10)

    val state = RegInit(idle)

    // default value for mask is all ones, which means that all buffers are included
    // at this point you cannot exclude certain buffers from outside
    val mask = RegInit(VecInit(Seq.fill(numberOfBuffers)(true.B)))

    val buffersStatus = Seq.fill(numberOfBuffers)(Wire(Bool()))
    for (i <- 0 until numberOfBuffers) {
        // Do buffers have enough data to start comparison?
        val dataFinishedButBufferNotEmpty = io.decoders(i).lastSeen && ~io.inputBuffers(i).status.empty
        buffersStatus(i) := io.inputBuffers(i).status.halfFull || (dataFinishedButBufferNotEmpty)

        // Update mask if buffer has no data and will not receive more
        mask(i) := ~(io.decoders(i).lastSeen && io.inputBuffers(i).status.empty)
    }

    val maskAsUInt = Cat(mask.reverse)
    val numberOfActiveBuffers = PopCount(mask)
    val onlyOneBufferActive = numberOfActiveBuffers === 1.U
    val noActiveBuffers = numberOfActiveBuffers === 0.U
    val buffersHaveData = (maskAsUInt & Cat(buffersStatus.reverse)) === maskAsUInt && ~noActiveBuffers
    val shouldSendLastDataSignal = (state === fillBuffers && noActiveBuffers && io.outputBuffer.empty) || (state === waitForOutputBuffer && io.outputBuffer.empty)

    switch (state) {
        is (idle) {
            when (io.control.start) {
                state := fillBuffers
            }
        }

        is (fillBuffers) {
            when (buffersHaveData) {
                when (onlyOneBufferActive) {
                    // only one buffer left, let's just transfer output to output buffer
                    state := startKvTransfer
                } .otherwise {
                    // two or more buffers left, let's start comparison
                    state := setupComparison
                }
            } .elsewhen(noActiveBuffers) {
                when (io.outputBuffer.empty) {
                    state := idle
                } .otherwise {
                    state := waitForOutputBuffer
                }
            }
        }

        is (setupComparison) {
            state := startComparison
        }

        is (startComparison) {
            state := waitForComparison
        }

        is (waitForComparison) {
            when (io.merger.haveWinner && io.merger.isResultValid) {
                state := stopComparison
            }
        }

        is (stopComparison) {
            state := startKvTransfer
        }

        is (startKvTransfer) {
            state := waitForKvTransfer
        }

        is (waitForKvTransfer) {
            when (~io.kvTransfer.busy) {
                state := movePointers
            }
        }

        is (movePointers) {
            state := fillBuffers
        }

        is (waitForOutputBuffer) {
            when (io.outputBuffer.empty) {
                state := idle
            }
        }
    }

    // Controller controls
    io.control.busy := state =/= idle

    // Encoder control
    io.encoder.lastDataIsProcessed := shouldSendLastDataSignal

    // Decoders outputs
    // TODO: do we need readyToAccept? If buffer is full, decoder will not send data anyway
    for (i <- 0 until numberOfBuffers) {
        // hardcoded for now, until decision is made about readyToAccept
        io.decoders(i).readyToAccept := true.B
    }

    // Input buffers
    for (i <- 0 until numberOfBuffers) {
        io.inputBuffers(i).control.moveReadPtr := state === movePointers && Mux(onlyOneBufferActive, mask(i), io.merger.nextKvPairsToLoad(i)) && ~io.inputBuffers(i).status.empty
        // KV Transfer does reset before operation, no need to do it here
        io.inputBuffers(i).control.resetRead <> DontCare
    }


    // KV Transfer outputs
    io.kvTransfer.mask := maskAsUInt
    io.kvTransfer.bufferInputSelect := Mux(onlyOneBufferActive, PriorityEncoder(mask), io.merger.winnerIndex)
    io.kvTransfer.stop := state === setupComparison || state === stopComparison
    when (state === startKvTransfer) {
        io.kvTransfer.command := KvTransferCommand.transferKvPair
    } .elsewhen (state === startComparison) {
        io.kvTransfer.command := KvTransferCommand.transferKeys
    } .otherwise {
        io.kvTransfer.command := KvTransferCommand.nop
    }

    // Merger
    io.merger.reset := state === startComparison
    io.merger.mask := maskAsUInt
}
