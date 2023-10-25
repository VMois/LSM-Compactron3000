package compaction_unit

import chisel3._
import chisel3.util._


class AxiStreamIO(busWidth: Int) extends Bundle {
    val tdata = Output(UInt(busWidth.W))
    val tvalid = Output(Bool())
    val tready = Input(Bool())
    val tlast = Output(Bool())
}
