package compaction_unit

import chisel3._
import chisel3.util.HasBlackBoxResource

trait AxiIO extends Bundle {
    val S_AXI_ACLK = Input(Bool())
    val S_AXI_ARESETN = Input(Bool())
    val S_AXI_AWADDR = Input(UInt(4.W))
    val S_AXI_AWPROT = Input(UInt(3.W))
    val S_AXI_AWVALID = Input(Bool())
    val S_AXI_AWREADY = Output(Bool())
    val S_AXI_WDATA = Input(UInt(32.W))
    val S_AXI_WSTRB = Input(UInt(4.W))
    val S_AXI_WVALID = Input(Bool())
    val S_AXI_WREADY = Output(Bool())
    val S_AXI_BRESP = Output(UInt(2.W))
    val S_AXI_BVALID = Output(Bool())
    val S_AXI_BREADY = Input(Bool())
    val S_AXI_ARADDR = Input(UInt(4.W))
    val S_AXI_ARPROT = Input(UInt(3.W))
    val S_AXI_ARVALID = Input(Bool())
    val S_AXI_ARREADY = Output(Bool())
    val S_AXI_RDATA = Output(UInt(32.W))
    val S_AXI_RRESP = Output(UInt(2.W))
    val S_AXI_RVALID = Output(Bool())
    val S_AXI_RREADY = Input(Bool())
}

trait ExternalControllerSignals extends Bundle {
    // custom signals for Controller
    val status = Input(UInt(32.W))
    val control = Output(UInt(32.W))
}


class ControlAdapterVerilog extends BlackBox with HasBlackBoxResource {
    val io = IO(new Bundle with ExternalControllerSignals with AxiIO)
    addResource("/control_adapter_axi_lite_s.v")
}
