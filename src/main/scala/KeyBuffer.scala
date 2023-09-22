package compaction_unit

import chisel3._
import chisel3.util._


class KeyBufferIO(busWidth: Int, numberOfBuffers: Int) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val deq = Decoupled(UInt(busWidth.W))

    val bufferInputSelect = Input(UInt(log2Ceil(numberOfBuffers).W))
    val incrWritePtr = Input(Bool())
    val clearBuffer = Input(Bool())

    val bufferOutputSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val empty = Output(Bool())
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

    val bufferOutputSelect = RegInit(0.U(log2Ceil(numberOfBuffers).W))

    val shouldIncreaseReadPtr = bufferOutputSelect === (numberOfBuffers-1).U

    val readFullPtr = readPtr * numberOfBuffers.U + bufferOutputSelect
    val writeFullPtr = writePtr * numberOfBuffers.U + io.bufferInputSelect

    when (io.enq.valid && !fullReg && !io.clearBuffer) {
        mem.write(writeFullPtr, io.enq.bits)
        fullReg := nextWrite === readPtr && io.incrWritePtr

        // row was loaded, next write will be applied to the next row
        when (io.incrWritePtr) {
            incrWrite := true.B
            emptyReg := false.B
        }
    }

    when (io.clearBuffer) {
        stateReg := idle
        emptyReg := true.B
        fullReg := false.B
        writePtr := 0.U
        readPtr := 0.U
        bufferOutputSelect := 0.U
    }

    val data = mem.read(readFullPtr)

    switch(stateReg) {
        is(idle) {
            when(!emptyReg && !io.clearBuffer) {
                stateReg := valid
                fullReg := false.B
                emptyReg := nextRead === writePtr && shouldIncreaseReadPtr
                // prepare for the next read, as it requires one cycle delay
                bufferOutputSelect := bufferOutputSelect + 1.U
            }
        }
        is(valid) {
            when (!io.clearBuffer) {
                when(io.deq.ready) {
                    when(!emptyReg) {
                        stateReg := valid
                        fullReg := false.B
                        emptyReg := nextRead === writePtr && shouldIncreaseReadPtr
                        incrRead := shouldIncreaseReadPtr
                        bufferOutputSelect := bufferOutputSelect + 1.U
                    } otherwise {
                        bufferOutputSelect := 0.U
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
                        emptyReg := nextRead === writePtr && (bufferOutputSelect === (numberOfBuffers-1).U)
                        incrRead := shouldIncreaseReadPtr
                        bufferOutputSelect := bufferOutputSelect + 1.U
                    } otherwise {
                        bufferOutputSelect := 0.U
                        stateReg := idle
                    }
                }
            }
        }
    }

    io.deq.bits := Mux(stateReg === valid, data, shadowReg)

    // both enq and clearBuffer are driven by the same module, otherwise, it creates unpredictable behavior
    io.enq.ready := !fullReg && ~io.clearBuffer
    io.deq.valid := stateReg === valid || stateReg === waitForTransfer

    // this is a hack to output the correct buffer select value
    // the reason is that the "bufferOutputSelect" register 
    // will contain the value from the current cycle but the valid data will be from previous.
    io.bufferOutputSelect := bufferOutputSelect - 1.U
    io.empty := emptyReg
}

object KeyBufferMain extends App {
  println("Generating the Key Buffer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KeyBuffer(4, 4, 8), Array("--target-dir", "generated"))
}
