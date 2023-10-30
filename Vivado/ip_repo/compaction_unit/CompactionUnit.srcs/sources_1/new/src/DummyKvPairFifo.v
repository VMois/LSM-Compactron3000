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
  input         io_output_enq_ready,
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
  wire  _T_1 = io_input_axi_s_tvalid & io_input_axi_s_tready; // @[DummyDecoder.scala 41:41]
  wire [7:0] _counter_T_1 = counter + 8'h1; // @[DummyDecoder.scala 49:36]
  wire [1:0] _GEN_2 = counter == keyLen ? 2'h2 : state; // @[DummyDecoder.scala 27:24 51:43 52:27]
  wire [7:0] _GEN_3 = counter == keyLen ? 8'h0 : _counter_T_1; // @[DummyDecoder.scala 49:25 51:43 53:29]
  wire  _T_7 = counter == valueLen; // @[DummyDecoder.scala 62:31]
  wire [1:0] _GEN_6 = counter == valueLen ? 2'h0 : state; // @[DummyDecoder.scala 27:24 62:45 63:27]
  wire [7:0] _GEN_7 = counter == valueLen ? 8'h0 : _counter_T_1; // @[DummyDecoder.scala 60:25 62:45 64:29]
  wire [7:0] _GEN_9 = _T_1 ? _GEN_7 : counter; // @[DummyDecoder.scala 32:26 59:67]
  wire [1:0] _GEN_10 = _T_1 ? _GEN_6 : state; // @[DummyDecoder.scala 27:24 59:67]
  wire  _io_output_enq_valid_T_1 = state == 2'h2; // @[DummyDecoder.scala 75:56]
  assign io_input_axi_s_tready = io_output_enq_ready; // @[DummyDecoder.scala 72:47]
  assign io_output_enq_valid = (state == 2'h1 | state == 2'h2) & io_input_axi_s_tvalid; // @[DummyDecoder.scala 75:71]
  assign io_output_enq_bits = io_input_axi_s_tdata; // @[DummyDecoder.scala 76:24]
  assign io_output_lastInput = _io_output_enq_valid_T_1 & _T_7; // @[DummyDecoder.scala 78:48]
  assign io_output_isInputKey = state == 2'h1; // @[DummyDecoder.scala 77:35]
  always @(posedge clock) begin
    if (reset) begin // @[DummyDecoder.scala 27:24]
      state <= 2'h0; // @[DummyDecoder.scala 27:24]
    end else if (2'h0 == state) begin // @[DummyDecoder.scala 39:20]
      if (io_input_axi_s_tvalid & io_input_axi_s_tready) begin // @[DummyDecoder.scala 41:67]
        state <= 2'h1; // @[DummyDecoder.scala 42:23]
      end
    end else if (2'h1 == state) begin // @[DummyDecoder.scala 39:20]
      if (_T_1) begin // @[DummyDecoder.scala 48:67]
        state <= _GEN_2;
      end
    end else if (2'h2 == state) begin // @[DummyDecoder.scala 39:20]
      state <= _GEN_10;
    end
    if (reset) begin // @[DummyDecoder.scala 28:25]
      status <= 32'h0; // @[DummyDecoder.scala 28:25]
    end else if (2'h0 == state) begin // @[DummyDecoder.scala 39:20]
      if (io_input_axi_s_tvalid & io_input_axi_s_tready) begin // @[DummyDecoder.scala 41:67]
        status <= io_input_axi_s_tdata; // @[DummyDecoder.scala 43:24]
      end
    end
    if (reset) begin // @[DummyDecoder.scala 32:26]
      counter <= 8'h0; // @[DummyDecoder.scala 32:26]
    end else if (!(2'h0 == state)) begin // @[DummyDecoder.scala 39:20]
      if (2'h1 == state) begin // @[DummyDecoder.scala 39:20]
        if (_T_1) begin // @[DummyDecoder.scala 48:67]
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
  output        io_enq_ready,
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
  reg [31:0] _RAND_16;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] mem [0:1279]; // @[KvRingBuffer.scala 96:26]
  wire  mem_data_en; // @[KvRingBuffer.scala 185:{24,24} 96:{26,26}]
  reg [10:0] mem_data_addr; // @[KvRingBuffer.scala 96:26]
  wire [31:0] mem_data_data; // @[KvRingBuffer.scala 96:26]
  wire [31:0] mem_MPORT_data; // @[KvRingBuffer.scala 96:26 142:32]
  wire [10:0] mem_MPORT_addr; // @[KvRingBuffer.scala 96:26]
  wire  mem_MPORT_mask; // @[KvRingBuffer.scala 96:26]
  wire  mem_MPORT_en; // @[KvRingBuffer.scala 96:26]
  reg [1:0] readPtr; // @[KvRingBuffer.scala 87:29]
  wire [1:0] _nextVal_T_2 = readPtr + 2'h1; // @[KvRingBuffer.scala 88:63]
  wire [1:0] nextRead = readPtr == 2'h3 ? 2'h0 : _nextVal_T_2; // @[KvRingBuffer.scala 88:26]
  reg [3:0] outputStateReg; // @[KvRingBuffer.scala 134:33]
  wire  _GEN_126 = 4'ha == outputStateReg ? io_deq_ready : 4'hb == outputStateReg & io_deq_ready; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_131 = 4'h9 == outputStateReg ? 1'h0 : _GEN_126; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_137 = 4'h8 == outputStateReg ? 1'h0 : _GEN_131; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_142 = 4'h7 == outputStateReg ? 1'h0 : _GEN_137; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_147 = 4'h6 == outputStateReg ? 1'h0 : _GEN_142; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_153 = 4'h5 == outputStateReg ? 1'h0 : _GEN_147; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_159 = 4'h4 == outputStateReg ? 1'h0 : _GEN_153; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_166 = 4'h3 == outputStateReg ? 1'h0 : _GEN_159; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_174 = 4'h2 == outputStateReg ? 1'h0 : _GEN_166; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_182 = 4'h1 == outputStateReg ? 1'h0 : _GEN_174; // @[KvRingBuffer.scala 188:28]
  wire  incrRead = 4'h0 == outputStateReg ? 1'h0 : _GEN_182; // @[KvRingBuffer.scala 188:28]
  reg [1:0] writePtr; // @[KvRingBuffer.scala 87:29]
  wire [1:0] _nextVal_T_5 = writePtr + 2'h1; // @[KvRingBuffer.scala 88:63]
  wire [1:0] nextWrite = writePtr == 2'h3 ? 2'h0 : _nextVal_T_5; // @[KvRingBuffer.scala 88:26]
  reg [1:0] inputStateReg; // @[KvRingBuffer.scala 133:32]
  wire  _GEN_25 = 2'h1 == inputStateReg ? 1'h0 : 2'h2 == inputStateReg; // @[KvRingBuffer.scala 144:27]
  wire  incrWrite = 2'h0 == inputStateReg ? 1'h0 : _GEN_25; // @[KvRingBuffer.scala 144:27]
  reg [9:0] writeKeyChunkPtr; // @[KvRingBuffer.scala 87:29]
  wire [9:0] _nextVal_T_8 = writeKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 88:63]
  reg [9:0] writeValueChunkPtr; // @[KvRingBuffer.scala 87:29]
  wire [9:0] _nextVal_T_11 = writeValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 88:63]
  reg [9:0] readKeyChunkPtr; // @[KvRingBuffer.scala 87:29]
  wire [9:0] _nextVal_T_14 = readKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 88:63]
  reg [9:0] readValueChunkPtr; // @[KvRingBuffer.scala 87:29]
  wire [9:0] _nextVal_T_17 = readValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 88:63]
  reg [31:0] keyLen; // @[KvRingBuffer.scala 120:25]
  reg [31:0] valueLen; // @[KvRingBuffer.scala 121:27]
  reg  emptyReg; // @[KvRingBuffer.scala 123:27]
  reg  fullReg; // @[KvRingBuffer.scala 124:26]
  reg [31:0] writeReg; // @[KvRingBuffer.scala 136:27]
  wire  _writeDataPtr_T = inputStateReg == 2'h0; // @[KvRingBuffer.scala 139:42]
  wire [2:0] _writeDataPtr_T_1 = io_isInputKey ? 3'h2 : 3'h6; // @[KvRingBuffer.scala 139:60]
  wire [9:0] _writeDataPtr_T_2 = io_isInputKey ? writeKeyChunkPtr : writeValueChunkPtr; // @[KvRingBuffer.scala 139:152]
  wire [9:0] _GEN_191 = {{7'd0}, _writeDataPtr_T_1}; // @[KvRingBuffer.scala 139:147]
  wire [9:0] _writeDataPtr_T_4 = _GEN_191 + _writeDataPtr_T_2; // @[KvRingBuffer.scala 139:147]
  wire [9:0] writeDataPtr = inputStateReg == 2'h0 ? _writeDataPtr_T_4 : 10'h0; // @[KvRingBuffer.scala 139:27]
  wire  metadataOffsetPtr = inputStateReg == 2'h2; // @[KvRingBuffer.scala 140:47]
  wire [5:0] _writeFullPtr_T = writePtr * 4'ha; // @[KvRingBuffer.scala 141:33]
  wire [9:0] _GEN_192 = {{4'd0}, _writeFullPtr_T}; // @[KvRingBuffer.scala 141:42]
  wire [9:0] _writeFullPtr_T_2 = _GEN_192 + writeDataPtr; // @[KvRingBuffer.scala 141:42]
  wire [9:0] _GEN_193 = {{9'd0}, metadataOffsetPtr}; // @[KvRingBuffer.scala 141:57]
  wire [9:0] writeFullPtr = _writeFullPtr_T_2 + _GEN_193; // @[KvRingBuffer.scala 141:57]
  wire  _T_3 = ~fullReg; // @[KvRingBuffer.scala 146:34]
  wire [1:0] _GEN_6 = io_lastInput ? 2'h1 : inputStateReg; // @[KvRingBuffer.scala 133:32 151:40 152:39]
  wire [31:0] _GEN_7 = io_lastInput ? {{22'd0}, writeKeyChunkPtr} : writeReg; // @[KvRingBuffer.scala 136:27 151:40 153:34]
  wire  _GEN_16 = 2'h2 == inputStateReg ? 1'h0 : emptyReg; // @[KvRingBuffer.scala 144:27 165:22 123:27]
  wire  _GEN_24 = 2'h1 == inputStateReg ? emptyReg : _GEN_16; // @[KvRingBuffer.scala 123:27 144:27]
  wire  _GEN_33 = 2'h0 == inputStateReg ? emptyReg : _GEN_24; // @[KvRingBuffer.scala 123:27 144:27]
  wire [5:0] _readFullPtr_T = readPtr * 4'ha; // @[KvRingBuffer.scala 184:31]
  wire [9:0] _GEN_194 = {{4'd0}, _readFullPtr_T}; // @[KvRingBuffer.scala 184:40]
  wire [9:0] _readFullPtr_T_2 = _GEN_194 + readValueChunkPtr; // @[KvRingBuffer.scala 184:40]
  wire [9:0] readFullPtr = _readFullPtr_T_2 + readKeyChunkPtr; // @[KvRingBuffer.scala 184:60]
  reg [31:0] shadowReg; // @[KvRingBuffer.scala 186:28]
  wire [31:0] _GEN_48 = mem_data_data; // @[KvRingBuffer.scala 206:42 207:24 120:25]
  wire [9:0] _GEN_52 = keyLen == 32'h1 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 219:38 221:39]
  wire [2:0] _GEN_53 = keyLen == 32'h1 ? 3'h6 : 3'h1; // @[KvRingBuffer.scala 219:38 222:37 227:37]
  wire [3:0] _GEN_54 = keyLen == 32'h1 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 219:38 224:36 228:36]
  wire [9:0] _GEN_56 = {{7'd0}, _GEN_53}; // @[KvRingBuffer.scala 218:42]
  wire [31:0] _T_21 = keyLen - 32'h1; // @[KvRingBuffer.scala 236:54]
  wire [31:0] _GEN_195 = {{22'd0}, readKeyChunkPtr}; // @[KvRingBuffer.scala 236:43]
  wire  _T_22 = _GEN_195 == _T_21; // @[KvRingBuffer.scala 236:43]
  wire  _emptyReg_T = nextRead == writePtr; // @[KvRingBuffer.scala 238:46]
  wire [3:0] _GEN_58 = _GEN_195 == _T_21 ? 4'h6 : outputStateReg; // @[KvRingBuffer.scala 236:61 237:40]
  wire  _GEN_59 = _GEN_195 == _T_21 ? nextRead == writePtr : _GEN_33; // @[KvRingBuffer.scala 236:61 238:34]
  wire [9:0] _GEN_60 = _GEN_195 == _T_21 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 236:61 239:43]
  wire [9:0] _GEN_61 = _GEN_195 == _T_21 ? 10'h6 : _nextVal_T_14; // @[KvRingBuffer.scala 236:61 240:41 242:41]
  wire [3:0] _GEN_62 = io_deq_ready ? _GEN_58 : 4'h5; // @[KvRingBuffer.scala 235:36 247:36]
  wire  _GEN_63 = io_deq_ready ? _GEN_59 : _GEN_33; // @[KvRingBuffer.scala 235:36]
  wire [9:0] _GEN_64 = io_deq_ready ? _GEN_60 : readValueChunkPtr; // @[KvRingBuffer.scala 235:36]
  wire [9:0] _GEN_65 = io_deq_ready ? _GEN_61 : readKeyChunkPtr; // @[KvRingBuffer.scala 235:36]
  wire [31:0] _GEN_66 = io_deq_ready ? shadowReg : mem_data_data; // @[KvRingBuffer.scala 186:28 235:36 246:31]
  wire [3:0] _GEN_72 = _T_22 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 254:57 255:36 260:36]
  wire [3:0] _GEN_76 = io_deq_ready ? _GEN_72 : outputStateReg; // @[KvRingBuffer.scala 253:57]
  wire [3:0] _GEN_80 = valueLen == 32'h1 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 272:48 273:44 275:44]
  wire [9:0] _GEN_81 = valueLen == 32'h1 ? readValueChunkPtr : 10'h1; // @[KvRingBuffer.scala 272:48 276:47]
  wire [3:0] _GEN_84 = io_deq_ready ? _GEN_80 : 4'h7; // @[KvRingBuffer.scala 268:36 281:36]
  wire [9:0] _GEN_85 = io_deq_ready ? _GEN_81 : readValueChunkPtr; // @[KvRingBuffer.scala 268:36]
  wire [3:0] _GEN_93 = io_deq_ready ? _GEN_80 : outputStateReg; // @[KvRingBuffer.scala 287:57]
  wire [31:0] _T_39 = valueLen - 32'h1; // @[KvRingBuffer.scala 304:57]
  wire [31:0] _GEN_197 = {{22'd0}, readValueChunkPtr}; // @[KvRingBuffer.scala 304:44]
  wire  _T_40 = _GEN_197 == _T_39; // @[KvRingBuffer.scala 304:44]
  wire [3:0] _GEN_95 = _GEN_197 == _T_39 ? 4'ha : outputStateReg; // @[KvRingBuffer.scala 304:64 305:40]
  wire  _GEN_96 = _GEN_197 == _T_39 ? _emptyReg_T : _GEN_33; // @[KvRingBuffer.scala 304:64 309:34]
  wire [9:0] _GEN_97 = _GEN_197 == _T_39 ? readValueChunkPtr : _nextVal_T_17; // @[KvRingBuffer.scala 304:64 311:43]
  wire [3:0] _GEN_98 = io_deq_ready ? _GEN_95 : 4'h9; // @[KvRingBuffer.scala 303:36 316:36]
  wire  _GEN_99 = io_deq_ready ? _GEN_96 : _GEN_33; // @[KvRingBuffer.scala 303:36]
  wire [9:0] _GEN_100 = io_deq_ready ? _GEN_97 : readValueChunkPtr; // @[KvRingBuffer.scala 303:36]
  wire [3:0] _GEN_105 = _T_40 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 323:60 324:36 330:36]
  wire [3:0] _GEN_108 = io_deq_ready ? _GEN_105 : outputStateReg; // @[KvRingBuffer.scala 322:57]
  wire [3:0] _GEN_111 = io_deq_ready ? 4'h0 : 4'hb; // @[KvRingBuffer.scala 338:36 339:36 347:36]
  wire  _GEN_112 = io_deq_ready ? _emptyReg_T : _GEN_33; // @[KvRingBuffer.scala 338:36 340:30]
  wire [3:0] _GEN_118 = io_deq_ready ? 4'h0 : outputStateReg; // @[KvRingBuffer.scala 353:57 354:32]
  wire [3:0] _GEN_121 = 4'hb == outputStateReg ? _GEN_118 : outputStateReg; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_122 = 4'hb == outputStateReg ? _GEN_112 : _GEN_33; // @[KvRingBuffer.scala 188:28]
  wire [3:0] _GEN_124 = 4'ha == outputStateReg ? _GEN_111 : _GEN_121; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_125 = 4'ha == outputStateReg ? _GEN_112 : _GEN_122; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_127 = 4'ha == outputStateReg ? _GEN_66 : shadowReg; // @[KvRingBuffer.scala 186:28 188:28]
  wire [3:0] _GEN_128 = 4'h9 == outputStateReg ? _GEN_108 : _GEN_124; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_129 = 4'h9 == outputStateReg ? _GEN_99 : _GEN_125; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_130 = 4'h9 == outputStateReg ? _GEN_100 : readValueChunkPtr; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_132 = 4'h9 == outputStateReg ? shadowReg : _GEN_127; // @[KvRingBuffer.scala 186:28 188:28]
  wire [3:0] _GEN_133 = 4'h8 == outputStateReg ? _GEN_98 : _GEN_128; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_134 = 4'h8 == outputStateReg ? _GEN_99 : _GEN_129; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_135 = 4'h8 == outputStateReg ? _GEN_100 : _GEN_130; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_136 = 4'h8 == outputStateReg ? _GEN_66 : _GEN_132; // @[KvRingBuffer.scala 188:28]
  wire [3:0] _GEN_138 = 4'h7 == outputStateReg ? _GEN_93 : _GEN_133; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_139 = 4'h7 == outputStateReg ? _GEN_85 : _GEN_135; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_140 = 4'h7 == outputStateReg ? _GEN_33 : _GEN_134; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_141 = 4'h7 == outputStateReg ? shadowReg : _GEN_136; // @[KvRingBuffer.scala 186:28 188:28]
  wire [3:0] _GEN_143 = 4'h6 == outputStateReg ? _GEN_84 : _GEN_138; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_144 = 4'h6 == outputStateReg ? _GEN_85 : _GEN_139; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_145 = 4'h6 == outputStateReg ? _GEN_66 : _GEN_141; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_146 = 4'h6 == outputStateReg ? _GEN_33 : _GEN_140; // @[KvRingBuffer.scala 188:28]
  wire [3:0] _GEN_148 = 4'h5 == outputStateReg ? _GEN_76 : _GEN_143; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_149 = 4'h5 == outputStateReg ? _GEN_63 : _GEN_146; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_150 = 4'h5 == outputStateReg ? _GEN_64 : _GEN_144; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_151 = 4'h5 == outputStateReg ? _GEN_65 : readKeyChunkPtr; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_152 = 4'h5 == outputStateReg ? shadowReg : _GEN_145; // @[KvRingBuffer.scala 186:28 188:28]
  wire [3:0] _GEN_154 = 4'h4 == outputStateReg ? _GEN_62 : _GEN_148; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_155 = 4'h4 == outputStateReg ? _GEN_63 : _GEN_149; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_156 = 4'h4 == outputStateReg ? _GEN_64 : _GEN_150; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_157 = 4'h4 == outputStateReg ? _GEN_65 : _GEN_151; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_158 = 4'h4 == outputStateReg ? _GEN_66 : _GEN_152; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_160 = 4'h3 == outputStateReg ? mem_data_data : valueLen; // @[KvRingBuffer.scala 188:28 217:22 121:27]
  wire [9:0] _GEN_161 = 4'h3 == outputStateReg ? _GEN_52 : _GEN_156; // @[KvRingBuffer.scala 188:28]
  wire [9:0] _GEN_162 = 4'h3 == outputStateReg ? _GEN_56 : _GEN_157; // @[KvRingBuffer.scala 188:28]
  wire [3:0] _GEN_163 = 4'h3 == outputStateReg ? _GEN_54 : _GEN_154; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_164 = 4'h3 == outputStateReg ? _GEN_33 : _GEN_155; // @[KvRingBuffer.scala 188:28]
  wire [31:0] _GEN_165 = 4'h3 == outputStateReg ? shadowReg : _GEN_158; // @[KvRingBuffer.scala 186:28 188:28]
  wire  _GEN_172 = 4'h2 == outputStateReg ? _GEN_33 : _GEN_164; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_180 = 4'h1 == outputStateReg ? _GEN_33 : _GEN_172; // @[KvRingBuffer.scala 188:28]
  wire  _GEN_188 = 4'h0 == outputStateReg ? _GEN_33 : _GEN_180; // @[KvRingBuffer.scala 188:28]
  wire  _io_deq_valid_T_3 = outputStateReg == 4'h5; // @[KvRingBuffer.scala 365:111]
  wire  _io_deq_valid_T_5 = outputStateReg == 4'h7; // @[KvRingBuffer.scala 365:148]
  wire  _io_deq_valid_T_9 = outputStateReg == 4'ha; // @[KvRingBuffer.scala 365:232]
  wire  _io_deq_valid_T_11 = outputStateReg == 4'h9; // @[KvRingBuffer.scala 365:273]
  wire  _io_deq_valid_T_13 = outputStateReg == 4'hb; // @[KvRingBuffer.scala 365:312]
  assign mem_data_en = 1'h1; // @[KvRingBuffer.scala 185:{24,24} 96:26]
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_data_data = mem[mem_data_addr]; // @[KvRingBuffer.scala 96:26]
  `else
  assign mem_data_data = mem_data_addr >= 11'h500 ? _RAND_2[31:0] : mem[mem_data_addr]; // @[KvRingBuffer.scala 96:26]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_MPORT_data = _writeDataPtr_T ? io_enq_bits : writeReg; // @[KvRingBuffer.scala 142:32]
  assign mem_MPORT_addr = {{1'd0}, writeFullPtr};
  assign mem_MPORT_mask = 1'h1;
  assign mem_MPORT_en = 1'h1;
  assign io_enq_ready = _writeDataPtr_T & _T_3; // @[KvRingBuffer.scala 364:51]
  assign io_deq_valid = outputStateReg == 4'h4 | outputStateReg == 4'h6 | outputStateReg == 4'h5 | outputStateReg == 4'h7
     | outputStateReg == 4'h8 | outputStateReg == 4'ha | outputStateReg == 4'h9 | outputStateReg == 4'hb; // @[KvRingBuffer.scala 365:294]
  assign io_deq_bits = _io_deq_valid_T_3 | _io_deq_valid_T_5 | _io_deq_valid_T_11 | _io_deq_valid_T_13 ? shadowReg :
    mem_data_data; // @[KvRingBuffer.scala 366:23]
  assign io_lastOutput = _io_deq_valid_T_9 | _io_deq_valid_T_13; // @[KvRingBuffer.scala 368:61]
  assign io_metadataValid = outputStateReg == 4'h2 | outputStateReg == 4'h3; // @[KvRingBuffer.scala 372:61]
  always @(posedge clock) begin
    if (mem_data_en) begin
      mem_data_addr <= {{1'd0}, readFullPtr}; // @[KvRingBuffer.scala 185:24]
    end
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[KvRingBuffer.scala 96:26]
    end
    if (reset) begin // @[KvRingBuffer.scala 87:29]
      readPtr <= 2'h0; // @[KvRingBuffer.scala 87:29]
    end else if (incrRead) begin // @[KvRingBuffer.scala 89:21]
      if (readPtr == 2'h3) begin // @[KvRingBuffer.scala 88:26]
        readPtr <= 2'h0;
      end else begin
        readPtr <= _nextVal_T_2;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 134:33]
      outputStateReg <= 4'h0; // @[KvRingBuffer.scala 134:33]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 190:54]
        outputStateReg <= 4'h1; // @[KvRingBuffer.scala 193:32]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      outputStateReg <= 4'h2;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      outputStateReg <= 4'h3;
    end else begin
      outputStateReg <= _GEN_163;
    end
    if (reset) begin // @[KvRingBuffer.scala 87:29]
      writePtr <= 2'h0; // @[KvRingBuffer.scala 87:29]
    end else if (incrWrite) begin // @[KvRingBuffer.scala 89:21]
      if (writePtr == 2'h3) begin // @[KvRingBuffer.scala 88:26]
        writePtr <= 2'h0;
      end else begin
        writePtr <= _nextVal_T_5;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 133:32]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 133:32]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 146:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 147:38]
          inputStateReg <= _GEN_6;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      inputStateReg <= 2'h2; // @[KvRingBuffer.scala 160:27]
    end else if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 170:27]
    end
    if (reset) begin // @[KvRingBuffer.scala 87:29]
      writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 87:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 146:44]
        if (io_isInputKey) begin // @[KvRingBuffer.scala 147:38]
          writeKeyChunkPtr <= _nextVal_T_8; // @[KvRingBuffer.scala 148:38]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 144:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
        writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 171:30]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 87:29]
      writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 87:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 146:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 147:38]
          writeValueChunkPtr <= _nextVal_T_11; // @[KvRingBuffer.scala 150:40]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 144:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
        writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 172:32]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 87:29]
      readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 87:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 190:54]
        readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 191:33]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      readKeyChunkPtr <= 10'h1;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      readKeyChunkPtr <= 10'h0;
    end else begin
      readKeyChunkPtr <= _GEN_162;
    end
    if (reset) begin // @[KvRingBuffer.scala 87:29]
      readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 87:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 190:54]
        readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 192:35]
      end
    end else if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
      if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
        readValueChunkPtr <= 10'h2;
      end else begin
        readValueChunkPtr <= _GEN_161;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 120:25]
      keyLen <= 32'h0; // @[KvRingBuffer.scala 120:25]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
        if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 188:28]
          keyLen <= _GEN_48;
        end
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 121:27]
      valueLen <= 32'h0; // @[KvRingBuffer.scala 121:27]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
          valueLen <= _GEN_160;
        end
      end
    end
    emptyReg <= reset | _GEN_188; // @[KvRingBuffer.scala 123:{27,27}]
    if (reset) begin // @[KvRingBuffer.scala 124:26]
      fullReg <= 1'h0; // @[KvRingBuffer.scala 124:26]
    end else if (!(2'h0 == inputStateReg)) begin // @[KvRingBuffer.scala 144:27]
      if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 144:27]
        if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
          fullReg <= nextWrite == readPtr; // @[KvRingBuffer.scala 167:21]
        end
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 136:27]
      writeReg <= 32'h0; // @[KvRingBuffer.scala 136:27]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 146:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 147:38]
          writeReg <= _GEN_7;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 144:27]
      writeReg <= {{22'd0}, writeValueChunkPtr}; // @[KvRingBuffer.scala 161:22]
    end
    if (reset) begin // @[KvRingBuffer.scala 186:28]
      shadowReg <= 32'h0; // @[KvRingBuffer.scala 186:28]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 188:28]
          shadowReg <= _GEN_165;
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
  writeReg = _RAND_15[31:0];
  _RAND_16 = {1{`RANDOM}};
  shadowReg = _RAND_16[31:0];
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
  wire  decoder_io_output_enq_ready; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_output_enq_valid; // @[DummyKvPairFifo.scala 17:25]
  wire [31:0] decoder_io_output_enq_bits; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_output_lastInput; // @[DummyKvPairFifo.scala 17:25]
  wire  decoder_io_output_isInputKey; // @[DummyKvPairFifo.scala 17:25]
  wire  kvOutputBuffer_clock; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_reset; // @[DummyKvPairFifo.scala 18:32]
  wire  kvOutputBuffer_io_enq_ready; // @[DummyKvPairFifo.scala 18:32]
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
    .io_output_enq_ready(decoder_io_output_enq_ready),
    .io_output_enq_valid(decoder_io_output_enq_valid),
    .io_output_enq_bits(decoder_io_output_enq_bits),
    .io_output_lastInput(decoder_io_output_lastInput),
    .io_output_isInputKey(decoder_io_output_isInputKey)
  );
  KVRingBuffer kvOutputBuffer ( // @[DummyKvPairFifo.scala 18:32]
    .clock(kvOutputBuffer_clock),
    .reset(kvOutputBuffer_reset),
    .io_enq_ready(kvOutputBuffer_io_enq_ready),
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
  assign io_axi_s_tready = decoder_io_input_axi_s_tready; // @[DummyKvPairFifo.scala 33:28]
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
  assign decoder_io_output_enq_ready = kvOutputBuffer_io_enq_ready; // @[DummyKvPairFifo.scala 36:27]
  assign kvOutputBuffer_clock = clock;
  assign kvOutputBuffer_reset = reset;
  assign kvOutputBuffer_io_enq_valid = decoder_io_output_enq_valid; // @[DummyKvPairFifo.scala 36:27]
  assign kvOutputBuffer_io_enq_bits = decoder_io_output_enq_bits; // @[DummyKvPairFifo.scala 36:27]
  assign kvOutputBuffer_io_lastInput = decoder_io_output_lastInput; // @[DummyKvPairFifo.scala 38:33]
  assign kvOutputBuffer_io_isInputKey = decoder_io_output_isInputKey; // @[DummyKvPairFifo.scala 37:34]
  assign kvOutputBuffer_io_deq_ready = encoder_io_input_deq_ready; // @[DummyKvPairFifo.scala 26:26]
endmodule
