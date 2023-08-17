package compaction_unit

import chisel3._
import chisel3.util._


class KvTransferIO(busWidth: Int, numberOfBuffers: Int = 4) extends Bundle {
    val enq = Flipped(Decoupled(UInt(busWidth.W)))
    val deq = Decoupled(UInt(busWidth.W))

    val command = Input(UInt(2.W))

    var bufferSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
    val outputKeyOnly = Output(Bool())
}


/** A class for KV transfer module. 
 *  This module is used to transfer KV pairs to Comparator module when requested.
 *  The module supports following commands:
 *      01: Transfer a chunk of Key from each buffer, one-by-one to output.
 *
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param numberOfBuffers, the number of buffers that will be connected to the KV transfer module.
 */
class KvTransfer(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Module {
    assert (busWidth > 0, "Bus width must be greater than 0")

    val io = IO(new KvTransferIO(busWidth, numberOfBuffers))

    val idle :: loadChunk :: waitForTransfer :: Nil = Enum(3)

    val state = RegInit(idle)
    val bufferIdx = RegInit(0.U(log2Ceil(numberOfBuffers).W))
    val data = RegInit(0.U(busWidth.W))

    switch (state) {
        is (idle) {
            when (io.command === "b01".U) {
                state := loadChunk
            }
        }
        is (loadChunk) {
            when (io.enq.valid) {
                data := io.enq.bits
                state := waitForTransfer
            }
        }
        is (waitForTransfer) {
            when (io.deq.ready) {
                when (bufferIdx === (numberOfBuffers-1).U) {
                    state := idle
                    bufferIdx := 0.U
                }.otherwise {
                    bufferIdx := bufferIdx + 1.U
                    state := loadChunk
                }
            }
        }
    }
    
    io.bufferSelect := bufferIdx
    io.outputKeyOnly := state === loadChunk || state === waitForTransfer
    io.enq.ready := state === loadChunk
    io.deq.bits := data
    io.deq.valid := state === waitForTransfer
}


/** A top module that connects KV transfer module to multiple buffers. 
 *
 *  @param busWidth, the number of bits that can be read from memory at once.
 *  @param numberOfBuffers, the number of buffers that will be connected to the KV transfer module.
 */
class TopKvTransfer(busWidth: Int = 4, numberOfBuffers: Int = 4) extends Module {
    val io = IO(new Bundle {
        val enq = Vec(numberOfBuffers, Flipped(Decoupled(UInt(busWidth.W))))
        val deq = Decoupled(UInt(busWidth.W))
        val command = Input(UInt(2.W))
        val bufferSelect = Output(UInt(log2Ceil(numberOfBuffers).W))
        val outputKeyOnly = Output(Bool())
    })

    val kvTransfer = Module(new KvTransfer(busWidth, numberOfBuffers))

    kvTransfer.io.enq <> DontCare
    kvTransfer.io.deq <> io.deq

    kvTransfer.io.bufferSelect <> io.bufferSelect
    kvTransfer.io.command <> io.command
    kvTransfer.io.outputKeyOnly <> io.outputKeyOnly

    for (i <- 0 until numberOfBuffers) {
        when(kvTransfer.io.bufferSelect === i.U) {
            kvTransfer.io.enq <> io.enq(i)
        }.otherwise {
            io.enq(i).ready := false.B
            io.enq(i).bits <> DontCare
            io.enq(i).valid <> DontCare
        }
    }
}

object KvTransferMain extends App {
  println("Generating the KV Transfer Verilog...")
  (new chisel3.stage.ChiselStage).emitVerilog(new KvTransfer(4), Array("--target-dir", "generated"))
  (new chisel3.stage.ChiselStage).emitVerilog(new TopKvTransfer(4), Array("--target-dir", "generated"))
}
