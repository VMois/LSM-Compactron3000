package compaction_unit

import chisel3._
import chisel3.util._


class KeyBufferIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    // Inputs from KV Transfer module
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val bufferInputSelect = Input(UInt(log2Ceil(numberOfBuffers).W))
    val incrWritePtr = Input(Bool())
    val lastInput = Input(Bool())

    // Control inputs from KV Transfer module
    val clearBuffer = Input(Bool())
    val mask = Input(UInt(numberOfBuffers.W))

    // Outputs to Merger module
    val deq = Decoupled(UInt(busWidth.W))
    val bufferOutputSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val empty = Output(Bool())
    val lastOutput = Output(Bool())
}


class KeyBuffer(busWidth: Int, numberOfBuffers: Int, maximumKeySize: Int) extends Module {
    assert (busWidth > 0, "Bus width must be greater than 0")
    assert (numberOfBuffers > 0, "numberOfBuffers must be greater than 0")
    assert (maximumKeySize > 0, "maximumKeySize width must be greater than 0")
    assert (maximumKeySize % busWidth == 0, "Key size must be a multiple of bus width")

    val io = IO(new KeyBufferIO(busWidth, numberOfBuffers))

    val depth = maximumKeySize / busWidth
    val memSize = depth * numberOfBuffers
    val mem = SyncReadMem(memSize, UInt(busWidth.W))

    def counter(depth: Int, incr: Bool): (UInt, UInt) = {
        val cntReg = RegInit(0.U(log2Ceil(depth).W))
        val nextVal = Mux(cntReg === (depth-1).U, 0.U, cntReg + 1.U)
        when (incr) {
            cntReg := nextVal
        }
        (cntReg, nextVal)
    }

    val incrRead = WireInit(false.B)
    val incrWrite = WireInit(false.B)
    val (readPtr, nextRead) = counter(depth, incrRead)
    val (writePtr, nextWrite) = counter(depth, incrWrite)

    val emptyReg = RegInit(true.B)
    val fullReg = RegInit(false.B)

    val idle :: valid :: waitForTransfer :: Nil = Enum(3)
    val stateReg = RegInit(idle)
    val shadowReg = RegInit(0.U(busWidth.W))

    val mask = RegInit(0.U(numberOfBuffers.W))
    val bufferOutputSelect = RegInit(0.U(log2Ceil(numberOfBuffers).W))

    val shouldIncreaseReadPtr = bufferOutputSelect === (numberOfBuffers-1).U

    val readFullPtr = readPtr * numberOfBuffers.U + bufferOutputSelect
    val writeFullPtr = writePtr * numberOfBuffers.U + io.bufferInputSelect

    val lastChunks = RegInit(VecInit(Seq.fill(numberOfBuffers)(false.B)))
    val lastChunkCounters = RegInit(VecInit(Seq.fill(numberOfBuffers)(0.U(log2Ceil(depth).W))))

    when (io.enq.valid && !fullReg && !io.clearBuffer) {
        mem.write(writeFullPtr, io.enq.bits)
        fullReg := nextWrite === readPtr && io.incrWritePtr

        // second condition, in theory, should never happen, but it is here just in case
        // it prevents the last chunk from being overwritten if it was already written  
        when (io.lastInput && !lastChunks(io.bufferInputSelect)) {
            lastChunks(io.bufferInputSelect) := true.B
            lastChunkCounters(io.bufferInputSelect) := writePtr
        }

        // row was loaded, next write will be applied to the next row
        when (io.incrWritePtr) {
            incrWrite := true.B
            emptyReg := false.B
        }
    }

    val nextIndexSelector = Module(new NextIndexSelector(numberOfBuffers))
    nextIndexSelector.io.mask := io.mask
    nextIndexSelector.io.currentIndex := bufferOutputSelect

    when (io.clearBuffer) {
        stateReg := idle
        emptyReg := true.B
        fullReg := false.B
        writePtr := 0.U
        readPtr := 0.U
        bufferOutputSelect := PriorityEncoder(io.mask)
        lastChunks.foreach(_ := false.B)
        lastChunkCounters.foreach(_ := 0.U)
    }

    val data = mem.read(readFullPtr)

    switch(stateReg) {
        is(idle) {
            when(!emptyReg && !io.clearBuffer) {
                stateReg := valid
                fullReg := false.B
                emptyReg := nextRead === writePtr && shouldIncreaseReadPtr && !io.incrWritePtr
                // prepare for the next read, as it requires one cycle delay
                bufferOutputSelect := nextIndexSelector.io.nextIndex
            }
        }
        is(valid) {
            when (!io.clearBuffer) {
                when(io.deq.ready) {
                    when(!emptyReg) {
                        stateReg := valid
                        fullReg := false.B
                        emptyReg := nextRead === writePtr && shouldIncreaseReadPtr && !io.incrWritePtr
                        incrRead := shouldIncreaseReadPtr
                        bufferOutputSelect := nextIndexSelector.io.nextIndex
                    } otherwise {
                        bufferOutputSelect := nextIndexSelector.io.nextIndex
                        stateReg := idle
                    }
                } otherwise {
                    shadowReg := data
                    stateReg := waitForTransfer
                }
            }
        }
        is(waitForTransfer) {
            when (!io.clearBuffer) {
                when(io.deq.ready) {
                    when(!emptyReg) {
                        stateReg := valid
                        fullReg := false.B
                        emptyReg := nextRead === writePtr && shouldIncreaseReadPtr && !io.incrWritePtr
                        incrRead := shouldIncreaseReadPtr
                        bufferOutputSelect := nextIndexSelector.io.nextIndex
                    } otherwise {
                        bufferOutputSelect := nextIndexSelector.io.nextIndex
                        stateReg := idle
                    }
                }
            }
        }
    }

    // the "bufferOutputSelect" reg contains the value from the current cycle
    // but the valid output data is from previous cycle, hence substract 1.
    io.bufferOutputSelect := bufferOutputSelect - 1.U

    io.deq.bits := Mux(stateReg === valid, data, shadowReg)

    // because readPtr during the last cycle of row read already points to the next row, 
    // we need a Mux to substract 1 in a right place.
    val currentReadPtr = Mux(io.bufferOutputSelect === (numberOfBuffers - 1).U, readPtr - 1.U, readPtr)

    // besides being in valid state, we should only output valid = True if the current chunk was never last chunk before
    // for this we check in lastChunks if current buffer had a last chunk before;
    // if it did, we check if we are past the last chunk; 
    // if we are past the last chunk for this buffer, it means we are reading garbage and should output valid = False.
    // this is important for consistency. The output data should always be correct if valid = True.
    io.deq.valid := (stateReg === valid || stateReg === waitForTransfer) && Mux(lastChunks(io.bufferOutputSelect), lastChunkCounters(io.bufferOutputSelect) >= currentReadPtr, true.B)

    io.lastOutput := lastChunks(io.bufferOutputSelect) && lastChunkCounters(io.bufferOutputSelect) === currentReadPtr

    // both enq and clearBuffer are driven by the same module, otherwise, it creates unpredictable behavior
    io.enq.ready := !fullReg && ~io.clearBuffer

    io.empty := emptyReg
}

object KeyBufferMain extends App {
  println("Generating the Key Buffer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KeyBuffer(4, 4, 8), Array("--target-dir", "generated"))
}
