module DummyEncoder(
  input         clock,
  input         reset,
  output        io_input_deq_ready,
  input         io_input_deq_valid,
  input  [31:0] io_input_deq_bits,
  input         io_input_lastOutput,
  input         io_input_metadataValid,
  output [31:0] io_output_axi_m_tdata,
  output        io_output_axi_m_tvalid,
  input         io_output_axi_m_tready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state; // @[DummyEncoder.scala 24:24]
  reg [31:0] status; // @[DummyEncoder.scala 25:25]
  wire [31:0] _status_T_3 = {status[31:16],io_input_deq_bits[7:0],status[7:0]}; // @[Cat.scala 33:92]
  wire [31:0] _status_T_7 = {status[31:24],io_input_deq_bits[7:0],status[15:0]}; // @[Cat.scala 33:92]
  wire [1:0] _GEN_3 = io_output_axi_m_tready ? 2'h3 : state; // @[DummyEncoder.scala 43:43 44:23 24:24]
  wire [1:0] _GEN_4 = io_input_lastOutput & io_output_axi_m_tready ? 2'h0 : state; // @[DummyEncoder.scala 49:66 50:23 24:24]
  wire [1:0] _GEN_5 = 2'h3 == state ? _GEN_4 : state; // @[DummyEncoder.scala 27:20 24:24]
  wire  _io_output_axi_m_tdata_T = state == 2'h2; // @[DummyEncoder.scala 56:40]
  assign io_input_deq_ready = state == 2'h3 & io_output_axi_m_tready; // @[DummyEncoder.scala 55:48]
  assign io_output_axi_m_tdata = state == 2'h2 ? status : io_input_deq_bits; // @[DummyEncoder.scala 56:33]
  assign io_output_axi_m_tvalid = _io_output_axi_m_tdata_T | io_input_deq_valid; // @[DummyEncoder.scala 57:54]
  always @(posedge clock) begin
    if (reset) begin // @[DummyEncoder.scala 24:24]
      state <= 2'h0; // @[DummyEncoder.scala 24:24]
    end else if (2'h0 == state) begin // @[DummyEncoder.scala 27:20]
      if (io_input_metadataValid) begin // @[DummyEncoder.scala 29:43]
        state <= 2'h1; // @[DummyEncoder.scala 31:23]
      end
    end else if (2'h1 == state) begin // @[DummyEncoder.scala 27:20]
      state <= 2'h2; // @[DummyEncoder.scala 39:19]
    end else if (2'h2 == state) begin // @[DummyEncoder.scala 27:20]
      state <= _GEN_3;
    end else begin
      state <= _GEN_5;
    end
    if (reset) begin // @[DummyEncoder.scala 25:25]
      status <= 32'h0; // @[DummyEncoder.scala 25:25]
    end else if (2'h0 == state) begin // @[DummyEncoder.scala 27:20]
      if (io_input_metadataValid) begin // @[DummyEncoder.scala 29:43]
        status <= _status_T_3; // @[DummyEncoder.scala 30:24]
      end
    end else if (2'h1 == state) begin // @[DummyEncoder.scala 27:20]
      if (io_input_metadataValid) begin // @[DummyEncoder.scala 36:43]
        status <= _status_T_7; // @[DummyEncoder.scala 37:24]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  status = _RAND_1[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module DummyDecoder(
  input         clock,
  input         reset,
  input  [31:0] io_input_axi_s_tdata,
  input         io_input_axi_s_tvalid,
  output        io_input_axi_s_tready,
  output        io_output_enq_valid,
  output [31:0] io_output_enq_bits,
  output        io_output_lastInput,
  output        io_output_isInputKey
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state; // @[DummyDecoder.scala 27:24]
  reg [31:0] status; // @[DummyDecoder.scala 28:25]
  reg [7:0] counter; // @[DummyDecoder.scala 32:26]
  wire [7:0] keyLen = status[15:8] - 8'h1; // @[DummyDecoder.scala 35:32]
  wire [7:0] valueLen = status[23:16] - 8'h1; // @[DummyDecoder.scala 36:35]
  wire  _T_2 = io_input_axi_s_tvalid & io_input_axi_s_tready; // @[DummyDecoder.scala 48:41]
  wire [7:0] _counter_T_1 = counter + 8'h1; // @[DummyDecoder.scala 49:36]
  wire [1:0] _GEN_2 = counter == keyLen ? 2'h2 : state; // @[DummyDecoder.scala 27:24 51:43 52:27]
  wire [7:0] _GEN_3 = counter == keyLen ? 8'h0 : _counter_T_1; // @[DummyDecoder.scala 49:25 51:43 53:29]
  wire  _T_6 = counter == valueLen; // @[DummyDecoder.scala 62:31]
  wire [1:0] _GEN_6 = counter == valueLen ? 2'h0 : state; // @[DummyDecoder.scala 27:24 62:45 63:27]
  wire [7:0] _GEN_7 = counter == valueLen ? 8'h0 : _counter_T_1; // @[DummyDecoder.scala 60:25 62:45 64:29]
  wire [7:0] _GEN_9 = _T_2 ? _GEN_7 : counter; // @[DummyDecoder.scala 32:26 59:67]
  wire [1:0] _GEN_10 = _T_2 ? _GEN_6 : state; // @[DummyDecoder.scala 27:24 59:67]
  wire  _io_output_enq_valid_T_1 = state == 2'h2; // @[DummyDecoder.scala 75:56]
  assign io_input_axi_s_tready = 1'h1; // @[DummyDecoder.scala 72:27]
  assign io_output_enq_valid = (state == 2'h1 | state == 2'h2) & io_input_axi_s_tvalid; // @[DummyDecoder.scala 75:71]
  assign io_output_enq_bits = io_input_axi_s_tdata; // @[DummyDecoder.scala 76:24]
  assign io_output_lastInput = _io_output_enq_valid_T_1 & _T_6; // @[DummyDecoder.scala 78:48]
  assign io_output_isInputKey = state == 2'h1; // @[DummyDecoder.scala 77:35]
  always @(posedge clock) begin
    if (reset) begin // @[DummyDecoder.scala 27:24]
      state <= 2'h0; // @[DummyDecoder.scala 27:24]
    end else if (2'h0 == state) begin // @[DummyDecoder.scala 39:20]
      if (io_input_axi_s_tvalid) begin // @[DummyDecoder.scala 41:42]
        state <= 2'h1; // @[DummyDecoder.scala 42:23]
      end
    end else if (2'h1 == state) begin // @[DummyDecoder.scala 39:20]
      if (io_input_axi_s_tvalid & io_input_axi_s_tready) begin // @[DummyDecoder.scala 48:67]
        state <= _GEN_2;
      end
    end else if (2'h2 == state) begin // @[DummyDecoder.scala 39:20]
      state <= _GEN_10;
    end
    if (reset) begin // @[DummyDecoder.scala 28:25]
      status <= 32'h0; // @[DummyDecoder.scala 28:25]
    end else if (2'h0 == state) begin // @[DummyDecoder.scala 39:20]
      if (io_input_axi_s_tvalid) begin // @[DummyDecoder.scala 41:42]
        status <= io_input_axi_s_tdata; // @[DummyDecoder.scala 43:24]
      end
    end
    if (reset) begin // @[DummyDecoder.scala 32:26]
      counter <= 8'h0; // @[DummyDecoder.scala 32:26]
    end else if (!(2'h0 == state)) begin // @[DummyDecoder.scala 39:20]
      if (2'h1 == state) begin // @[DummyDecoder.scala 39:20]
        if (io_input_axi_s_tvalid & io_input_axi_s_tready) begin // @[DummyDecoder.scala 48:67]
          counter <= _GEN_3;
        end
      end else if (2'h2 == state) begin // @[DummyDecoder.scala 39:20]
        counter <= _GEN_9;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  status = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  counter = _RAND_2[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module KVRingBuffer(
  input         clock,
  input         reset,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_lastInput,
  input         io_isInputKey,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits,
  output        io_lastOutput,
  output        io_metadataValid
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] mem [0:1279]; // @[KvRingBuffer.scala 84:26]
  wire  mem_data_en; // @[KvRingBuffer.scala 168:{24,24} 84:{26,26}]
  reg [10:0] mem_data_addr; // @[KvRingBuffer.scala 84:26]
  wire [31:0] mem_data_data; // @[KvRingBuffer.scala 84:26]
  wire [31:0] mem_MPORT_data; // @[KvRingBuffer.scala 84:26 127:38]
  wire [10:0] mem_MPORT_addr; // @[KvRingBuffer.scala 84:26]
  wire  mem_MPORT_mask; // @[KvRingBuffer.scala 84:26 127:38]
  wire  mem_MPORT_en; // @[KvRingBuffer.scala 84:26 124:27 84:26]
  wire [31:0] mem_MPORT_1_data; // @[KvRingBuffer.scala 84:26 127:38]
  wire [10:0] mem_MPORT_1_addr; // @[KvRingBuffer.scala 84:26]
  wire  mem_MPORT_1_mask; // @[KvRingBuffer.scala 84:26 127:38]
  wire  mem_MPORT_1_en; // @[KvRingBuffer.scala 84:26 124:27 84:26]
  wire [31:0] mem_MPORT_2_data; // @[KvRingBuffer.scala 84:26]
  wire [10:0] mem_MPORT_2_addr; // @[KvRingBuffer.scala 84:26]
  wire  mem_MPORT_2_mask; // @[KvRingBuffer.scala 84:26 124:27]
  wire  mem_MPORT_2_en; // @[KvRingBuffer.scala 84:26 124:27 84:26]
  wire [31:0] mem_MPORT_3_data; // @[KvRingBuffer.scala 84:26]
  wire [10:0] mem_MPORT_3_addr; // @[KvRingBuffer.scala 84:26]
  wire  mem_MPORT_3_mask; // @[KvRingBuffer.scala 84:26 124:27]
  wire  mem_MPORT_3_en; // @[KvRingBuffer.scala 84:26 124:27 84:26]
  reg [1:0] readPtr; // @[KvRingBuffer.scala 75:29]
  wire [1:0] _nextVal_T_2 = readPtr + 2'h1; // @[KvRingBuffer.scala 76:63]
  wire [1:0] nextRead = readPtr == 2'h3 ? 2'h0 : _nextVal_T_2; // @[KvRingBuffer.scala 76:26]
  reg [3:0] outputStateReg; // @[KvRingBuffer.scala 122:33]
  wire  _GEN_173 = 4'ha == outputStateReg ? io_deq_ready : 4'hb == outputStateReg & io_deq_ready; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_178 = 4'h9 == outputStateReg ? 1'h0 : _GEN_173; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_184 = 4'h8 == outputStateReg ? 1'h0 : _GEN_178; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_189 = 4'h7 == outputStateReg ? 1'h0 : _GEN_184; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_194 = 4'h6 == outputStateReg ? 1'h0 : _GEN_189; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_200 = 4'h5 == outputStateReg ? 1'h0 : _GEN_194; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_206 = 4'h4 == outputStateReg ? 1'h0 : _GEN_200; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_213 = 4'h3 == outputStateReg ? 1'h0 : _GEN_206; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_221 = 4'h2 == outputStateReg ? 1'h0 : _GEN_213; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_229 = 4'h1 == outputStateReg ? 1'h0 : _GEN_221; // @[KvRingBuffer.scala 171:28]
  wire  incrRead = 4'h0 == outputStateReg ? 1'h0 : _GEN_229; // @[KvRingBuffer.scala 171:28]
  reg [1:0] writePtr; // @[KvRingBuffer.scala 75:29]
  wire [1:0] _nextVal_T_5 = writePtr + 2'h1; // @[KvRingBuffer.scala 76:63]
  wire [1:0] nextWrite = writePtr == 2'h3 ? 2'h0 : _nextVal_T_5; // @[KvRingBuffer.scala 76:26]
  reg [1:0] inputStateReg; // @[KvRingBuffer.scala 121:32]
  wire  _GEN_51 = 2'h1 == inputStateReg ? 1'h0 : 2'h2 == inputStateReg; // @[KvRingBuffer.scala 124:27 84:26]
  wire  incrWrite = 2'h0 == inputStateReg ? 1'h0 : _GEN_51; // @[KvRingBuffer.scala 124:27 84:26]
  reg [9:0] writeKeyChunkPtr; // @[KvRingBuffer.scala 75:29]
  wire [9:0] _nextVal_T_8 = writeKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 76:63]
  reg [9:0] writeValueChunkPtr; // @[KvRingBuffer.scala 75:29]
  wire [9:0] _nextVal_T_11 = writeValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 76:63]
  reg [9:0] readKeyChunkPtr; // @[KvRingBuffer.scala 75:29]
  wire [9:0] _nextVal_T_14 = readKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 76:63]
  reg [9:0] readValueChunkPtr; // @[KvRingBuffer.scala 75:29]
  wire [9:0] _nextVal_T_17 = readValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 76:63]
  reg [31:0] keyLen; // @[KvRingBuffer.scala 108:25]
  reg [31:0] valueLen; // @[KvRingBuffer.scala 109:27]
  reg  emptyReg; // @[KvRingBuffer.scala 111:27]
  reg  fullReg; // @[KvRingBuffer.scala 112:26]
  wire [5:0] _T_3 = writePtr * 4'h8; // @[KvRingBuffer.scala 128:40]
  wire [5:0] _T_5 = _T_3 + 6'h2; // @[KvRingBuffer.scala 128:108]
  wire [9:0] _GEN_238 = {{4'd0}, _T_5}; // @[KvRingBuffer.scala 128:134]
  wire [9:0] _T_7 = _GEN_238 + writeKeyChunkPtr; // @[KvRingBuffer.scala 128:134]
  wire [5:0] _T_10 = _T_3 + 6'h6; // @[KvRingBuffer.scala 131:108]
  wire [9:0] _GEN_239 = {{4'd0}, _T_10}; // @[KvRingBuffer.scala 131:155]
  wire [9:0] _T_12 = _GEN_239 + writeValueChunkPtr; // @[KvRingBuffer.scala 131:155]
  wire [1:0] _GEN_6 = io_lastInput ? 2'h1 : inputStateReg; // @[KvRingBuffer.scala 121:32 134:40 135:39]
  wire  _GEN_15 = io_isInputKey ? 1'h0 : 1'h1; // @[KvRingBuffer.scala 127:38 84:26]
  wire  _GEN_22 = io_enq_valid & ~fullReg & io_isInputKey; // @[KvRingBuffer.scala 126:44 84:26]
  wire  _GEN_28 = io_enq_valid & ~fullReg & _GEN_15; // @[KvRingBuffer.scala 126:44 84:26]
  wire [5:0] _T_18 = _T_3 + 6'h1; // @[KvRingBuffer.scala 147:100]
  wire  _GEN_38 = 2'h2 == inputStateReg ? 1'h0 : emptyReg; // @[KvRingBuffer.scala 124:27 148:22 111:27]
  wire  _GEN_54 = 2'h1 == inputStateReg ? emptyReg : _GEN_38; // @[KvRingBuffer.scala 111:27 124:27]
  wire  _GEN_81 = 2'h0 == inputStateReg ? emptyReg : _GEN_54; // @[KvRingBuffer.scala 111:27 124:27]
  wire [5:0] _readFullPtr_T = readPtr * 4'h8; // @[KvRingBuffer.scala 167:31]
  wire [9:0] _GEN_240 = {{4'd0}, _readFullPtr_T}; // @[KvRingBuffer.scala 167:99]
  wire [9:0] _readFullPtr_T_2 = _GEN_240 + readValueChunkPtr; // @[KvRingBuffer.scala 167:99]
  wire [9:0] readFullPtr = _readFullPtr_T_2 + readKeyChunkPtr; // @[KvRingBuffer.scala 167:119]
  reg [31:0] shadowReg; // @[KvRingBuffer.scala 169:28]
  wire [31:0] _GEN_95 = mem_data_data; // @[KvRingBuffer.scala 188:42 189:24 108:25]
  wire [9:0] _GEN_99 = keyLen == 32'h1 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 201:38 203:39]
  wire [2:0] _GEN_100 = keyLen == 32'h1 ? 3'h6 : 3'h1; // @[KvRingBuffer.scala 201:38 204:37 209:37]
  wire [3:0] _GEN_101 = keyLen == 32'h1 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 201:38 206:36 210:36]
  wire [9:0] _GEN_103 = {{7'd0}, _GEN_100}; // @[KvRingBuffer.scala 200:42]
  wire [31:0] _T_33 = keyLen - 32'h1; // @[KvRingBuffer.scala 218:54]
  wire [31:0] _GEN_241 = {{22'd0}, readKeyChunkPtr}; // @[KvRingBuffer.scala 218:43]
  wire  _T_34 = _GEN_241 == _T_33; // @[KvRingBuffer.scala 218:43]
  wire  _emptyReg_T = nextRead == writePtr; // @[KvRingBuffer.scala 220:46]
  wire [3:0] _GEN_105 = _GEN_241 == _T_33 ? 4'h6 : outputStateReg; // @[KvRingBuffer.scala 218:61 219:40]
  wire  _GEN_106 = _GEN_241 == _T_33 ? nextRead == writePtr : _GEN_81; // @[KvRingBuffer.scala 218:61 220:34]
  wire [9:0] _GEN_107 = _GEN_241 == _T_33 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 218:61 221:43]
  wire [9:0] _GEN_108 = _GEN_241 == _T_33 ? 10'h6 : _nextVal_T_14; // @[KvRingBuffer.scala 218:61 222:41 224:41]
  wire [3:0] _GEN_109 = io_deq_ready ? _GEN_105 : 4'h5; // @[KvRingBuffer.scala 217:36 229:36]
  wire  _GEN_110 = io_deq_ready ? _GEN_106 : _GEN_81; // @[KvRingBuffer.scala 217:36]
  wire [9:0] _GEN_111 = io_deq_ready ? _GEN_107 : readValueChunkPtr; // @[KvRingBuffer.scala 217:36]
  wire [9:0] _GEN_112 = io_deq_ready ? _GEN_108 : readKeyChunkPtr; // @[KvRingBuffer.scala 217:36]
  wire [31:0] _GEN_113 = io_deq_ready ? shadowReg : mem_data_data; // @[KvRingBuffer.scala 169:28 217:36 228:31]
  wire [3:0] _GEN_119 = _T_34 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 236:57 237:36 242:36]
  wire [3:0] _GEN_123 = io_deq_ready ? _GEN_119 : outputStateReg; // @[KvRingBuffer.scala 235:57]
  wire [3:0] _GEN_127 = valueLen == 32'h1 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 254:48 255:44 257:44]
  wire [9:0] _GEN_128 = valueLen == 32'h1 ? readValueChunkPtr : 10'h1; // @[KvRingBuffer.scala 254:48 258:47]
  wire [3:0] _GEN_131 = io_deq_ready ? _GEN_127 : 4'h7; // @[KvRingBuffer.scala 250:36 263:36]
  wire [9:0] _GEN_132 = io_deq_ready ? _GEN_128 : readValueChunkPtr; // @[KvRingBuffer.scala 250:36]
  wire [3:0] _GEN_140 = io_deq_ready ? _GEN_127 : outputStateReg; // @[KvRingBuffer.scala 269:57]
  wire [31:0] _T_51 = valueLen - 32'h1; // @[KvRingBuffer.scala 286:57]
  wire [31:0] _GEN_243 = {{22'd0}, readValueChunkPtr}; // @[KvRingBuffer.scala 286:44]
  wire  _T_52 = _GEN_243 == _T_51; // @[KvRingBuffer.scala 286:44]
  wire [3:0] _GEN_142 = _GEN_243 == _T_51 ? 4'ha : outputStateReg; // @[KvRingBuffer.scala 286:64 287:40]
  wire  _GEN_143 = _GEN_243 == _T_51 ? _emptyReg_T : _GEN_81; // @[KvRingBuffer.scala 286:64 291:34]
  wire [9:0] _GEN_144 = _GEN_243 == _T_51 ? readValueChunkPtr : _nextVal_T_17; // @[KvRingBuffer.scala 286:64 293:43]
  wire [3:0] _GEN_145 = io_deq_ready ? _GEN_142 : 4'h9; // @[KvRingBuffer.scala 285:36 298:36]
  wire  _GEN_146 = io_deq_ready ? _GEN_143 : _GEN_81; // @[KvRingBuffer.scala 285:36]
  wire [9:0] _GEN_147 = io_deq_ready ? _GEN_144 : readValueChunkPtr; // @[KvRingBuffer.scala 285:36]
  wire [3:0] _GEN_152 = _T_52 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 305:60 306:36 312:36]
  wire [3:0] _GEN_155 = io_deq_ready ? _GEN_152 : outputStateReg; // @[KvRingBuffer.scala 304:57]
  wire [3:0] _GEN_158 = io_deq_ready ? 4'h0 : 4'hb; // @[KvRingBuffer.scala 320:36 321:36 329:36]
  wire  _GEN_159 = io_deq_ready ? _emptyReg_T : _GEN_81; // @[KvRingBuffer.scala 320:36 322:30]
  wire [3:0] _GEN_165 = io_deq_ready ? 4'h0 : outputStateReg; // @[KvRingBuffer.scala 335:57 336:32]
  wire [3:0] _GEN_168 = 4'hb == outputStateReg ? _GEN_165 : outputStateReg; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_169 = 4'hb == outputStateReg ? _GEN_159 : _GEN_81; // @[KvRingBuffer.scala 171:28]
  wire [3:0] _GEN_171 = 4'ha == outputStateReg ? _GEN_158 : _GEN_168; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_172 = 4'ha == outputStateReg ? _GEN_159 : _GEN_169; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_174 = 4'ha == outputStateReg ? _GEN_113 : shadowReg; // @[KvRingBuffer.scala 169:28 171:28]
  wire [3:0] _GEN_175 = 4'h9 == outputStateReg ? _GEN_155 : _GEN_171; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_176 = 4'h9 == outputStateReg ? _GEN_146 : _GEN_172; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_177 = 4'h9 == outputStateReg ? _GEN_147 : readValueChunkPtr; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_179 = 4'h9 == outputStateReg ? shadowReg : _GEN_174; // @[KvRingBuffer.scala 169:28 171:28]
  wire [3:0] _GEN_180 = 4'h8 == outputStateReg ? _GEN_145 : _GEN_175; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_181 = 4'h8 == outputStateReg ? _GEN_146 : _GEN_176; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_182 = 4'h8 == outputStateReg ? _GEN_147 : _GEN_177; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_183 = 4'h8 == outputStateReg ? _GEN_113 : _GEN_179; // @[KvRingBuffer.scala 171:28]
  wire [3:0] _GEN_185 = 4'h7 == outputStateReg ? _GEN_140 : _GEN_180; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_186 = 4'h7 == outputStateReg ? _GEN_132 : _GEN_182; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_187 = 4'h7 == outputStateReg ? _GEN_81 : _GEN_181; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_188 = 4'h7 == outputStateReg ? shadowReg : _GEN_183; // @[KvRingBuffer.scala 169:28 171:28]
  wire [3:0] _GEN_190 = 4'h6 == outputStateReg ? _GEN_131 : _GEN_185; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_191 = 4'h6 == outputStateReg ? _GEN_132 : _GEN_186; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_192 = 4'h6 == outputStateReg ? _GEN_113 : _GEN_188; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_193 = 4'h6 == outputStateReg ? _GEN_81 : _GEN_187; // @[KvRingBuffer.scala 171:28]
  wire [3:0] _GEN_195 = 4'h5 == outputStateReg ? _GEN_123 : _GEN_190; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_196 = 4'h5 == outputStateReg ? _GEN_110 : _GEN_193; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_197 = 4'h5 == outputStateReg ? _GEN_111 : _GEN_191; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_198 = 4'h5 == outputStateReg ? _GEN_112 : readKeyChunkPtr; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_199 = 4'h5 == outputStateReg ? shadowReg : _GEN_192; // @[KvRingBuffer.scala 169:28 171:28]
  wire [3:0] _GEN_201 = 4'h4 == outputStateReg ? _GEN_109 : _GEN_195; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_202 = 4'h4 == outputStateReg ? _GEN_110 : _GEN_196; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_203 = 4'h4 == outputStateReg ? _GEN_111 : _GEN_197; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_204 = 4'h4 == outputStateReg ? _GEN_112 : _GEN_198; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_205 = 4'h4 == outputStateReg ? _GEN_113 : _GEN_199; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_207 = 4'h3 == outputStateReg ? mem_data_data : valueLen; // @[KvRingBuffer.scala 171:28 199:22 109:27]
  wire [9:0] _GEN_208 = 4'h3 == outputStateReg ? _GEN_99 : _GEN_203; // @[KvRingBuffer.scala 171:28]
  wire [9:0] _GEN_209 = 4'h3 == outputStateReg ? _GEN_103 : _GEN_204; // @[KvRingBuffer.scala 171:28]
  wire [3:0] _GEN_210 = 4'h3 == outputStateReg ? _GEN_101 : _GEN_201; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_211 = 4'h3 == outputStateReg ? _GEN_81 : _GEN_202; // @[KvRingBuffer.scala 171:28]
  wire [31:0] _GEN_212 = 4'h3 == outputStateReg ? shadowReg : _GEN_205; // @[KvRingBuffer.scala 169:28 171:28]
  wire  _GEN_219 = 4'h2 == outputStateReg ? _GEN_81 : _GEN_211; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_227 = 4'h1 == outputStateReg ? _GEN_81 : _GEN_219; // @[KvRingBuffer.scala 171:28]
  wire  _GEN_235 = 4'h0 == outputStateReg ? _GEN_81 : _GEN_227; // @[KvRingBuffer.scala 171:28]
  wire  _io_deq_valid_T_3 = outputStateReg == 4'h5; // @[KvRingBuffer.scala 347:111]
  wire  _io_deq_valid_T_5 = outputStateReg == 4'h7; // @[KvRingBuffer.scala 347:148]
  wire  _io_deq_valid_T_9 = outputStateReg == 4'ha; // @[KvRingBuffer.scala 347:232]
  wire  _io_deq_valid_T_11 = outputStateReg == 4'h9; // @[KvRingBuffer.scala 347:273]
  wire  _io_deq_valid_T_13 = outputStateReg == 4'hb; // @[KvRingBuffer.scala 347:312]
  assign mem_data_en = 1'h1; // @[KvRingBuffer.scala 168:{24,24} 84:26]
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_data_data = mem[mem_data_addr]; // @[KvRingBuffer.scala 84:26]
  `else
  assign mem_data_data = mem_data_addr >= 11'h500 ? _RAND_2[31:0] : mem[mem_data_addr]; // @[KvRingBuffer.scala 84:26]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_MPORT_data = io_enq_bits; // @[KvRingBuffer.scala 127:38]
  assign mem_MPORT_addr = {{1'd0}, _T_7};
  assign mem_MPORT_mask = 1'h1; // @[KvRingBuffer.scala 127:38]
  assign mem_MPORT_en = 2'h0 == inputStateReg & _GEN_22; // @[KvRingBuffer.scala 124:27 84:26]
  assign mem_MPORT_1_data = io_enq_bits; // @[KvRingBuffer.scala 127:38]
  assign mem_MPORT_1_addr = {{1'd0}, _T_12};
  assign mem_MPORT_1_mask = 1'h1; // @[KvRingBuffer.scala 127:38]
  assign mem_MPORT_1_en = 2'h0 == inputStateReg & _GEN_28; // @[KvRingBuffer.scala 124:27 84:26]
  assign mem_MPORT_2_data = {{22'd0}, writeKeyChunkPtr};
  assign mem_MPORT_2_addr = {{5'd0}, _T_3};
  assign mem_MPORT_2_mask = 1'h1; // @[KvRingBuffer.scala 124:27]
  assign mem_MPORT_2_en = 2'h0 == inputStateReg ? 1'h0 : 2'h1 == inputStateReg; // @[KvRingBuffer.scala 124:27 84:26]
  assign mem_MPORT_3_data = {{22'd0}, writeValueChunkPtr};
  assign mem_MPORT_3_addr = {{5'd0}, _T_18};
  assign mem_MPORT_3_mask = 1'h1; // @[KvRingBuffer.scala 124:27]
  assign mem_MPORT_3_en = 2'h0 == inputStateReg ? 1'h0 : _GEN_51; // @[KvRingBuffer.scala 124:27 84:26]
  assign io_deq_valid = outputStateReg == 4'h4 | outputStateReg == 4'h6 | outputStateReg == 4'h5 | outputStateReg == 4'h7
     | outputStateReg == 4'h8 | outputStateReg == 4'ha | outputStateReg == 4'h9 | outputStateReg == 4'hb; // @[KvRingBuffer.scala 347:294]
  assign io_deq_bits = _io_deq_valid_T_3 | _io_deq_valid_T_5 | _io_deq_valid_T_11 | _io_deq_valid_T_13 ? shadowReg :
    mem_data_data; // @[KvRingBuffer.scala 348:23]
  assign io_lastOutput = _io_deq_valid_T_9 | _io_deq_valid_T_13; // @[KvRingBuffer.scala 350:61]
  assign io_metadataValid = outputStateReg == 4'h2 | outputStateReg == 4'h3; // @[KvRingBuffer.scala 354:61]
  always @(posedge clock) begin
    if (mem_data_en) begin
      mem_data_addr <= {{1'd0}, readFullPtr}; // @[KvRingBuffer.scala 168:24]
    end
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[KvRingBuffer.scala 84:26]
    end
    if (mem_MPORT_1_en & mem_MPORT_1_mask) begin
      mem[mem_MPORT_1_addr] <= mem_MPORT_1_data; // @[KvRingBuffer.scala 84:26]
    end
    if (mem_MPORT_2_en & mem_MPORT_2_mask) begin
      mem[mem_MPORT_2_addr] <= mem_MPORT_2_data; // @[KvRingBuffer.scala 84:26]
    end
    if (mem_MPORT_3_en & mem_MPORT_3_mask) begin
      mem[mem_MPORT_3_addr] <= mem_MPORT_3_data; // @[KvRingBuffer.scala 84:26]
    end
    if (reset) begin // @[KvRingBuffer.scala 75:29]
      readPtr <= 2'h0; // @[KvRingBuffer.scala 75:29]
    end else if (incrRead) begin // @[KvRingBuffer.scala 77:21]
      if (readPtr == 2'h3) begin // @[KvRingBuffer.scala 76:26]
        readPtr <= 2'h0;
      end else begin
        readPtr <= _nextVal_T_2;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 122:33]
      outputStateReg <= 4'h0; // @[KvRingBuffer.scala 122:33]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 173:54]
        outputStateReg <= 4'h1; // @[KvRingBuffer.scala 176:32]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      outputStateReg <= 4'h2;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      outputStateReg <= 4'h3;
    end else begin
      outputStateReg <= _GEN_210;
    end
    if (reset) begin // @[KvRingBuffer.scala 75:29]
      writePtr <= 2'h0; // @[KvRingBuffer.scala 75:29]
    end else if (incrWrite) begin // @[KvRingBuffer.scala 77:21]
      if (writePtr == 2'h3) begin // @[KvRingBuffer.scala 76:26]
        writePtr <= 2'h0;
      end else begin
        writePtr <= _nextVal_T_5;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 121:32]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 121:32]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 126:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 127:38]
          inputStateReg <= _GEN_6;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
      inputStateReg <= 2'h2; // @[KvRingBuffer.scala 143:27]
    end else if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 153:27]
    end
    if (reset) begin // @[KvRingBuffer.scala 75:29]
      writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 75:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 126:44]
        if (io_isInputKey) begin // @[KvRingBuffer.scala 127:38]
          writeKeyChunkPtr <= _nextVal_T_8; // @[KvRingBuffer.scala 129:38]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 124:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
        writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 154:30]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 75:29]
      writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 75:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 126:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 127:38]
          writeValueChunkPtr <= _nextVal_T_11; // @[KvRingBuffer.scala 132:40]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 124:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
        writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 155:32]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 75:29]
      readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 75:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 173:54]
        readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 174:33]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      readKeyChunkPtr <= 10'h1;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      readKeyChunkPtr <= 10'h0;
    end else begin
      readKeyChunkPtr <= _GEN_209;
    end
    if (reset) begin // @[KvRingBuffer.scala 75:29]
      readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 75:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 173:54]
        readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 175:35]
      end
    end else if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
      if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
        readValueChunkPtr <= 10'h2;
      end else begin
        readValueChunkPtr <= _GEN_208;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 108:25]
      keyLen <= 32'h0; // @[KvRingBuffer.scala 108:25]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
        if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 171:28]
          keyLen <= _GEN_95;
        end
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 109:27]
      valueLen <= 32'h0; // @[KvRingBuffer.scala 109:27]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
          valueLen <= _GEN_207;
        end
      end
    end
    emptyReg <= reset | _GEN_235; // @[KvRingBuffer.scala 111:{27,27}]
    if (reset) begin // @[KvRingBuffer.scala 112:26]
      fullReg <= 1'h0; // @[KvRingBuffer.scala 112:26]
    end else if (!(2'h0 == inputStateReg)) begin // @[KvRingBuffer.scala 124:27]
      if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 124:27]
        if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 124:27]
          fullReg <= nextWrite == readPtr; // @[KvRingBuffer.scala 150:21]
        end
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 169:28]
      shadowReg <= 32'h0; // @[KvRingBuffer.scala 169:28]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 171:28]
          shadowReg <= _GEN_212;
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_2 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1280; initvar = initvar+1)
    mem[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  mem_data_addr = _RAND_1[10:0];
  _RAND_3 = {1{`RANDOM}};
  readPtr = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  outputStateReg = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  writePtr = _RAND_5[1:0];
  _RAND_6 = {1{`RANDOM}};
  inputStateReg = _RAND_6[1:0];
  _RAND_7 = {1{`RANDOM}};
  writeKeyChunkPtr = _RAND_7[9:0];
  _RAND_8 = {1{`RANDOM}};
  writeValueChunkPtr = _RAND_8[9:0];
  _RAND_9 = {1{`RANDOM}};
  readKeyChunkPtr = _RAND_9[9:0];
  _RAND_10 = {1{`RANDOM}};
  readValueChunkPtr = _RAND_10[9:0];
  _RAND_11 = {1{`RANDOM}};
  keyLen = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  valueLen = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  emptyReg = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  fullReg = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  shadowReg = _RAND_15[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module DummyKvPairFifo(
  input         clock,
  input         reset,
  input  [31:0] io_axi_s_tdata,
  input         io_axi_s_tvalid,
  output        io_axi_s_tready,
  input         io_axi_s_tlast,
  output [31:0] io_axi_m_tdata,
  output        io_axi_m_tvalid,
  input         io_axi_m_tready,
  output        io_axi_m_tlast
);
  wire  encoder_clock; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_reset; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_io_input_deq_ready; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_io_input_deq_valid; // @[DummyKvPairFifo.scala 16:25]
  wire [31:0] encoder_io_input_deq_bits; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_io_input_lastOutput; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_io_input_metadataValid; // @[DummyKvPairFifo.scala 16:25]
  wire [31:0] encoder_io_output_axi_m_tdata; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_io_output_axi_m_tvalid; // @[DummyKvPairFifo.scala 16:25]
  wire  encoder_io_output_axi_m_tready; // @[DummyKvPairFifo.scala 16:25]
  wire  decoder_clock; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_reset; // @[DummyKvPairFifo.scala 17:25]
  wire [31:0] decoder_io_input_axi_s_tdata; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_input_axi_s_tvalid; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_input_axi_s_tready; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_output_enq_valid; // @[DummyKvPairFifo.scala 17:25]
  wire [31:0] decoder_io_output_enq_bits; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_output_lastInput; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_output_isInputKey; // @[DummyKvPairFifo.scala 17:25]
  wire  kvOutputBuffer_clock; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_reset; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_enq_valid; // @[DummyKvPairFifo.scala 18:32]
  wire [31:0] kvOutputBuffer_io_enq_bits; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_lastInput; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_isInputKey; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_deq_ready; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_deq_valid; // @[DummyKvPairFifo.scala 18:32]
  wire [31:0] kvOutputBuffer_io_deq_bits; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_lastOutput; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_metadataValid; // @[DummyKvPairFifo.scala 18:32]
  DummyEncoder encoder ( // @[DummyKvPairFifo.scala 16:25]
    .clock(encoder_clock),
    .reset(encoder_reset),
    .io_input_deq_ready(encoder_io_input_deq_ready),
    .io_input_deq_valid(encoder_io_input_deq_valid),
    .io_input_deq_bits(encoder_io_input_deq_bits),
    .io_input_lastOutput(encoder_io_input_lastOutput),
    .io_input_metadataValid(encoder_io_input_metadataValid),
    .io_output_axi_m_tdata(encoder_io_output_axi_m_tdata),
    .io_output_axi_m_tvalid(encoder_io_output_axi_m_tvalid),
    .io_output_axi_m_tready(encoder_io_output_axi_m_tready)
  );
  DummyDecoder decoder ( // @[DummyKvPairFifo.scala 17:25]
    .clock(decoder_clock),
    .reset(decoder_reset),
    .io_input_axi_s_tdata(decoder_io_input_axi_s_tdata),
    .io_input_axi_s_tvalid(decoder_io_input_axi_s_tvalid),
    .io_input_axi_s_tready(decoder_io_input_axi_s_tready),
    .io_output_enq_valid(decoder_io_output_enq_valid),
    .io_output_enq_bits(decoder_io_output_enq_bits),
    .io_output_lastInput(decoder_io_output_lastInput),
    .io_output_isInputKey(decoder_io_output_isInputKey)
  );
  KVRingBuffer kvOutputBuffer ( // @[DummyKvPairFifo.scala 18:32]
    .clock(kvOutputBuffer_clock),
    .reset(kvOutputBuffer_reset),
    .io_enq_valid(kvOutputBuffer_io_enq_valid),
    .io_enq_bits(kvOutputBuffer_io_enq_bits),
    .io_lastInput(kvOutputBuffer_io_lastInput),
    .io_isInputKey(kvOutputBuffer_io_isInputKey),
    .io_deq_ready(kvOutputBuffer_io_deq_ready),
    .io_deq_valid(kvOutputBuffer_io_deq_valid),
    .io_deq_bits(kvOutputBuffer_io_deq_bits),
    .io_lastOutput(kvOutputBuffer_io_lastOutput),
    .io_metadataValid(kvOutputBuffer_io_metadataValid)
  );
  assign io_axi_s_tready = 1'h1; // @[DummyKvPairFifo.scala 33:28]
  assign io_axi_m_tdata = encoder_io_output_axi_m_tdata; // @[DummyKvPairFifo.scala 32:29]
  assign io_axi_m_tvalid = encoder_io_output_axi_m_tvalid; // @[DummyKvPairFifo.scala 32:29]
  assign io_axi_m_tlast = 1'h0; // @[DummyKvPairFifo.scala 32:29]
  assign encoder_clock = clock;
  assign encoder_reset = reset;
  assign encoder_io_input_deq_valid = kvOutputBuffer_io_deq_valid; // @[DummyKvPairFifo.scala 26:26]
  assign encoder_io_input_deq_bits = kvOutputBuffer_io_deq_bits; // @[DummyKvPairFifo.scala 26:26]
  assign encoder_io_input_lastOutput = kvOutputBuffer_io_lastOutput; // @[DummyKvPairFifo.scala 28:33]
  assign encoder_io_input_metadataValid = kvOutputBuffer_io_metadataValid; // @[DummyKvPairFifo.scala 29:36]
  assign encoder_io_output_axi_m_tready = io_axi_m_tready; // @[DummyKvPairFifo.scala 32:29]
  assign decoder_clock = clock;
  assign decoder_reset = reset;
  assign decoder_io_input_axi_s_tdata = io_axi_s_tdata; // @[DummyKvPairFifo.scala 33:28]
  assign decoder_io_input_axi_s_tvalid = io_axi_s_tvalid; // @[DummyKvPairFifo.scala 33:28]
  assign kvOutputBuffer_clock = clock;
  assign kvOutputBuffer_reset = reset;
  assign kvOutputBuffer_io_enq_valid = decoder_io_output_enq_valid; // @[DummyKvPairFifo.scala 36:27]
  assign kvOutputBuffer_io_enq_bits = decoder_io_output_enq_bits; // @[DummyKvPairFifo.scala 36:27]
  assign kvOutputBuffer_io_lastInput = decoder_io_output_lastInput; // @[DummyKvPairFifo.scala 38:33]
  assign kvOutputBuffer_io_isInputKey = decoder_io_output_isInputKey; // @[DummyKvPairFifo.scala 37:34]
  assign kvOutputBuffer_io_deq_ready = encoder_io_input_deq_ready; // @[DummyKvPairFifo.scala 26:26]
endmodule
