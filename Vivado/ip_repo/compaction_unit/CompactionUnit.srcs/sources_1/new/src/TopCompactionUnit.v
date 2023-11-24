module DummyEncoder(
  input         clock,
  input         reset,
  input         io_control_lastDataIsProcessed,
  output        io_input_deq_ready,
  input         io_input_deq_valid,
  input  [31:0] io_input_deq_bits,
  input         io_input_lastOutput,
  input         io_input_metadataValid,
  output [31:0] io_output_axi_m_tdata,
  output        io_output_axi_m_tvalid,
  input         io_output_axi_m_tready,
  output        io_output_axi_m_tlast
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state; // @[DummyEncoder.scala 29:24]
  reg [31:0] status; // @[DummyEncoder.scala 30:25]
  wire [31:0] _status_T_3 = {status[31:16],io_input_deq_bits[7:0],status[7:0]}; // @[Cat.scala 33:92]
  wire [31:0] _status_T_7 = {status[31:24],io_input_deq_bits[7:0],status[15:0]}; // @[Cat.scala 33:92]
  wire [1:0] _GEN_3 = io_output_axi_m_tready ? 2'h3 : state; // @[DummyEncoder.scala 48:43 49:23 29:24]
  wire [1:0] _GEN_4 = io_input_lastOutput & io_output_axi_m_tready ? 2'h0 : state; // @[DummyEncoder.scala 54:66 55:23 29:24]
  wire [1:0] _GEN_5 = 2'h3 == state ? _GEN_4 : state; // @[DummyEncoder.scala 32:20 29:24]
  wire  _io_output_axi_m_tdata_T = state == 2'h2; // @[DummyEncoder.scala 61:40]
  assign io_input_deq_ready = state == 2'h3 & io_output_axi_m_tready; // @[DummyEncoder.scala 60:48]
  assign io_output_axi_m_tdata = state == 2'h2 ? status : io_input_deq_bits; // @[DummyEncoder.scala 61:33]
  assign io_output_axi_m_tvalid = _io_output_axi_m_tdata_T | io_input_deq_valid | io_output_axi_m_tlast; // @[DummyEncoder.scala 62:75]
  assign io_output_axi_m_tlast = state == 2'h0 & io_control_lastDataIsProcessed; // @[DummyEncoder.scala 63:45]
  always @(posedge clock) begin
    if (reset) begin // @[DummyEncoder.scala 29:24]
      state <= 2'h0; // @[DummyEncoder.scala 29:24]
    end else if (2'h0 == state) begin // @[DummyEncoder.scala 32:20]
      if (io_input_metadataValid) begin // @[DummyEncoder.scala 34:43]
        state <= 2'h1; // @[DummyEncoder.scala 36:23]
      end
    end else if (2'h1 == state) begin // @[DummyEncoder.scala 32:20]
      state <= 2'h2; // @[DummyEncoder.scala 44:19]
    end else if (2'h2 == state) begin // @[DummyEncoder.scala 32:20]
      state <= _GEN_3;
    end else begin
      state <= _GEN_5;
    end
    if (reset) begin // @[DummyEncoder.scala 30:25]
      status <= 32'h0; // @[DummyEncoder.scala 30:25]
    end else if (2'h0 == state) begin // @[DummyEncoder.scala 32:20]
      if (io_input_metadataValid) begin // @[DummyEncoder.scala 34:43]
        status <= _status_T_3; // @[DummyEncoder.scala 35:24]
      end
    end else if (2'h1 == state) begin // @[DummyEncoder.scala 32:20]
      if (io_input_metadataValid) begin // @[DummyEncoder.scala 41:43]
        status <= _status_T_7; // @[DummyEncoder.scala 42:24]
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
  output        io_output_isInputKey,
  output        io_control_lastKvPairSeen
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state; // @[DummyDecoder.scala 30:24]
  reg [31:0] status; // @[DummyDecoder.scala 31:25]
  reg  lastSeen; // @[DummyDecoder.scala 32:27]
  reg [7:0] counter; // @[DummyDecoder.scala 35:26]
  wire [7:0] keyLen = status[15:8] - 8'h1; // @[DummyDecoder.scala 38:32]
  wire [7:0] valueLen = status[23:16] - 8'h1; // @[DummyDecoder.scala 39:35]
  wire  isLastKvPair = status[0]; // @[DummyDecoder.scala 40:30]
  wire  _T_1 = io_input_axi_s_tvalid & io_input_axi_s_tready; // @[DummyDecoder.scala 44:41]
  wire [7:0] _counter_T_1 = counter + 8'h1; // @[DummyDecoder.scala 52:36]
  wire [1:0] _GEN_2 = counter == keyLen ? 2'h2 : state; // @[DummyDecoder.scala 30:24 54:43 55:27]
  wire [7:0] _GEN_3 = counter == keyLen ? 8'h0 : _counter_T_1; // @[DummyDecoder.scala 52:25 54:43 56:29]
  wire  _T_7 = counter == valueLen; // @[DummyDecoder.scala 65:31]
  wire [1:0] _GEN_6 = counter == valueLen ? 2'h0 : state; // @[DummyDecoder.scala 30:24 65:45 66:27]
  wire [7:0] _GEN_7 = counter == valueLen ? 8'h0 : _counter_T_1; // @[DummyDecoder.scala 63:25 65:45 67:29]
  wire  _GEN_8 = counter == valueLen ? isLastKvPair : lastSeen; // @[DummyDecoder.scala 32:27 65:45 68:30]
  wire [7:0] _GEN_9 = _T_1 ? _GEN_7 : counter; // @[DummyDecoder.scala 35:26 62:67]
  wire [1:0] _GEN_10 = _T_1 ? _GEN_6 : state; // @[DummyDecoder.scala 30:24 62:67]
  wire  _GEN_11 = _T_1 ? _GEN_8 : lastSeen; // @[DummyDecoder.scala 32:27 62:67]
  wire  _io_output_enq_valid_T_1 = state == 2'h2; // @[DummyDecoder.scala 78:56]
  assign io_input_axi_s_tready = io_output_enq_ready; // @[DummyDecoder.scala 75:55]
  assign io_output_enq_valid = (state == 2'h1 | state == 2'h2) & io_input_axi_s_tvalid; // @[DummyDecoder.scala 78:71]
  assign io_output_enq_bits = io_input_axi_s_tdata; // @[DummyDecoder.scala 79:24]
  assign io_output_lastInput = _io_output_enq_valid_T_1 & _T_7; // @[DummyDecoder.scala 81:48]
  assign io_output_isInputKey = state == 2'h1; // @[DummyDecoder.scala 80:35]
  assign io_control_lastKvPairSeen = lastSeen; // @[DummyDecoder.scala 76:31]
  always @(posedge clock) begin
    if (reset) begin // @[DummyDecoder.scala 30:24]
      state <= 2'h0; // @[DummyDecoder.scala 30:24]
    end else if (2'h0 == state) begin // @[DummyDecoder.scala 42:20]
      if (io_input_axi_s_tvalid & io_input_axi_s_tready) begin // @[DummyDecoder.scala 44:84]
        state <= 2'h1; // @[DummyDecoder.scala 45:23]
      end
    end else if (2'h1 == state) begin // @[DummyDecoder.scala 42:20]
      if (_T_1) begin // @[DummyDecoder.scala 51:67]
        state <= _GEN_2;
      end
    end else if (2'h2 == state) begin // @[DummyDecoder.scala 42:20]
      state <= _GEN_10;
    end
    if (reset) begin // @[DummyDecoder.scala 31:25]
      status <= 32'h0; // @[DummyDecoder.scala 31:25]
    end else if (2'h0 == state) begin // @[DummyDecoder.scala 42:20]
      if (io_input_axi_s_tvalid & io_input_axi_s_tready) begin // @[DummyDecoder.scala 44:84]
        status <= io_input_axi_s_tdata; // @[DummyDecoder.scala 46:24]
      end
    end
    if (reset) begin // @[DummyDecoder.scala 32:27]
      lastSeen <= 1'h0; // @[DummyDecoder.scala 32:27]
    end else if (!(2'h0 == state)) begin // @[DummyDecoder.scala 42:20]
      if (!(2'h1 == state)) begin // @[DummyDecoder.scala 42:20]
        if (2'h2 == state) begin // @[DummyDecoder.scala 42:20]
          lastSeen <= _GEN_11;
        end
      end
    end
    if (reset) begin // @[DummyDecoder.scala 35:26]
      counter <= 8'h0; // @[DummyDecoder.scala 35:26]
    end else if (!(2'h0 == state)) begin // @[DummyDecoder.scala 42:20]
      if (2'h1 == state) begin // @[DummyDecoder.scala 42:20]
        if (_T_1) begin // @[DummyDecoder.scala 51:67]
          counter <= _GEN_3;
        end
      end else if (2'h2 == state) begin // @[DummyDecoder.scala 42:20]
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
  lastSeen = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  counter = _RAND_3[7:0];
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
  input         io_control_moveReadPtr,
  input         io_control_resetRead,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits,
  input         io_outputKeyOnly,
  output        io_lastOutput,
  output        io_isOutputKey,
  output        io_status_empty,
  output        io_status_full,
  output        io_status_halfFull
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
  reg [31:0] mem [0:10943]; // @[KvRingBuffer.scala 103:26]
  wire  mem_data_en; // @[KvRingBuffer.scala 103:26 205:{24,24} 103:26]
  reg [13:0] mem_data_addr; // @[KvRingBuffer.scala 103:26]
  wire [31:0] mem_data_data; // @[KvRingBuffer.scala 103:26]
  wire [31:0] mem_MPORT_data; // @[KvRingBuffer.scala 103:26 153:36]
  wire [13:0] mem_MPORT_addr; // @[KvRingBuffer.scala 103:26]
  wire  mem_MPORT_mask; // @[KvRingBuffer.scala 103:26 152:101]
  wire  mem_MPORT_en; // @[KvRingBuffer.scala 103:26 152:61]
  reg [3:0] readPtr; // @[KvRingBuffer.scala 94:29]
  wire [3:0] _nextVal_T_2 = readPtr + 4'h1; // @[KvRingBuffer.scala 95:63]
  wire [3:0] nextRead = readPtr == 4'h8 ? 4'h0 : _nextVal_T_2; // @[KvRingBuffer.scala 95:26]
  wire  moveOrResetRequested = io_control_moveReadPtr | io_control_resetRead; // @[KvRingBuffer.scala 196:55]
  wire  incrRead = moveOrResetRequested & io_control_moveReadPtr; // @[KvRingBuffer.scala 197:33]
  reg [3:0] writePtr; // @[KvRingBuffer.scala 94:29]
  wire [3:0] _nextVal_T_5 = writePtr + 4'h1; // @[KvRingBuffer.scala 95:63]
  wire [3:0] nextWrite = writePtr == 4'h8 ? 4'h0 : _nextVal_T_5; // @[KvRingBuffer.scala 95:26]
  reg [1:0] inputStateReg; // @[KvRingBuffer.scala 142:32]
  wire  _GEN_31 = 2'h1 == inputStateReg ? 1'h0 : 2'h2 == inputStateReg; // @[KvRingBuffer.scala 156:27]
  wire  incrWrite = 2'h0 == inputStateReg ? 1'h0 : _GEN_31; // @[KvRingBuffer.scala 156:27]
  reg [9:0] writeKeyChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_8 = writeKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [9:0] writeValueChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_11 = writeValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [9:0] readKeyChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_14 = readKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [9:0] readValueChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_17 = readValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [31:0] keyLen; // @[KvRingBuffer.scala 127:25]
  reg [31:0] valueLen; // @[KvRingBuffer.scala 128:27]
  reg  emptyReg; // @[KvRingBuffer.scala 130:27]
  reg  fullReg; // @[KvRingBuffer.scala 131:26]
  wire [3:0] _distanceBetweenPtrs_T_2 = writePtr - readPtr; // @[KvRingBuffer.scala 134:65]
  wire [3:0] _distanceBetweenPtrs_T_4 = 4'h9 - readPtr; // @[KvRingBuffer.scala 134:84]
  wire [3:0] _distanceBetweenPtrs_T_6 = _distanceBetweenPtrs_T_4 + writePtr; // @[KvRingBuffer.scala 134:94]
  wire [3:0] distanceBetweenPtrs = writePtr >= readPtr ? _distanceBetweenPtrs_T_2 : _distanceBetweenPtrs_T_6; // @[KvRingBuffer.scala 134:34]
  reg [3:0] outputStateReg; // @[KvRingBuffer.scala 143:33]
  reg [31:0] writeReg; // @[KvRingBuffer.scala 145:27]
  wire  _writeDataPtr_T = inputStateReg == 2'h0; // @[KvRingBuffer.scala 148:42]
  wire [3:0] _writeDataPtr_T_1 = io_isInputKey ? 4'h2 : 4'ha; // @[KvRingBuffer.scala 148:60]
  wire [9:0] _writeDataPtr_T_2 = io_isInputKey ? writeKeyChunkPtr : writeValueChunkPtr; // @[KvRingBuffer.scala 148:152]
  wire [9:0] _GEN_161 = {{6'd0}, _writeDataPtr_T_1}; // @[KvRingBuffer.scala 148:147]
  wire [9:0] _writeDataPtr_T_4 = _GEN_161 + _writeDataPtr_T_2; // @[KvRingBuffer.scala 148:147]
  wire [9:0] writeDataPtr = inputStateReg == 2'h0 ? _writeDataPtr_T_4 : 10'h0; // @[KvRingBuffer.scala 148:27]
  wire  metadataOffsetPtr = inputStateReg == 2'h2; // @[KvRingBuffer.scala 149:47]
  wire [9:0] _writeFullPtr_T = writePtr * 6'h26; // @[KvRingBuffer.scala 150:33]
  wire [9:0] _writeFullPtr_T_2 = _writeFullPtr_T + writeDataPtr; // @[KvRingBuffer.scala 150:42]
  wire [9:0] _GEN_162 = {{9'd0}, metadataOffsetPtr}; // @[KvRingBuffer.scala 150:57]
  wire [9:0] writeFullPtr = _writeFullPtr_T_2 + _GEN_162; // @[KvRingBuffer.scala 150:57]
  wire  _T = inputStateReg == 2'h1; // @[KvRingBuffer.scala 152:41]
  wire  _T_7 = ~fullReg; // @[KvRingBuffer.scala 158:34]
  wire [1:0] _GEN_11 = io_lastInput ? 2'h1 : inputStateReg; // @[KvRingBuffer.scala 142:32 163:40 164:39]
  wire [31:0] _GEN_12 = io_lastInput ? {{22'd0}, writeKeyChunkPtr} : writeReg; // @[KvRingBuffer.scala 145:27 163:40 165:34]
  wire  _GEN_13 = io_lastInput ? 1'h0 : emptyReg; // @[KvRingBuffer.scala 130:27 163:40 166:34]
  wire  _GEN_18 = io_isInputKey ? emptyReg : _GEN_13; // @[KvRingBuffer.scala 130:27 159:38]
  wire  _GEN_23 = io_enq_valid & ~fullReg ? _GEN_18 : emptyReg; // @[KvRingBuffer.scala 130:27 158:44]
  wire  _GEN_25 = 2'h2 == inputStateReg ? nextWrite == readPtr : fullReg; // @[KvRingBuffer.scala 156:27 179:21 131:26]
  wire  _GEN_32 = 2'h1 == inputStateReg ? fullReg : _GEN_25; // @[KvRingBuffer.scala 131:26 156:27]
  wire  _GEN_39 = 2'h0 == inputStateReg ? _GEN_23 : emptyReg; // @[KvRingBuffer.scala 130:27 156:27]
  wire  _GEN_41 = 2'h0 == inputStateReg ? fullReg : _GEN_32; // @[KvRingBuffer.scala 131:26 156:27]
  wire  writeIsIncoming = _T | metadataOffsetPtr; // @[KvRingBuffer.scala 188:62]
  wire  _GEN_43 = io_control_moveReadPtr ? nextRead == writePtr & ~writeIsIncoming : _GEN_39; // @[KvRingBuffer.scala 192:18 199:39]
  wire [3:0] _GEN_45 = moveOrResetRequested ? 4'h0 : outputStateReg; // @[KvRingBuffer.scala 197:33 198:24 143:33]
  wire  _GEN_47 = moveOrResetRequested ? _GEN_43 : _GEN_39; // @[KvRingBuffer.scala 197:33]
  wire [9:0] _readFullPtr_T = readPtr * 6'h26; // @[KvRingBuffer.scala 204:31]
  wire [9:0] _readFullPtr_T_2 = _readFullPtr_T + readValueChunkPtr; // @[KvRingBuffer.scala 204:40]
  wire [9:0] readFullPtr = _readFullPtr_T_2 + readKeyChunkPtr; // @[KvRingBuffer.scala 204:60]
  reg [31:0] shadowReg; // @[KvRingBuffer.scala 206:28]
  wire  _T_13 = ~moveOrResetRequested; // @[KvRingBuffer.scala 212:31]
  wire [31:0] _GEN_58 = _T_13 ? mem_data_data : keyLen; // @[KvRingBuffer.scala 228:42 229:24 127:25]
  wire [9:0] _GEN_59 = _T_13 ? 10'h0 : readKeyChunkPtr; // @[KvRingBuffer.scala 228:42 232:33]
  wire [9:0] _GEN_60 = _T_13 ? 10'h2 : readValueChunkPtr; // @[KvRingBuffer.scala 228:42 233:35]
  wire [3:0] _GEN_61 = _T_13 ? 4'h3 : _GEN_45; // @[KvRingBuffer.scala 228:42 234:32]
  wire [9:0] _GEN_62 = keyLen == 32'h1 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 241:38 243:39]
  wire [3:0] _GEN_63 = keyLen == 32'h1 ? 4'ha : 4'h1; // @[KvRingBuffer.scala 241:38 244:37 249:37]
  wire [3:0] _GEN_64 = keyLen == 32'h1 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 241:38 246:36 250:36]
  wire [9:0] _GEN_65 = _T_13 ? _GEN_62 : readValueChunkPtr; // @[KvRingBuffer.scala 240:42]
  wire [9:0] _GEN_66 = _T_13 ? {{6'd0}, _GEN_63} : readKeyChunkPtr; // @[KvRingBuffer.scala 240:42]
  wire [3:0] _GEN_67 = _T_13 ? _GEN_64 : _GEN_45; // @[KvRingBuffer.scala 240:42]
  wire [31:0] _T_25 = keyLen - 32'h1; // @[KvRingBuffer.scala 258:54]
  wire [31:0] _GEN_163 = {{22'd0}, readKeyChunkPtr}; // @[KvRingBuffer.scala 258:43]
  wire  _T_26 = _GEN_163 == _T_25; // @[KvRingBuffer.scala 258:43]
  wire [3:0] _GEN_68 = _GEN_163 == _T_25 ? 4'h6 : _GEN_45; // @[KvRingBuffer.scala 258:61 259:40]
  wire [9:0] _GEN_69 = _GEN_163 == _T_25 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 258:61 260:43]
  wire [9:0] _GEN_70 = _GEN_163 == _T_25 ? 10'ha : _nextVal_T_14; // @[KvRingBuffer.scala 258:61 261:41 263:41]
  wire [3:0] _GEN_71 = io_deq_ready ? _GEN_68 : 4'h5; // @[KvRingBuffer.scala 257:36 268:36]
  wire [9:0] _GEN_72 = io_deq_ready ? _GEN_69 : readValueChunkPtr; // @[KvRingBuffer.scala 257:36]
  wire [9:0] _GEN_73 = io_deq_ready ? _GEN_70 : readKeyChunkPtr; // @[KvRingBuffer.scala 257:36]
  wire [31:0] _GEN_74 = io_deq_ready ? shadowReg : mem_data_data; // @[KvRingBuffer.scala 206:28 257:36 267:31]
  wire [3:0] _GEN_75 = _T_13 ? _GEN_71 : _GEN_45; // @[KvRingBuffer.scala 256:42]
  wire [9:0] _GEN_76 = _T_13 ? _GEN_72 : readValueChunkPtr; // @[KvRingBuffer.scala 256:42]
  wire [9:0] _GEN_77 = _T_13 ? _GEN_73 : readKeyChunkPtr; // @[KvRingBuffer.scala 256:42]
  wire [31:0] _GEN_78 = _T_13 ? _GEN_74 : shadowReg; // @[KvRingBuffer.scala 206:28 256:42]
  wire  _T_29 = io_deq_ready & _T_13; // @[KvRingBuffer.scala 274:31]
  wire [3:0] _GEN_79 = _T_26 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 275:57 276:36 280:36]
  wire [3:0] _GEN_82 = io_deq_ready & _T_13 ? _GEN_79 : _GEN_45; // @[KvRingBuffer.scala 274:57]
  wire [9:0] _GEN_83 = io_deq_ready & _T_13 ? _GEN_69 : readValueChunkPtr; // @[KvRingBuffer.scala 274:57]
  wire [9:0] _GEN_84 = io_deq_ready & _T_13 ? _GEN_70 : readKeyChunkPtr; // @[KvRingBuffer.scala 274:57]
  wire [3:0] _GEN_85 = valueLen == 32'h1 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 292:48 293:44 295:44]
  wire [9:0] _GEN_86 = valueLen == 32'h1 ? readValueChunkPtr : 10'h1; // @[KvRingBuffer.scala 292:48 296:47]
  wire [3:0] _GEN_87 = io_outputKeyOnly ? 4'h0 : _GEN_85; // @[KvRingBuffer.scala 289:44 290:40]
  wire [9:0] _GEN_88 = io_outputKeyOnly ? readValueChunkPtr : _GEN_86; // @[KvRingBuffer.scala 289:44]
  wire [3:0] _GEN_89 = io_deq_ready ? _GEN_87 : 4'h7; // @[KvRingBuffer.scala 288:36 301:36]
  wire [9:0] _GEN_90 = io_deq_ready ? _GEN_88 : readValueChunkPtr; // @[KvRingBuffer.scala 288:36]
  wire [3:0] _GEN_91 = _T_13 ? _GEN_89 : _GEN_45; // @[KvRingBuffer.scala 287:42]
  wire [9:0] _GEN_92 = _T_13 ? _GEN_90 : readValueChunkPtr; // @[KvRingBuffer.scala 287:42]
  wire [3:0] _GEN_98 = _T_29 ? _GEN_87 : _GEN_45; // @[KvRingBuffer.scala 307:57]
  wire [9:0] _GEN_99 = _T_29 ? _GEN_88 : readValueChunkPtr; // @[KvRingBuffer.scala 307:57]
  wire [31:0] _T_43 = valueLen - 32'h1; // @[KvRingBuffer.scala 324:57]
  wire [31:0] _GEN_165 = {{22'd0}, readValueChunkPtr}; // @[KvRingBuffer.scala 324:44]
  wire  _T_44 = _GEN_165 == _T_43; // @[KvRingBuffer.scala 324:44]
  wire [3:0] _GEN_100 = _GEN_165 == _T_43 ? 4'ha : _GEN_45; // @[KvRingBuffer.scala 324:64 325:40]
  wire [9:0] _GEN_101 = _GEN_165 == _T_43 ? readValueChunkPtr : _nextVal_T_17; // @[KvRingBuffer.scala 324:64 327:43]
  wire [3:0] _GEN_102 = io_deq_ready ? _GEN_100 : 4'h9; // @[KvRingBuffer.scala 323:36 332:36]
  wire [9:0] _GEN_103 = io_deq_ready ? _GEN_101 : readValueChunkPtr; // @[KvRingBuffer.scala 323:36]
  wire [3:0] _GEN_104 = _T_13 ? _GEN_102 : _GEN_45; // @[KvRingBuffer.scala 322:42]
  wire [9:0] _GEN_105 = _T_13 ? _GEN_103 : readValueChunkPtr; // @[KvRingBuffer.scala 322:42]
  wire [3:0] _GEN_107 = _T_44 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 339:60 340:36 342:36]
  wire [3:0] _GEN_109 = _T_29 ? _GEN_107 : _GEN_45; // @[KvRingBuffer.scala 338:57]
  wire [9:0] _GEN_110 = _T_29 ? _GEN_101 : readValueChunkPtr; // @[KvRingBuffer.scala 338:57]
  wire [3:0] _GEN_111 = io_deq_ready ? 4'h0 : 4'hb; // @[KvRingBuffer.scala 350:36 351:36 358:36]
  wire [3:0] _GEN_112 = _T_13 ? _GEN_111 : _GEN_45; // @[KvRingBuffer.scala 349:42]
  wire [3:0] _GEN_114 = _T_29 ? 4'h0 : _GEN_45; // @[KvRingBuffer.scala 364:57 365:32]
  wire [3:0] _GEN_115 = 4'hb == outputStateReg ? _GEN_114 : _GEN_45; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_116 = 4'ha == outputStateReg ? _GEN_112 : _GEN_115; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_117 = 4'ha == outputStateReg ? _GEN_78 : shadowReg; // @[KvRingBuffer.scala 206:28 208:28]
  wire [3:0] _GEN_118 = 4'h9 == outputStateReg ? _GEN_109 : _GEN_116; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_119 = 4'h9 == outputStateReg ? _GEN_110 : readValueChunkPtr; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_120 = 4'h9 == outputStateReg ? shadowReg : _GEN_117; // @[KvRingBuffer.scala 206:28 208:28]
  wire [3:0] _GEN_121 = 4'h8 == outputStateReg ? _GEN_104 : _GEN_118; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_122 = 4'h8 == outputStateReg ? _GEN_105 : _GEN_119; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_123 = 4'h8 == outputStateReg ? _GEN_78 : _GEN_120; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_124 = 4'h7 == outputStateReg ? _GEN_98 : _GEN_121; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_125 = 4'h7 == outputStateReg ? _GEN_99 : _GEN_122; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_126 = 4'h7 == outputStateReg ? shadowReg : _GEN_123; // @[KvRingBuffer.scala 206:28 208:28]
  wire [3:0] _GEN_127 = 4'h6 == outputStateReg ? _GEN_91 : _GEN_124; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_128 = 4'h6 == outputStateReg ? _GEN_92 : _GEN_125; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_129 = 4'h6 == outputStateReg ? _GEN_78 : _GEN_126; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_130 = 4'h5 == outputStateReg ? _GEN_82 : _GEN_127; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_131 = 4'h5 == outputStateReg ? _GEN_83 : _GEN_128; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_132 = 4'h5 == outputStateReg ? _GEN_84 : readKeyChunkPtr; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_133 = 4'h5 == outputStateReg ? shadowReg : _GEN_129; // @[KvRingBuffer.scala 206:28 208:28]
  wire [3:0] _GEN_134 = 4'h4 == outputStateReg ? _GEN_75 : _GEN_130; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_135 = 4'h4 == outputStateReg ? _GEN_76 : _GEN_131; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_136 = 4'h4 == outputStateReg ? _GEN_77 : _GEN_132; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_137 = 4'h4 == outputStateReg ? _GEN_78 : _GEN_133; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_138 = 4'h3 == outputStateReg ? mem_data_data : valueLen; // @[KvRingBuffer.scala 208:28 239:22 128:27]
  wire [9:0] _GEN_139 = 4'h3 == outputStateReg ? _GEN_65 : _GEN_135; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_140 = 4'h3 == outputStateReg ? _GEN_66 : _GEN_136; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_141 = 4'h3 == outputStateReg ? _GEN_67 : _GEN_134; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_142 = 4'h3 == outputStateReg ? shadowReg : _GEN_137; // @[KvRingBuffer.scala 206:28 208:28]
  wire  _io_deq_valid_T_1 = outputStateReg == 4'h6; // @[KvRingBuffer.scala 374:72]
  wire  _io_deq_valid_T_3 = outputStateReg == 4'h5; // @[KvRingBuffer.scala 374:111]
  wire  _io_deq_valid_T_4 = outputStateReg == 4'h4 | outputStateReg == 4'h6 | outputStateReg == 4'h5; // @[KvRingBuffer.scala 374:93]
  wire  _io_deq_valid_T_5 = outputStateReg == 4'h7; // @[KvRingBuffer.scala 374:148]
  wire  _io_deq_valid_T_9 = outputStateReg == 4'ha; // @[KvRingBuffer.scala 374:232]
  wire  _io_deq_valid_T_11 = outputStateReg == 4'h9; // @[KvRingBuffer.scala 374:273]
  wire  _io_deq_valid_T_13 = outputStateReg == 4'hb; // @[KvRingBuffer.scala 374:312]
  assign mem_data_en = 1'h1; // @[KvRingBuffer.scala 205:{24,24} 103:26]
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_data_data = mem[mem_data_addr]; // @[KvRingBuffer.scala 103:26]
  `else
  assign mem_data_data = mem_data_addr >= 14'h2ac0 ? _RAND_2[31:0] : mem[mem_data_addr]; // @[KvRingBuffer.scala 103:26]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_MPORT_data = _writeDataPtr_T ? io_enq_bits : writeReg; // @[KvRingBuffer.scala 153:36]
  assign mem_MPORT_addr = {{4'd0}, writeFullPtr};
  assign mem_MPORT_mask = 1'h1; // @[KvRingBuffer.scala 152:101]
  assign mem_MPORT_en = io_enq_valid | inputStateReg == 2'h1 | metadataOffsetPtr; // @[KvRingBuffer.scala 152:61]
  assign io_enq_ready = _writeDataPtr_T & _T_7; // @[KvRingBuffer.scala 373:51]
  assign io_deq_valid = outputStateReg == 4'h4 | outputStateReg == 4'h6 | outputStateReg == 4'h5 | outputStateReg == 4'h7
     | outputStateReg == 4'h8 | outputStateReg == 4'ha | outputStateReg == 4'h9 | outputStateReg == 4'hb; // @[KvRingBuffer.scala 374:294]
  assign io_deq_bits = _io_deq_valid_T_3 | _io_deq_valid_T_5 | _io_deq_valid_T_11 | _io_deq_valid_T_13 ? shadowReg :
    mem_data_data; // @[KvRingBuffer.scala 375:23]
  assign io_lastOutput = _io_deq_valid_T_9 | _io_deq_valid_T_13 | (_io_deq_valid_T_1 | _io_deq_valid_T_5) &
    io_outputKeyOnly; // @[KvRingBuffer.scala 377:110]
  assign io_isOutputKey = _io_deq_valid_T_4 | _io_deq_valid_T_5; // @[KvRingBuffer.scala 376:132]
  assign io_status_empty = emptyReg; // @[KvRingBuffer.scala 378:21]
  assign io_status_full = fullReg; // @[KvRingBuffer.scala 379:20]
  assign io_status_halfFull = distanceBetweenPtrs >= 4'h4 | io_status_full; // @[KvRingBuffer.scala 380:64]
  always @(posedge clock) begin
    if (mem_data_en) begin
      mem_data_addr <= {{4'd0}, readFullPtr}; // @[KvRingBuffer.scala 205:24]
    end
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[KvRingBuffer.scala 103:26]
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      readPtr <= 4'h0; // @[KvRingBuffer.scala 94:29]
    end else if (incrRead) begin // @[KvRingBuffer.scala 96:21]
      if (readPtr == 4'h8) begin // @[KvRingBuffer.scala 95:26]
        readPtr <= 4'h0;
      end else begin
        readPtr <= _nextVal_T_2;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      writePtr <= 4'h0; // @[KvRingBuffer.scala 94:29]
    end else if (incrWrite) begin // @[KvRingBuffer.scala 96:21]
      if (writePtr == 4'h8) begin // @[KvRingBuffer.scala 95:26]
        writePtr <= 4'h0;
      end else begin
        writePtr <= _nextVal_T_5;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 142:32]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 142:32]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 159:38]
          inputStateReg <= _GEN_11;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      inputStateReg <= 2'h2; // @[KvRingBuffer.scala 173:27]
    end else if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 182:27]
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (io_isInputKey) begin // @[KvRingBuffer.scala 159:38]
          writeKeyChunkPtr <= _nextVal_T_8; // @[KvRingBuffer.scala 160:38]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 156:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
        writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 183:30]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 159:38]
          writeValueChunkPtr <= _nextVal_T_11; // @[KvRingBuffer.scala 162:40]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 156:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
        writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 184:32]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (~emptyReg & ~moveOrResetRequested) begin // @[KvRingBuffer.scala 212:54]
        readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 213:33]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (_T_13) begin // @[KvRingBuffer.scala 220:42]
        readKeyChunkPtr <= 10'h1; // @[KvRingBuffer.scala 223:33]
      end
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      readKeyChunkPtr <= _GEN_59;
    end else begin
      readKeyChunkPtr <= _GEN_140;
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (~emptyReg & ~moveOrResetRequested) begin // @[KvRingBuffer.scala 212:54]
        readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 214:35]
      end
    end else if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
        readValueChunkPtr <= _GEN_60;
      end else begin
        readValueChunkPtr <= _GEN_139;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 127:25]
      keyLen <= 32'h0; // @[KvRingBuffer.scala 127:25]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
        if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
          keyLen <= _GEN_58;
        end
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 128:27]
      valueLen <= 32'h0; // @[KvRingBuffer.scala 128:27]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
          valueLen <= _GEN_138;
        end
      end
    end
    emptyReg <= reset | _GEN_47; // @[KvRingBuffer.scala 130:{27,27}]
    if (reset) begin // @[KvRingBuffer.scala 131:26]
      fullReg <= 1'h0; // @[KvRingBuffer.scala 131:26]
    end else if (moveOrResetRequested) begin // @[KvRingBuffer.scala 197:33]
      if (io_control_moveReadPtr) begin // @[KvRingBuffer.scala 199:39]
        fullReg <= 1'h0; // @[KvRingBuffer.scala 193:17]
      end else begin
        fullReg <= _GEN_41;
      end
    end else begin
      fullReg <= _GEN_41;
    end
    if (reset) begin // @[KvRingBuffer.scala 143:33]
      outputStateReg <= 4'h0; // @[KvRingBuffer.scala 143:33]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (~emptyReg & ~moveOrResetRequested) begin // @[KvRingBuffer.scala 212:54]
        outputStateReg <= 4'h1; // @[KvRingBuffer.scala 215:32]
      end else begin
        outputStateReg <= _GEN_45;
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (_T_13) begin // @[KvRingBuffer.scala 220:42]
        outputStateReg <= 4'h2; // @[KvRingBuffer.scala 221:32]
      end else begin
        outputStateReg <= _GEN_45;
      end
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      outputStateReg <= _GEN_61;
    end else begin
      outputStateReg <= _GEN_141;
    end
    if (reset) begin // @[KvRingBuffer.scala 145:27]
      writeReg <= 32'h0; // @[KvRingBuffer.scala 145:27]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 159:38]
          writeReg <= _GEN_12;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      writeReg <= {{22'd0}, writeValueChunkPtr}; // @[KvRingBuffer.scala 174:22]
    end
    if (reset) begin // @[KvRingBuffer.scala 206:28]
      shadowReg <= 32'h0; // @[KvRingBuffer.scala 206:28]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
          shadowReg <= _GEN_142;
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
  for (initvar = 0; initvar < 10944; initvar = initvar+1)
    mem[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  mem_data_addr = _RAND_1[13:0];
  _RAND_3 = {1{`RANDOM}};
  readPtr = _RAND_3[3:0];
  _RAND_4 = {1{`RANDOM}};
  writePtr = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  inputStateReg = _RAND_5[1:0];
  _RAND_6 = {1{`RANDOM}};
  writeKeyChunkPtr = _RAND_6[9:0];
  _RAND_7 = {1{`RANDOM}};
  writeValueChunkPtr = _RAND_7[9:0];
  _RAND_8 = {1{`RANDOM}};
  readKeyChunkPtr = _RAND_8[9:0];
  _RAND_9 = {1{`RANDOM}};
  readValueChunkPtr = _RAND_9[9:0];
  _RAND_10 = {1{`RANDOM}};
  keyLen = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  valueLen = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  emptyReg = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  fullReg = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  outputStateReg = _RAND_14[3:0];
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
module NextIndexSelector(
  input  [1:0] io_mask,
  input        io_currentIndex,
  output       io_nextIndex,
  output       io_overflow
);
  wire  modifiedMask_1 = 1'h1 <= io_currentIndex ? 1'h0 : io_mask[1]; // @[NextIndexSelector.scala 25:39 26:29 28:29]
  wire [1:0] _T_2 = {1'h0,modifiedMask_1}; // @[Cat.scala 33:92]
  wire  _io_nextIndex_T_2 = io_mask[0] ? 1'h0 : 1'h1; // @[Mux.scala 47:70]
  wire [1:0] _io_nextIndex_T_3 = {modifiedMask_1,1'h0}; // @[NextIndexSelector.scala 37:54]
  wire  _io_nextIndex_T_6 = _io_nextIndex_T_3[0] ? 1'h0 : 1'h1; // @[Mux.scala 47:70]
  assign io_nextIndex = _T_2 == 2'h0 ? _io_nextIndex_T_2 : _io_nextIndex_T_6; // @[NextIndexSelector.scala 33:45 34:22 37:22]
  assign io_overflow = _T_2 == 2'h0; // @[NextIndexSelector.scala 33:36]
endmodule
module KvTransfer(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_lastInput,
  input         io_isInputKey,
  output        io_resetBufferRead,
  output        io_outputKeyOnly,
  output        io_bufferSelect,
  output        io_outputSelect,
  input  [1:0]  io_control_command,
  input         io_control_stop,
  input         io_control_bufferInputSelect,
  input  [1:0]  io_control_mask,
  output        io_control_busy,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits,
  output        io_incrKeyBufferPtr,
  output        io_clearKeyBuffer,
  output        io_isOutputKey,
  output        io_lastOutput
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  wire [1:0] nextIndexSelector_io_mask; // @[KvTransfer.scala 83:35]
  wire  nextIndexSelector_io_currentIndex; // @[KvTransfer.scala 83:35]
  wire  nextIndexSelector_io_nextIndex; // @[KvTransfer.scala 83:35]
  wire  nextIndexSelector_io_overflow; // @[KvTransfer.scala 83:35]
  reg [2:0] state; // @[KvTransfer.scala 71:24]
  reg [31:0] data; // @[KvTransfer.scala 72:23]
  reg  lastKeyChunk; // @[KvTransfer.scala 73:31]
  reg  bufferIdx; // @[KvTransfer.scala 77:28]
  reg  moreChunksToLoad_0; // @[KvTransfer.scala 80:35]
  reg  moreChunksToLoad_1; // @[KvTransfer.scala 80:35]
  wire [1:0] _allBuffersEmpty_T = {moreChunksToLoad_0,moreChunksToLoad_1}; // @[Cat.scala 33:92]
  wire  allBuffersEmpty = _allBuffersEmpty_T == 2'h0; // @[KvTransfer.scala 81:49]
  wire  _bufferIdx_T_2 = io_control_mask[0] ? 1'h0 : 1'h1; // @[Mux.scala 47:70]
  wire  _GEN_0 = ~io_control_mask[0] ? 1'h0 : 1'h1; // @[KvTransfer.scala 100:45 97:55 98:45]
  wire  _GEN_1 = ~io_control_mask[1] ? 1'h0 : 1'h1; // @[KvTransfer.scala 100:45 97:55 98:45]
  wire  _GEN_5 = io_control_command == 2'h1 ? _GEN_0 : moreChunksToLoad_0; // @[KvTransfer.scala 80:35 90:74]
  wire  _GEN_6 = io_control_command == 2'h1 ? _GEN_1 : moreChunksToLoad_1; // @[KvTransfer.scala 80:35 90:74]
  wire  _T_9 = ~io_control_stop; // @[KvTransfer.scala 114:35]
  wire  _GEN_10 = bufferIdx ? moreChunksToLoad_1 : moreChunksToLoad_0; // @[KvTransfer.scala 114:{78,78}]
  wire  _GEN_11 = io_deq_ready ? nextIndexSelector_io_nextIndex : bufferIdx; // @[KvTransfer.scala 116:41 117:35 77:28]
  wire [31:0] _GEN_12 = io_deq_ready ? data : io_enq_bits; // @[KvTransfer.scala 116:41 72:23 120:30]
  wire  _GEN_13 = io_deq_ready ? lastKeyChunk : io_lastInput; // @[KvTransfer.scala 116:41 73:31 121:38]
  wire [2:0] _GEN_14 = io_deq_ready ? state : 3'h3; // @[KvTransfer.scala 116:41 71:24 122:31]
  wire  _GEN_15 = io_enq_valid ? _GEN_11 : bufferIdx; // @[KvTransfer.scala 115:37 77:28]
  wire [31:0] _GEN_16 = io_enq_valid ? _GEN_12 : data; // @[KvTransfer.scala 115:37 72:23]
  wire  _GEN_17 = io_enq_valid ? _GEN_13 : lastKeyChunk; // @[KvTransfer.scala 115:37 73:31]
  wire [2:0] _GEN_18 = io_enq_valid ? _GEN_14 : state; // @[KvTransfer.scala 115:37 71:24]
  wire [2:0] _GEN_19 = allBuffersEmpty ? 3'h0 : state; // @[KvTransfer.scala 127:40 128:27 71:24]
  wire  _GEN_20 = allBuffersEmpty ? bufferIdx : nextIndexSelector_io_nextIndex; // @[KvTransfer.scala 127:40 77:28 131:31]
  wire  _GEN_21 = ~io_control_stop & _GEN_10 ? _GEN_15 : _GEN_20; // @[KvTransfer.scala 114:90]
  wire [31:0] _GEN_22 = ~io_control_stop & _GEN_10 ? _GEN_16 : data; // @[KvTransfer.scala 114:90 72:23]
  wire  _GEN_23 = ~io_control_stop & _GEN_10 ? _GEN_17 : lastKeyChunk; // @[KvTransfer.scala 114:90 73:31]
  wire [2:0] _GEN_24 = ~io_control_stop & _GEN_10 ? _GEN_18 : _GEN_19; // @[KvTransfer.scala 114:90]
  wire  _T_12 = io_enq_valid & io_lastInput; // @[KvTransfer.scala 136:32]
  wire  _GEN_25 = ~bufferIdx ? 1'h0 : moreChunksToLoad_0; // @[KvTransfer.scala 137:{45,45} 80:35]
  wire  _GEN_26 = bufferIdx ? 1'h0 : moreChunksToLoad_1; // @[KvTransfer.scala 137:{45,45} 80:35]
  wire  _GEN_27 = io_enq_valid & io_lastInput ? _GEN_25 : moreChunksToLoad_0; // @[KvTransfer.scala 136:49 80:35]
  wire  _GEN_28 = io_enq_valid & io_lastInput ? _GEN_26 : moreChunksToLoad_1; // @[KvTransfer.scala 136:49 80:35]
  wire [2:0] _GEN_29 = io_control_stop ? 3'h0 : _GEN_24; // @[KvTransfer.scala 140:36 141:23]
  wire  _GEN_30 = io_deq_ready & _T_9 ? nextIndexSelector_io_nextIndex : bufferIdx; // @[KvTransfer.scala 145:53 146:27 77:28]
  wire [2:0] _GEN_31 = io_deq_ready & _T_9 ? 3'h2 : state; // @[KvTransfer.scala 145:53 147:23 71:24]
  wire [2:0] _GEN_32 = io_control_stop ? 3'h0 : _GEN_31; // @[KvTransfer.scala 150:36 151:23]
  wire [2:0] _GEN_33 = _T_12 & io_deq_ready ? 3'h0 : state; // @[KvTransfer.scala 160:65 161:23 71:24]
  wire [2:0] _GEN_34 = 3'h5 == state ? _GEN_33 : state; // @[KvTransfer.scala 87:20 71:24]
  wire [2:0] _GEN_35 = 3'h4 == state ? 3'h5 : _GEN_34; // @[KvTransfer.scala 156:19 87:20]
  wire  _GEN_36 = 3'h3 == state ? _GEN_30 : bufferIdx; // @[KvTransfer.scala 87:20 77:28]
  wire [2:0] _GEN_37 = 3'h3 == state ? _GEN_32 : _GEN_35; // @[KvTransfer.scala 87:20]
  wire  _GEN_42 = 3'h2 == state ? _GEN_27 : moreChunksToLoad_0; // @[KvTransfer.scala 87:20 80:35]
  wire  _GEN_43 = 3'h2 == state ? _GEN_28 : moreChunksToLoad_1; // @[KvTransfer.scala 87:20 80:35]
  wire  _GEN_48 = 3'h1 == state ? moreChunksToLoad_0 : _GEN_42; // @[KvTransfer.scala 87:20 80:35]
  wire  _GEN_49 = 3'h1 == state ? moreChunksToLoad_1 : _GEN_43; // @[KvTransfer.scala 87:20 80:35]
  wire  _GEN_53 = 3'h0 == state ? _GEN_5 : _GEN_48; // @[KvTransfer.scala 87:20]
  wire  _GEN_54 = 3'h0 == state ? _GEN_6 : _GEN_49; // @[KvTransfer.scala 87:20]
  wire  _io_outputSelect_T = state == 3'h5; // @[KvTransfer.scala 166:30]
  wire  _io_outputKeyOnly_T = state == 3'h2; // @[KvTransfer.scala 169:32]
  wire  _io_outputKeyOnly_T_1 = state == 3'h3; // @[KvTransfer.scala 169:55]
  wire  _io_outputKeyOnly_T_2 = state == 3'h2 | state == 3'h3; // @[KvTransfer.scala 169:46]
  wire  _io_control_busy_T = state != 3'h0; // @[KvTransfer.scala 170:30]
  wire  _io_clearKeyBuffer_T = state == 3'h1; // @[KvTransfer.scala 177:32]
  NextIndexSelector nextIndexSelector ( // @[KvTransfer.scala 83:35]
    .io_mask(nextIndexSelector_io_mask),
    .io_currentIndex(nextIndexSelector_io_currentIndex),
    .io_nextIndex(nextIndexSelector_io_nextIndex),
    .io_overflow(nextIndexSelector_io_overflow)
  );
  assign io_enq_ready = _io_outputKeyOnly_T & _GEN_10 | _io_outputSelect_T & io_deq_ready; // @[KvTransfer.scala 185:85]
  assign io_resetBufferRead = state == 3'h4 | _io_clearKeyBuffer_T; // @[KvTransfer.scala 181:53]
  assign io_outputKeyOnly = (state == 3'h2 | state == 3'h3) & state != 3'h5; // @[KvTransfer.scala 169:76]
  assign io_bufferSelect = bufferIdx; // @[KvTransfer.scala 167:21]
  assign io_outputSelect = state == 3'h5; // @[KvTransfer.scala 166:30]
  assign io_control_busy = state != 3'h0; // @[KvTransfer.scala 170:30]
  assign io_deq_valid = _io_control_busy_T & state != 3'h1 & (_io_outputKeyOnly_T_1 | _io_outputKeyOnly_T & (
    io_enq_valid & _GEN_10)) | _io_outputSelect_T & io_enq_valid; // @[KvTransfer.scala 187:184]
  assign io_deq_bits = _io_outputKeyOnly_T_1 ? data : io_enq_bits; // @[KvTransfer.scala 186:23]
  assign io_incrKeyBufferPtr = nextIndexSelector_io_overflow & _io_outputKeyOnly_T_2; // @[KvTransfer.scala 183:58]
  assign io_clearKeyBuffer = state == 3'h1 | io_control_stop; // @[KvTransfer.scala 177:51]
  assign io_isOutputKey = io_isInputKey; // @[KvTransfer.scala 168:20]
  assign io_lastOutput = _io_outputKeyOnly_T_1 ? lastKeyChunk : io_lastInput; // @[KvTransfer.scala 178:25]
  assign nextIndexSelector_io_mask = {moreChunksToLoad_1,moreChunksToLoad_0}; // @[KvTransfer.scala 84:51]
  assign nextIndexSelector_io_currentIndex = bufferIdx; // @[KvTransfer.scala 85:39]
  always @(posedge clock) begin
    if (reset) begin // @[KvTransfer.scala 71:24]
      state <= 3'h0; // @[KvTransfer.scala 71:24]
    end else if (3'h0 == state) begin // @[KvTransfer.scala 87:20]
      if (io_control_command == 2'h2) begin // @[KvTransfer.scala 105:76]
        state <= 3'h4; // @[KvTransfer.scala 107:23]
      end else if (io_control_command == 2'h1) begin // @[KvTransfer.scala 90:74]
        state <= 3'h1; // @[KvTransfer.scala 92:23]
      end
    end else if (3'h1 == state) begin // @[KvTransfer.scala 87:20]
      state <= 3'h2; // @[KvTransfer.scala 111:19]
    end else if (3'h2 == state) begin // @[KvTransfer.scala 87:20]
      state <= _GEN_29;
    end else begin
      state <= _GEN_37;
    end
    if (reset) begin // @[KvTransfer.scala 72:23]
      data <= 32'h0; // @[KvTransfer.scala 72:23]
    end else if (!(3'h0 == state)) begin // @[KvTransfer.scala 87:20]
      if (!(3'h1 == state)) begin // @[KvTransfer.scala 87:20]
        if (3'h2 == state) begin // @[KvTransfer.scala 87:20]
          data <= _GEN_22;
        end
      end
    end
    if (reset) begin // @[KvTransfer.scala 73:31]
      lastKeyChunk <= 1'h0; // @[KvTransfer.scala 73:31]
    end else if (!(3'h0 == state)) begin // @[KvTransfer.scala 87:20]
      if (!(3'h1 == state)) begin // @[KvTransfer.scala 87:20]
        if (3'h2 == state) begin // @[KvTransfer.scala 87:20]
          lastKeyChunk <= _GEN_23;
        end
      end
    end
    if (reset) begin // @[KvTransfer.scala 77:28]
      bufferIdx <= 1'h0; // @[KvTransfer.scala 77:28]
    end else if (3'h0 == state) begin // @[KvTransfer.scala 87:20]
      if (io_control_command == 2'h2) begin // @[KvTransfer.scala 105:76]
        bufferIdx <= io_control_bufferInputSelect; // @[KvTransfer.scala 106:27]
      end else if (io_control_command == 2'h1) begin // @[KvTransfer.scala 90:74]
        bufferIdx <= _bufferIdx_T_2; // @[KvTransfer.scala 91:27]
      end
    end else if (!(3'h1 == state)) begin // @[KvTransfer.scala 87:20]
      if (3'h2 == state) begin // @[KvTransfer.scala 87:20]
        bufferIdx <= _GEN_21;
      end else begin
        bufferIdx <= _GEN_36;
      end
    end
    moreChunksToLoad_0 <= reset | _GEN_53; // @[KvTransfer.scala 80:{35,35}]
    moreChunksToLoad_1 <= reset | _GEN_54; // @[KvTransfer.scala 80:{35,35}]
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
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  data = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  lastKeyChunk = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  bufferIdx = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  moreChunksToLoad_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  moreChunksToLoad_1 = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TopKvTransfer(
  input         clock,
  input         reset,
  output        io_enq_0_ready,
  input         io_enq_0_valid,
  input  [31:0] io_enq_0_bits,
  output        io_enq_1_ready,
  input         io_enq_1_valid,
  input  [31:0] io_enq_1_bits,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits,
  input         io_deqKvPair_ready,
  output        io_deqKvPair_valid,
  output [31:0] io_deqKvPair_bits,
  input         io_lastInputs_0,
  input         io_lastInputs_1,
  input         io_isInputKey_0,
  input         io_isInputKey_1,
  input  [1:0]  io_control_command,
  input         io_control_stop,
  input         io_control_bufferInputSelect,
  input  [1:0]  io_control_mask,
  output        io_control_busy,
  output        io_bufferSelect,
  output        io_outputKeyOnly,
  output        io_incrKeyBufferPtr,
  output        io_clearKeyBuffer,
  output        io_lastOutput,
  output        io_resetBufferRead,
  output        io_isOutputKey
);
  wire  kvTransfer_clock; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_reset; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_enq_ready; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_enq_valid; // @[KvTransfer.scala 225:28]
  wire [31:0] kvTransfer_io_enq_bits; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_lastInput; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_isInputKey; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_resetBufferRead; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_outputKeyOnly; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_bufferSelect; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_outputSelect; // @[KvTransfer.scala 225:28]
  wire [1:0] kvTransfer_io_control_command; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_control_stop; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_control_bufferInputSelect; // @[KvTransfer.scala 225:28]
  wire [1:0] kvTransfer_io_control_mask; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_control_busy; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_deq_ready; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_deq_valid; // @[KvTransfer.scala 225:28]
  wire [31:0] kvTransfer_io_deq_bits; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_incrKeyBufferPtr; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_clearKeyBuffer; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_isOutputKey; // @[KvTransfer.scala 225:28]
  wire  kvTransfer_io_lastOutput; // @[KvTransfer.scala 225:28]
  KvTransfer kvTransfer ( // @[KvTransfer.scala 225:28]
    .clock(kvTransfer_clock),
    .reset(kvTransfer_reset),
    .io_enq_ready(kvTransfer_io_enq_ready),
    .io_enq_valid(kvTransfer_io_enq_valid),
    .io_enq_bits(kvTransfer_io_enq_bits),
    .io_lastInput(kvTransfer_io_lastInput),
    .io_isInputKey(kvTransfer_io_isInputKey),
    .io_resetBufferRead(kvTransfer_io_resetBufferRead),
    .io_outputKeyOnly(kvTransfer_io_outputKeyOnly),
    .io_bufferSelect(kvTransfer_io_bufferSelect),
    .io_outputSelect(kvTransfer_io_outputSelect),
    .io_control_command(kvTransfer_io_control_command),
    .io_control_stop(kvTransfer_io_control_stop),
    .io_control_bufferInputSelect(kvTransfer_io_control_bufferInputSelect),
    .io_control_mask(kvTransfer_io_control_mask),
    .io_control_busy(kvTransfer_io_control_busy),
    .io_deq_ready(kvTransfer_io_deq_ready),
    .io_deq_valid(kvTransfer_io_deq_valid),
    .io_deq_bits(kvTransfer_io_deq_bits),
    .io_incrKeyBufferPtr(kvTransfer_io_incrKeyBufferPtr),
    .io_clearKeyBuffer(kvTransfer_io_clearKeyBuffer),
    .io_isOutputKey(kvTransfer_io_isOutputKey),
    .io_lastOutput(kvTransfer_io_lastOutput)
  );
  assign io_enq_0_ready = ~kvTransfer_io_bufferSelect & kvTransfer_io_enq_ready; // @[KvTransfer.scala 248:50 249:31 253:29]
  assign io_enq_1_ready = kvTransfer_io_bufferSelect & kvTransfer_io_enq_ready; // @[KvTransfer.scala 248:50 249:31 253:29]
  assign io_deq_valid = kvTransfer_io_outputSelect ? 1'h0 : kvTransfer_io_deq_valid; // @[KvTransfer.scala 259:39 262:22 265:16]
  assign io_deq_bits = kvTransfer_io_deq_bits; // @[KvTransfer.scala 259:39 265:16]
  assign io_deqKvPair_valid = kvTransfer_io_outputSelect & kvTransfer_io_deq_valid; // @[KvTransfer.scala 259:39 260:22 268:28]
  assign io_deqKvPair_bits = kvTransfer_io_deq_bits; // @[KvTransfer.scala 259:39 260:22]
  assign io_control_busy = kvTransfer_io_control_busy; // @[KvTransfer.scala 227:27]
  assign io_bufferSelect = kvTransfer_io_bufferSelect; // @[KvTransfer.scala 231:32]
  assign io_outputKeyOnly = kvTransfer_io_outputKeyOnly; // @[KvTransfer.scala 236:33]
  assign io_incrKeyBufferPtr = kvTransfer_io_incrKeyBufferPtr; // @[KvTransfer.scala 232:36]
  assign io_clearKeyBuffer = kvTransfer_io_clearKeyBuffer; // @[KvTransfer.scala 233:34]
  assign io_lastOutput = kvTransfer_io_lastOutput; // @[KvTransfer.scala 239:30]
  assign io_resetBufferRead = kvTransfer_io_resetBufferRead; // @[KvTransfer.scala 240:35]
  assign io_isOutputKey = kvTransfer_io_isOutputKey; // @[KvTransfer.scala 238:31]
  assign kvTransfer_clock = clock;
  assign kvTransfer_reset = reset;
  assign kvTransfer_io_enq_valid = kvTransfer_io_bufferSelect ? io_enq_1_valid : io_enq_0_valid; // @[KvTransfer.scala 248:50 249:31]
  assign kvTransfer_io_enq_bits = kvTransfer_io_bufferSelect ? io_enq_1_bits : io_enq_0_bits; // @[KvTransfer.scala 248:50 249:31]
  assign kvTransfer_io_lastInput = kvTransfer_io_bufferSelect ? io_lastInputs_1 : io_lastInputs_0; // @[KvTransfer.scala 248:50 250:37]
  assign kvTransfer_io_isInputKey = kvTransfer_io_bufferSelect ? io_isInputKey_1 : io_isInputKey_0; // @[KvTransfer.scala 248:50 251:38]
  assign kvTransfer_io_control_command = io_control_command; // @[KvTransfer.scala 227:27]
  assign kvTransfer_io_control_stop = io_control_stop; // @[KvTransfer.scala 227:27]
  assign kvTransfer_io_control_bufferInputSelect = io_control_bufferInputSelect; // @[KvTransfer.scala 227:27]
  assign kvTransfer_io_control_mask = io_control_mask; // @[KvTransfer.scala 227:27]
  assign kvTransfer_io_deq_ready = kvTransfer_io_outputSelect ? io_deqKvPair_ready : io_deq_ready; // @[KvTransfer.scala 259:39 260:22 265:16]
endmodule
module KeyBuffer(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits,
  input         io_bufferInputSelect,
  input         io_incrWritePtr,
  input         io_clearBuffer,
  input         io_lastInput,
  output        io_bufferOutputSelect,
  output        io_lastOutput
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
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
`endif // RANDOMIZE_REG_INIT
  reg [31:0] mem [0:15]; // @[KeyBuffer.scala 32:26]
  wire  mem_data_en; // @[KeyBuffer.scala 32:26 94:{24,24} 32:26]
  reg [3:0] mem_data_addr; // @[KeyBuffer.scala 32:26]
  wire [31:0] mem_data_data; // @[KeyBuffer.scala 32:26]
  wire [31:0] mem_MPORT_data; // @[KeyBuffer.scala 32:26 65:56]
  wire [3:0] mem_MPORT_addr; // @[KeyBuffer.scala 32:26 65:56]
  wire  mem_MPORT_mask; // @[KeyBuffer.scala 32:26 65:56]
  wire  mem_MPORT_en; // @[KeyBuffer.scala 32:26 65:36]
  reg [2:0] readPtr; // @[KeyBuffer.scala 35:29]
  wire [2:0] _nextVal_T_2 = readPtr + 3'h1; // @[KeyBuffer.scala 36:63]
  wire [2:0] nextRead = readPtr == 3'h7 ? 3'h0 : _nextVal_T_2; // @[KeyBuffer.scala 36:26]
  reg [1:0] stateReg; // @[KeyBuffer.scala 52:27]
  wire  _T_12 = ~io_clearBuffer; // @[KeyBuffer.scala 107:19]
  reg  emptyReg; // @[KeyBuffer.scala 48:27]
  wire  _T_13 = ~emptyReg; // @[KeyBuffer.scala 109:26]
  reg  bufferOutputSelect; // @[KeyBuffer.scala 55:37]
  wire  _GEN_47 = ~emptyReg & bufferOutputSelect; // @[KeyBuffer.scala 109:37 113:34]
  wire  _GEN_52 = io_deq_ready & _GEN_47; // @[KeyBuffer.scala 108:36]
  wire  _GEN_58 = ~io_clearBuffer & _GEN_52; // @[KeyBuffer.scala 107:36]
  wire  _GEN_84 = 2'h1 == stateReg ? _GEN_58 : 2'h2 == stateReg & _GEN_58; // @[KeyBuffer.scala 96:22]
  wire  incrRead = 2'h0 == stateReg ? 1'h0 : _GEN_84; // @[KeyBuffer.scala 96:22]
  reg [2:0] writePtr; // @[KeyBuffer.scala 35:29]
  wire [2:0] _nextVal_T_5 = writePtr + 3'h1; // @[KeyBuffer.scala 36:63]
  wire [2:0] nextWrite = writePtr == 3'h7 ? 3'h0 : _nextVal_T_5; // @[KeyBuffer.scala 36:26]
  reg  fullReg; // @[KeyBuffer.scala 49:26]
  wire  _T = ~fullReg; // @[KeyBuffer.scala 65:27]
  wire  incrWrite = io_enq_valid & ~fullReg & _T_12 & io_incrWritePtr; // @[KeyBuffer.scala 65:56]
  reg [31:0] shadowReg; // @[KeyBuffer.scala 53:28]
  wire [4:0] _readFullPtr_T = readPtr * 2'h2; // @[KeyBuffer.scala 59:31]
  wire [4:0] _GEN_97 = {{4'd0}, bufferOutputSelect}; // @[KeyBuffer.scala 59:51]
  wire [4:0] readFullPtr = _readFullPtr_T + _GEN_97; // @[KeyBuffer.scala 59:51]
  wire [4:0] _writeFullPtr_T = writePtr * 2'h2; // @[KeyBuffer.scala 60:33]
  wire [4:0] _GEN_98 = {{4'd0}, io_bufferInputSelect}; // @[KeyBuffer.scala 60:53]
  wire [4:0] writeFullPtr = _writeFullPtr_T + _GEN_98; // @[KeyBuffer.scala 60:53]
  reg  lastChunks_0; // @[KeyBuffer.scala 62:29]
  reg  lastChunks_1; // @[KeyBuffer.scala 62:29]
  reg [2:0] lastChunkCounters_0; // @[KeyBuffer.scala 63:36]
  reg [2:0] lastChunkCounters_1; // @[KeyBuffer.scala 63:36]
  wire  _GEN_3 = io_bufferInputSelect ? lastChunks_1 : lastChunks_0; // @[KeyBuffer.scala 71:{31,31}]
  wire  _GEN_4 = ~io_bufferInputSelect | lastChunks_0; // @[KeyBuffer.scala 62:29 72:{46,46}]
  wire  _GEN_5 = io_bufferInputSelect | lastChunks_1; // @[KeyBuffer.scala 62:29 72:{46,46}]
  wire [2:0] _GEN_6 = ~io_bufferInputSelect ? writePtr : lastChunkCounters_0; // @[KeyBuffer.scala 63:36 73:{53,53}]
  wire [2:0] _GEN_7 = io_bufferInputSelect ? writePtr : lastChunkCounters_1; // @[KeyBuffer.scala 63:36 73:{53,53}]
  wire  _GEN_13 = io_incrWritePtr ? 1'h0 : emptyReg; // @[KeyBuffer.scala 77:32 79:22 48:27]
  wire  _GEN_19 = io_enq_valid & ~fullReg & _T_12 ? nextWrite == readPtr & io_incrWritePtr : fullReg; // @[KeyBuffer.scala 65:56 67:17 49:26]
  wire  _GEN_25 = io_enq_valid & ~fullReg & _T_12 ? _GEN_13 : emptyReg; // @[KeyBuffer.scala 48:27 65:56]
  wire [1:0] _GEN_26 = io_clearBuffer ? 2'h0 : stateReg; // @[KeyBuffer.scala 83:27 84:18 52:27]
  wire  _GEN_27 = io_clearBuffer | _GEN_25; // @[KeyBuffer.scala 83:27 85:18]
  wire  _GEN_28 = io_clearBuffer ? 1'h0 : _GEN_19; // @[KeyBuffer.scala 83:27 86:17]
  wire  _GEN_31 = io_clearBuffer ? 1'h0 : bufferOutputSelect; // @[KeyBuffer.scala 83:27 89:28 55:37]
  wire  _emptyReg_T_3 = nextRead == writePtr & bufferOutputSelect & ~io_incrWritePtr; // @[KeyBuffer.scala 101:76]
  wire  _bufferOutputSelect_T_1 = bufferOutputSelect + 1'h1; // @[KeyBuffer.scala 103:58]
  wire  _GEN_42 = _T_13 & _T_12 ? nextRead == writePtr & bufferOutputSelect & ~io_incrWritePtr : _GEN_27; // @[KeyBuffer.scala 101:26 98:48]
  wire [1:0] _GEN_44 = ~emptyReg ? 2'h1 : 2'h0; // @[KeyBuffer.scala 109:37 110:34 117:34]
  wire  _GEN_45 = ~emptyReg ? 1'h0 : _GEN_28; // @[KeyBuffer.scala 109:37 111:33]
  wire  _GEN_46 = ~emptyReg ? _emptyReg_T_3 : _GEN_27; // @[KeyBuffer.scala 109:37 112:34]
  wire  _GEN_48 = ~emptyReg & _bufferOutputSelect_T_1; // @[KeyBuffer.scala 109:37 114:44 116:44]
  wire [1:0] _GEN_49 = io_deq_ready ? _GEN_44 : 2'h2; // @[KeyBuffer.scala 108:36 121:30]
  wire  _GEN_50 = io_deq_ready ? _GEN_45 : _GEN_28; // @[KeyBuffer.scala 108:36]
  wire  _GEN_51 = io_deq_ready ? _GEN_46 : _GEN_27; // @[KeyBuffer.scala 108:36]
  wire  _GEN_53 = io_deq_ready ? _GEN_48 : _GEN_31; // @[KeyBuffer.scala 108:36]
  wire [31:0] _GEN_54 = io_deq_ready ? shadowReg : mem_data_data; // @[KeyBuffer.scala 108:36 53:28 120:31]
  wire  _GEN_56 = ~io_clearBuffer ? _GEN_50 : _GEN_28; // @[KeyBuffer.scala 107:36]
  wire  _GEN_57 = ~io_clearBuffer ? _GEN_51 : _GEN_27; // @[KeyBuffer.scala 107:36]
  wire  _GEN_59 = ~io_clearBuffer ? _GEN_53 : _GEN_31; // @[KeyBuffer.scala 107:36]
  wire [1:0] _GEN_66 = io_deq_ready ? _GEN_44 : _GEN_26; // @[KeyBuffer.scala 127:36]
  wire [1:0] _GEN_71 = _T_12 ? _GEN_66 : _GEN_26; // @[KeyBuffer.scala 126:36]
  wire  _GEN_78 = 2'h2 == stateReg ? _GEN_57 : _GEN_27; // @[KeyBuffer.scala 96:22]
  wire  _GEN_83 = 2'h1 == stateReg ? _GEN_57 : _GEN_78; // @[KeyBuffer.scala 96:22]
  wire  _GEN_89 = 2'h0 == stateReg ? _GEN_42 : _GEN_83; // @[KeyBuffer.scala 96:22]
  wire  _io_deq_bits_T = stateReg == 2'h1; // @[KeyBuffer.scala 147:33]
  wire [2:0] _currentReadPtr_T_2 = readPtr - 3'h1; // @[KeyBuffer.scala 151:89]
  wire [2:0] currentReadPtr = io_bufferOutputSelect ? _currentReadPtr_T_2 : readPtr; // @[KeyBuffer.scala 151:29]
  wire [2:0] _GEN_94 = io_bufferOutputSelect ? lastChunkCounters_1 : lastChunkCounters_0; // @[KeyBuffer.scala 158:{157,157}]
  wire  _GEN_96 = io_bufferOutputSelect ? lastChunks_1 : lastChunks_0; // @[KeyBuffer.scala 158:{80,80}]
  wire  _io_deq_valid_T_4 = _GEN_96 ? _GEN_94 >= currentReadPtr : 1'h1; // @[KeyBuffer.scala 158:80]
  assign mem_data_en = 1'h1; // @[KeyBuffer.scala 94:{24,24} 32:26]
  assign mem_data_data = mem[mem_data_addr]; // @[KeyBuffer.scala 32:26]
  assign mem_MPORT_data = io_enq_bits; // @[KeyBuffer.scala 65:56]
  assign mem_MPORT_addr = writeFullPtr[3:0]; // @[KeyBuffer.scala 65:56]
  assign mem_MPORT_mask = 1'h1; // @[KeyBuffer.scala 65:56]
  assign mem_MPORT_en = io_enq_valid & ~fullReg & _T_12; // @[KeyBuffer.scala 65:36]
  assign io_enq_ready = _T & _T_12; // @[KeyBuffer.scala 163:30]
  assign io_deq_valid = (_io_deq_bits_T | stateReg == 2'h2) & _io_deq_valid_T_4; // @[KeyBuffer.scala 158:74]
  assign io_deq_bits = stateReg == 2'h1 ? mem_data_data : shadowReg; // @[KeyBuffer.scala 147:23]
  assign io_bufferOutputSelect = bufferOutputSelect - 1'h1; // @[KeyBuffer.scala 145:49]
  assign io_lastOutput = _GEN_96 & _GEN_94 == currentReadPtr; // @[KeyBuffer.scala 160:56]
  always @(posedge clock) begin
    if (mem_data_en) begin
      mem_data_addr <= readFullPtr[3:0]; // @[KeyBuffer.scala 94:24]
    end
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[KeyBuffer.scala 32:26]
    end
    if (reset) begin // @[KeyBuffer.scala 35:29]
      readPtr <= 3'h0; // @[KeyBuffer.scala 35:29]
    end else if (io_clearBuffer) begin // @[KeyBuffer.scala 83:27]
      readPtr <= 3'h0; // @[KeyBuffer.scala 88:17]
    end else if (incrRead) begin // @[KeyBuffer.scala 37:21]
      if (readPtr == 3'h7) begin // @[KeyBuffer.scala 36:26]
        readPtr <= 3'h0;
      end else begin
        readPtr <= _nextVal_T_2;
      end
    end
    if (reset) begin // @[KeyBuffer.scala 52:27]
      stateReg <= 2'h0; // @[KeyBuffer.scala 52:27]
    end else if (2'h0 == stateReg) begin // @[KeyBuffer.scala 96:22]
      if (_T_13 & _T_12) begin // @[KeyBuffer.scala 98:48]
        stateReg <= 2'h1; // @[KeyBuffer.scala 99:26]
      end else begin
        stateReg <= _GEN_26;
      end
    end else if (2'h1 == stateReg) begin // @[KeyBuffer.scala 96:22]
      if (~io_clearBuffer) begin // @[KeyBuffer.scala 107:36]
        stateReg <= _GEN_49;
      end else begin
        stateReg <= _GEN_26;
      end
    end else if (2'h2 == stateReg) begin // @[KeyBuffer.scala 96:22]
      stateReg <= _GEN_71;
    end else begin
      stateReg <= _GEN_26;
    end
    emptyReg <= reset | _GEN_89; // @[KeyBuffer.scala 48:{27,27}]
    if (reset) begin // @[KeyBuffer.scala 55:37]
      bufferOutputSelect <= 1'h0; // @[KeyBuffer.scala 55:37]
    end else if (2'h0 == stateReg) begin // @[KeyBuffer.scala 96:22]
      if (_T_13 & _T_12) begin // @[KeyBuffer.scala 98:48]
        bufferOutputSelect <= bufferOutputSelect + 1'h1; // @[KeyBuffer.scala 103:36]
      end else begin
        bufferOutputSelect <= _GEN_31;
      end
    end else if (2'h1 == stateReg) begin // @[KeyBuffer.scala 96:22]
      bufferOutputSelect <= _GEN_59;
    end else if (2'h2 == stateReg) begin // @[KeyBuffer.scala 96:22]
      bufferOutputSelect <= _GEN_59;
    end else begin
      bufferOutputSelect <= _GEN_31;
    end
    if (reset) begin // @[KeyBuffer.scala 35:29]
      writePtr <= 3'h0; // @[KeyBuffer.scala 35:29]
    end else if (io_clearBuffer) begin // @[KeyBuffer.scala 83:27]
      writePtr <= 3'h0; // @[KeyBuffer.scala 87:18]
    end else if (incrWrite) begin // @[KeyBuffer.scala 37:21]
      if (writePtr == 3'h7) begin // @[KeyBuffer.scala 36:26]
        writePtr <= 3'h0;
      end else begin
        writePtr <= _nextVal_T_5;
      end
    end
    if (reset) begin // @[KeyBuffer.scala 49:26]
      fullReg <= 1'h0; // @[KeyBuffer.scala 49:26]
    end else if (2'h0 == stateReg) begin // @[KeyBuffer.scala 96:22]
      if (_T_13 & _T_12) begin // @[KeyBuffer.scala 98:48]
        fullReg <= 1'h0; // @[KeyBuffer.scala 100:25]
      end else begin
        fullReg <= _GEN_28;
      end
    end else if (2'h1 == stateReg) begin // @[KeyBuffer.scala 96:22]
      fullReg <= _GEN_56;
    end else if (2'h2 == stateReg) begin // @[KeyBuffer.scala 96:22]
      fullReg <= _GEN_56;
    end else begin
      fullReg <= _GEN_28;
    end
    if (reset) begin // @[KeyBuffer.scala 53:28]
      shadowReg <= 32'h0; // @[KeyBuffer.scala 53:28]
    end else if (!(2'h0 == stateReg)) begin // @[KeyBuffer.scala 96:22]
      if (2'h1 == stateReg) begin // @[KeyBuffer.scala 96:22]
        if (~io_clearBuffer) begin // @[KeyBuffer.scala 107:36]
          shadowReg <= _GEN_54;
        end
      end
    end
    if (reset) begin // @[KeyBuffer.scala 62:29]
      lastChunks_0 <= 1'h0; // @[KeyBuffer.scala 62:29]
    end else if (io_clearBuffer) begin // @[KeyBuffer.scala 83:27]
      lastChunks_0 <= 1'h0; // @[KeyBuffer.scala 90:30]
    end else if (io_enq_valid & ~fullReg & _T_12) begin // @[KeyBuffer.scala 65:56]
      if (io_lastInput & ~_GEN_3) begin // @[KeyBuffer.scala 71:66]
        lastChunks_0 <= _GEN_4;
      end
    end
    if (reset) begin // @[KeyBuffer.scala 62:29]
      lastChunks_1 <= 1'h0; // @[KeyBuffer.scala 62:29]
    end else if (io_clearBuffer) begin // @[KeyBuffer.scala 83:27]
      lastChunks_1 <= 1'h0; // @[KeyBuffer.scala 90:30]
    end else if (io_enq_valid & ~fullReg & _T_12) begin // @[KeyBuffer.scala 65:56]
      if (io_lastInput & ~_GEN_3) begin // @[KeyBuffer.scala 71:66]
        lastChunks_1 <= _GEN_5;
      end
    end
    if (reset) begin // @[KeyBuffer.scala 63:36]
      lastChunkCounters_0 <= 3'h0; // @[KeyBuffer.scala 63:36]
    end else if (io_clearBuffer) begin // @[KeyBuffer.scala 83:27]
      lastChunkCounters_0 <= 3'h0; // @[KeyBuffer.scala 91:37]
    end else if (io_enq_valid & ~fullReg & _T_12) begin // @[KeyBuffer.scala 65:56]
      if (io_lastInput & ~_GEN_3) begin // @[KeyBuffer.scala 71:66]
        lastChunkCounters_0 <= _GEN_6;
      end
    end
    if (reset) begin // @[KeyBuffer.scala 63:36]
      lastChunkCounters_1 <= 3'h0; // @[KeyBuffer.scala 63:36]
    end else if (io_clearBuffer) begin // @[KeyBuffer.scala 83:27]
      lastChunkCounters_1 <= 3'h0; // @[KeyBuffer.scala 91:37]
    end else if (io_enq_valid & ~fullReg & _T_12) begin // @[KeyBuffer.scala 65:56]
      if (io_lastInput & ~_GEN_3) begin // @[KeyBuffer.scala 71:66]
        lastChunkCounters_1 <= _GEN_7;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16; initvar = initvar+1)
    mem[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  mem_data_addr = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  readPtr = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  stateReg = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  emptyReg = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  bufferOutputSelect = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  writePtr = _RAND_6[2:0];
  _RAND_7 = {1{`RANDOM}};
  fullReg = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  shadowReg = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  lastChunks_0 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  lastChunks_1 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  lastChunkCounters_0 = _RAND_11[2:0];
  _RAND_12 = {1{`RANDOM}};
  lastChunkCounters_1 = _RAND_12[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module KeyChunksComparator(
  input  [31:0] io_in_0,
  input  [31:0] io_in_1,
  input  [1:0]  io_maskIn,
  input         io_lastChunksMask_0,
  input         io_lastChunksMask_1,
  output [1:0]  io_maskOut,
  output        io_haveWinner,
  output        io_winnerIndex
);
  wire [32:0] _modifiedInputs_0_T_2 = {1'h0,io_in_0}; // @[KeyChunksComparator.scala 34:71]
  wire [32:0] _modifiedInputs_0_T_3 = {1'h1,io_in_0}; // @[KeyChunksComparator.scala 34:88]
  wire [32:0] modifiedInputs_0 = io_maskIn[0] ? _modifiedInputs_0_T_2 : _modifiedInputs_0_T_3; // @[KeyChunksComparator.scala 34:37]
  wire [32:0] _modifiedInputs_1_T_2 = {1'h0,io_in_1}; // @[KeyChunksComparator.scala 34:71]
  wire [32:0] _modifiedInputs_1_T_3 = {1'h1,io_in_1}; // @[KeyChunksComparator.scala 34:88]
  wire [32:0] modifiedInputs_1 = io_maskIn[1] ? _modifiedInputs_1_T_2 : _modifiedInputs_1_T_3; // @[KeyChunksComparator.scala 34:37]
  wire  smallestIndex = modifiedInputs_0 <= modifiedInputs_1 ? 1'h0 : 1'h1; // @[KeyChunksComparator.scala 42:12]
  wire [32:0] _GEN_5 = smallestIndex ? modifiedInputs_1 : modifiedInputs_0; // @[KeyChunksComparator.scala 49:{58,58}]
  wire  equalityMask_0 = _GEN_5 == modifiedInputs_0; // @[KeyChunksComparator.scala 49:58]
  wire  equalityMask_1 = _GEN_5 == modifiedInputs_1; // @[KeyChunksComparator.scala 49:58]
  wire [1:0] _countOnes_T = {equalityMask_1,equalityMask_0}; // @[KeyChunksComparator.scala 54:43]
  wire [1:0] countOnes = _countOnes_T[0] + _countOnes_T[1]; // @[Bitwise.scala 51:90]
  wire  hasOnlyOneOne = countOnes == 2'h1; // @[KeyChunksComparator.scala 55:35]
  wire [1:0] _andResult_T_1 = {io_lastChunksMask_1,io_lastChunksMask_0}; // @[KeyChunksComparator.scala 61:61]
  wire [1:0] andResult = _countOnes_T & _andResult_T_1; // @[KeyChunksComparator.scala 61:41]
  wire  andResultEqualsZero = andResult == 2'h0; // @[KeyChunksComparator.scala 62:41]
  assign io_maskOut = hasOnlyOneOne | andResultEqualsZero ? _countOnes_T : andResult; // @[KeyChunksComparator.scala 64:22]
  assign io_haveWinner = hasOnlyOneOne | ~andResultEqualsZero; // @[KeyChunksComparator.scala 65:36]
  assign io_winnerIndex = io_maskOut[0] ? 1'h0 : 1'h1; // @[Mux.scala 47:70]
endmodule
module Merger(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_bufferInputSelect,
  input         io_lastInput,
  input         io_control_reset,
  input  [1:0]  io_control_mask,
  output        io_control_isResultValid,
  output        io_control_haveWinner,
  output        io_control_winnerIndex,
  output        io_control_nextKvPairsToLoad_0,
  output        io_control_nextKvPairsToLoad_1
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  wire [31:0] keyChunksComparator_io_in_0; // @[Merger.scala 72:37]
  wire [31:0] keyChunksComparator_io_in_1; // @[Merger.scala 72:37]
  wire [1:0] keyChunksComparator_io_maskIn; // @[Merger.scala 72:37]
  wire  keyChunksComparator_io_lastChunksMask_0; // @[Merger.scala 72:37]
  wire  keyChunksComparator_io_lastChunksMask_1; // @[Merger.scala 72:37]
  wire [1:0] keyChunksComparator_io_maskOut; // @[Merger.scala 72:37]
  wire  keyChunksComparator_io_haveWinner; // @[Merger.scala 72:37]
  wire  keyChunksComparator_io_winnerIndex; // @[Merger.scala 72:37]
  reg [31:0] keyChunks_0; // @[Merger.scala 60:24]
  reg [31:0] keyChunks_1; // @[Merger.scala 60:24]
  reg  lastKeyChunks_0; // @[Merger.scala 61:32]
  reg  lastKeyChunks_1; // @[Merger.scala 61:32]
  reg  state; // @[Merger.scala 64:24]
  reg [1:0] mask; // @[Merger.scala 67:23]
  reg  winnerIndexReg; // @[Merger.scala 68:33]
  wire  isLastRowChunkLoaded = io_bufferInputSelect & io_enq_valid; // @[Merger.scala 70:81]
  wire  _keyChunksComparator_io_in_1_T_1 = io_enq_valid & io_bufferInputSelect; // @[Merger.scala 80:62]
  wire  _GEN_3 = io_bufferInputSelect ? lastKeyChunks_1 : lastKeyChunks_0; // @[Merger.scala 95:{23,23}]
  wire  _GEN_4 = ~io_bufferInputSelect ? io_lastInput : lastKeyChunks_0; // @[Merger.scala 61:32 96:{57,57}]
  wire  _GEN_5 = io_bufferInputSelect ? io_lastInput : lastKeyChunks_1; // @[Merger.scala 61:32 96:{57,57}]
  wire  _GEN_12 = keyChunksComparator_io_haveWinner | state; // @[Merger.scala 102:58 103:27 64:24]
  KeyChunksComparator keyChunksComparator ( // @[Merger.scala 72:37]
    .io_in_0(keyChunksComparator_io_in_0),
    .io_in_1(keyChunksComparator_io_in_1),
    .io_maskIn(keyChunksComparator_io_maskIn),
    .io_lastChunksMask_0(keyChunksComparator_io_lastChunksMask_0),
    .io_lastChunksMask_1(keyChunksComparator_io_lastChunksMask_1),
    .io_maskOut(keyChunksComparator_io_maskOut),
    .io_haveWinner(keyChunksComparator_io_haveWinner),
    .io_winnerIndex(keyChunksComparator_io_winnerIndex)
  );
  assign io_enq_ready = ~state; // @[Merger.scala 126:27]
  assign io_control_isResultValid = state; // @[Merger.scala 122:39]
  assign io_control_haveWinner = state; // @[Merger.scala 123:36]
  assign io_control_winnerIndex = winnerIndexReg; // @[Merger.scala 125:28]
  assign io_control_nextKvPairsToLoad_0 = mask[0]; // @[Merger.scala 124:42]
  assign io_control_nextKvPairsToLoad_1 = mask[1]; // @[Merger.scala 124:42]
  assign keyChunksComparator_io_in_0 = keyChunks_0; // @[Merger.scala 83:42]
  assign keyChunksComparator_io_in_1 = io_enq_valid & io_bufferInputSelect ? io_enq_bits : keyChunks_1; // @[Merger.scala 80:48]
  assign keyChunksComparator_io_maskIn = mask; // @[Merger.scala 73:35]
  assign keyChunksComparator_io_lastChunksMask_0 = lastKeyChunks_0; // @[Merger.scala 84:54]
  assign keyChunksComparator_io_lastChunksMask_1 = _keyChunksComparator_io_in_1_T_1 ? io_lastInput : lastKeyChunks_1; // @[Merger.scala 81:60]
  always @(posedge clock) begin
    if (~state) begin // @[Merger.scala 88:20]
      if (io_enq_valid) begin // @[Merger.scala 90:33]
        if (~io_bufferInputSelect) begin // @[Merger.scala 91:49]
          keyChunks_0 <= io_enq_bits; // @[Merger.scala 91:49]
        end
      end
    end
    if (~state) begin // @[Merger.scala 88:20]
      if (io_enq_valid) begin // @[Merger.scala 90:33]
        if (io_bufferInputSelect) begin // @[Merger.scala 91:49]
          keyChunks_1 <= io_enq_bits; // @[Merger.scala 91:49]
        end
      end
    end
    if (reset) begin // @[Merger.scala 61:32]
      lastKeyChunks_0 <= 1'h0; // @[Merger.scala 61:32]
    end else if (~state) begin // @[Merger.scala 88:20]
      if (io_enq_valid) begin // @[Merger.scala 90:33]
        if (~_GEN_3) begin // @[Merger.scala 95:61]
          lastKeyChunks_0 <= _GEN_4;
        end
      end
    end else if (state) begin // @[Merger.scala 88:20]
      if (io_control_reset) begin // @[Merger.scala 110:37]
        lastKeyChunks_0 <= 1'h0; // @[Merger.scala 114:41]
      end
    end
    if (reset) begin // @[Merger.scala 61:32]
      lastKeyChunks_1 <= 1'h0; // @[Merger.scala 61:32]
    end else if (~state) begin // @[Merger.scala 88:20]
      if (io_enq_valid) begin // @[Merger.scala 90:33]
        if (~_GEN_3) begin // @[Merger.scala 95:61]
          lastKeyChunks_1 <= _GEN_5;
        end
      end
    end else if (state) begin // @[Merger.scala 88:20]
      if (io_control_reset) begin // @[Merger.scala 110:37]
        lastKeyChunks_1 <= 1'h0; // @[Merger.scala 114:41]
      end
    end
    if (reset) begin // @[Merger.scala 64:24]
      state <= 1'h0; // @[Merger.scala 64:24]
    end else if (~state) begin // @[Merger.scala 88:20]
      if (isLastRowChunkLoaded) begin // @[Merger.scala 100:41]
        state <= _GEN_12;
      end
    end else if (state) begin // @[Merger.scala 88:20]
      if (io_control_reset) begin // @[Merger.scala 110:37]
        state <= 1'h0; // @[Merger.scala 113:23]
      end
    end
    if (reset) begin // @[Merger.scala 67:23]
      mask <= 2'h3; // @[Merger.scala 67:23]
    end else if (~state) begin // @[Merger.scala 88:20]
      if (isLastRowChunkLoaded) begin // @[Merger.scala 100:41]
        mask <= keyChunksComparator_io_maskOut; // @[Merger.scala 101:22]
      end
    end else if (state) begin // @[Merger.scala 88:20]
      if (io_control_reset) begin // @[Merger.scala 110:37]
        mask <= io_control_mask; // @[Merger.scala 111:22]
      end
    end
    if (reset) begin // @[Merger.scala 68:33]
      winnerIndexReg <= 1'h0; // @[Merger.scala 68:33]
    end else if (~state) begin // @[Merger.scala 88:20]
      if (isLastRowChunkLoaded) begin // @[Merger.scala 100:41]
        if (keyChunksComparator_io_haveWinner) begin // @[Merger.scala 102:58]
          winnerIndexReg <= keyChunksComparator_io_winnerIndex; // @[Merger.scala 104:36]
        end
      end
    end else if (state) begin // @[Merger.scala 88:20]
      if (io_control_reset) begin // @[Merger.scala 110:37]
        winnerIndexReg <= 1'h0; // @[Merger.scala 112:32]
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
  keyChunks_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  keyChunks_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  lastKeyChunks_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  lastKeyChunks_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  state = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  mask = _RAND_5[1:0];
  _RAND_6 = {1{`RANDOM}};
  winnerIndexReg = _RAND_6[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module KVRingBuffer_2(
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
  output        io_metadataValid,
  output        io_status_empty
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
  reg [31:0] mem [0:10943]; // @[KvRingBuffer.scala 103:26]
  wire  mem_data_en; // @[KvRingBuffer.scala 103:26 205:{24,24} 103:26]
  reg [13:0] mem_data_addr; // @[KvRingBuffer.scala 103:26]
  wire [31:0] mem_data_data; // @[KvRingBuffer.scala 103:26]
  wire [31:0] mem_MPORT_data; // @[KvRingBuffer.scala 103:26 153:36]
  wire [13:0] mem_MPORT_addr; // @[KvRingBuffer.scala 103:26]
  wire  mem_MPORT_mask; // @[KvRingBuffer.scala 103:26 152:101]
  wire  mem_MPORT_en; // @[KvRingBuffer.scala 103:26 152:61]
  reg [3:0] readPtr; // @[KvRingBuffer.scala 94:29]
  wire [3:0] _nextVal_T_2 = readPtr + 4'h1; // @[KvRingBuffer.scala 95:63]
  wire [3:0] nextRead = readPtr == 4'h8 ? 4'h0 : _nextVal_T_2; // @[KvRingBuffer.scala 95:26]
  reg [3:0] outputStateReg; // @[KvRingBuffer.scala 143:33]
  wire  _GEN_129 = 4'ha == outputStateReg ? io_deq_ready : 4'hb == outputStateReg & io_deq_ready; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_135 = 4'h9 == outputStateReg ? 1'h0 : _GEN_129; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_142 = 4'h8 == outputStateReg ? 1'h0 : _GEN_135; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_148 = 4'h7 == outputStateReg ? 1'h0 : _GEN_142; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_154 = 4'h6 == outputStateReg ? 1'h0 : _GEN_148; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_161 = 4'h5 == outputStateReg ? 1'h0 : _GEN_154; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_168 = 4'h4 == outputStateReg ? 1'h0 : _GEN_161; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_176 = 4'h3 == outputStateReg ? 1'h0 : _GEN_168; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_185 = 4'h2 == outputStateReg ? 1'h0 : _GEN_176; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_194 = 4'h1 == outputStateReg ? 1'h0 : _GEN_185; // @[KvRingBuffer.scala 208:28]
  wire  incrRead = 4'h0 == outputStateReg ? 1'h0 : _GEN_194; // @[KvRingBuffer.scala 208:28]
  reg [3:0] writePtr; // @[KvRingBuffer.scala 94:29]
  wire [3:0] _nextVal_T_5 = writePtr + 4'h1; // @[KvRingBuffer.scala 95:63]
  wire [3:0] nextWrite = writePtr == 4'h8 ? 4'h0 : _nextVal_T_5; // @[KvRingBuffer.scala 95:26]
  reg [1:0] inputStateReg; // @[KvRingBuffer.scala 142:32]
  wire  _GEN_31 = 2'h1 == inputStateReg ? 1'h0 : 2'h2 == inputStateReg; // @[KvRingBuffer.scala 156:27]
  wire  incrWrite = 2'h0 == inputStateReg ? 1'h0 : _GEN_31; // @[KvRingBuffer.scala 156:27]
  reg [9:0] writeKeyChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_8 = writeKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [9:0] writeValueChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_11 = writeValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [9:0] readKeyChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_14 = readKeyChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [9:0] readValueChunkPtr; // @[KvRingBuffer.scala 94:29]
  wire [9:0] _nextVal_T_17 = readValueChunkPtr + 10'h1; // @[KvRingBuffer.scala 95:63]
  reg [31:0] keyLen; // @[KvRingBuffer.scala 127:25]
  reg [31:0] valueLen; // @[KvRingBuffer.scala 128:27]
  reg  emptyReg; // @[KvRingBuffer.scala 130:27]
  reg  fullReg; // @[KvRingBuffer.scala 131:26]
  reg [31:0] writeReg; // @[KvRingBuffer.scala 145:27]
  wire  _writeDataPtr_T = inputStateReg == 2'h0; // @[KvRingBuffer.scala 148:42]
  wire [3:0] _writeDataPtr_T_1 = io_isInputKey ? 4'h2 : 4'ha; // @[KvRingBuffer.scala 148:60]
  wire [9:0] _writeDataPtr_T_2 = io_isInputKey ? writeKeyChunkPtr : writeValueChunkPtr; // @[KvRingBuffer.scala 148:152]
  wire [9:0] _GEN_206 = {{6'd0}, _writeDataPtr_T_1}; // @[KvRingBuffer.scala 148:147]
  wire [9:0] _writeDataPtr_T_4 = _GEN_206 + _writeDataPtr_T_2; // @[KvRingBuffer.scala 148:147]
  wire [9:0] writeDataPtr = inputStateReg == 2'h0 ? _writeDataPtr_T_4 : 10'h0; // @[KvRingBuffer.scala 148:27]
  wire  metadataOffsetPtr = inputStateReg == 2'h2; // @[KvRingBuffer.scala 149:47]
  wire [9:0] _writeFullPtr_T = writePtr * 6'h26; // @[KvRingBuffer.scala 150:33]
  wire [9:0] _writeFullPtr_T_2 = _writeFullPtr_T + writeDataPtr; // @[KvRingBuffer.scala 150:42]
  wire [9:0] _GEN_207 = {{9'd0}, metadataOffsetPtr}; // @[KvRingBuffer.scala 150:57]
  wire [9:0] writeFullPtr = _writeFullPtr_T_2 + _GEN_207; // @[KvRingBuffer.scala 150:57]
  wire  _T = inputStateReg == 2'h1; // @[KvRingBuffer.scala 152:41]
  wire  _T_7 = ~fullReg; // @[KvRingBuffer.scala 158:34]
  wire [1:0] _GEN_11 = io_lastInput ? 2'h1 : inputStateReg; // @[KvRingBuffer.scala 142:32 163:40 164:39]
  wire [31:0] _GEN_12 = io_lastInput ? {{22'd0}, writeKeyChunkPtr} : writeReg; // @[KvRingBuffer.scala 145:27 163:40 165:34]
  wire  _GEN_13 = io_lastInput ? 1'h0 : emptyReg; // @[KvRingBuffer.scala 130:27 163:40 166:34]
  wire  _GEN_18 = io_isInputKey ? emptyReg : _GEN_13; // @[KvRingBuffer.scala 130:27 159:38]
  wire  _GEN_23 = io_enq_valid & ~fullReg ? _GEN_18 : emptyReg; // @[KvRingBuffer.scala 130:27 158:44]
  wire  _GEN_25 = 2'h2 == inputStateReg ? nextWrite == readPtr : fullReg; // @[KvRingBuffer.scala 156:27 179:21 131:26]
  wire  _GEN_32 = 2'h1 == inputStateReg ? fullReg : _GEN_25; // @[KvRingBuffer.scala 131:26 156:27]
  wire  _GEN_39 = 2'h0 == inputStateReg ? _GEN_23 : emptyReg; // @[KvRingBuffer.scala 130:27 156:27]
  wire  _GEN_41 = 2'h0 == inputStateReg ? fullReg : _GEN_32; // @[KvRingBuffer.scala 131:26 156:27]
  wire  writeIsIncoming = _T | metadataOffsetPtr; // @[KvRingBuffer.scala 188:62]
  wire [9:0] _readFullPtr_T = readPtr * 6'h26; // @[KvRingBuffer.scala 204:31]
  wire [9:0] _readFullPtr_T_2 = _readFullPtr_T + readValueChunkPtr; // @[KvRingBuffer.scala 204:40]
  wire [9:0] readFullPtr = _readFullPtr_T_2 + readKeyChunkPtr; // @[KvRingBuffer.scala 204:60]
  reg [31:0] shadowReg; // @[KvRingBuffer.scala 206:28]
  wire [31:0] _GEN_58 = mem_data_data; // @[KvRingBuffer.scala 228:42 229:24 127:25]
  wire [9:0] _GEN_62 = keyLen == 32'h1 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 241:38 243:39]
  wire [3:0] _GEN_63 = keyLen == 32'h1 ? 4'ha : 4'h1; // @[KvRingBuffer.scala 241:38 244:37 249:37]
  wire [3:0] _GEN_64 = keyLen == 32'h1 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 241:38 246:36 250:36]
  wire [9:0] _GEN_66 = {{6'd0}, _GEN_63}; // @[KvRingBuffer.scala 240:42]
  wire [31:0] _T_25 = keyLen - 32'h1; // @[KvRingBuffer.scala 258:54]
  wire [31:0] _GEN_208 = {{22'd0}, readKeyChunkPtr}; // @[KvRingBuffer.scala 258:43]
  wire  _T_26 = _GEN_208 == _T_25; // @[KvRingBuffer.scala 258:43]
  wire [3:0] _GEN_68 = _GEN_208 == _T_25 ? 4'h6 : outputStateReg; // @[KvRingBuffer.scala 258:61 259:40]
  wire [9:0] _GEN_69 = _GEN_208 == _T_25 ? 10'h0 : readValueChunkPtr; // @[KvRingBuffer.scala 258:61 260:43]
  wire [9:0] _GEN_70 = _GEN_208 == _T_25 ? 10'ha : _nextVal_T_14; // @[KvRingBuffer.scala 258:61 261:41 263:41]
  wire [3:0] _GEN_71 = io_deq_ready ? _GEN_68 : 4'h5; // @[KvRingBuffer.scala 257:36 268:36]
  wire [9:0] _GEN_72 = io_deq_ready ? _GEN_69 : readValueChunkPtr; // @[KvRingBuffer.scala 257:36]
  wire [9:0] _GEN_73 = io_deq_ready ? _GEN_70 : readKeyChunkPtr; // @[KvRingBuffer.scala 257:36]
  wire [31:0] _GEN_74 = io_deq_ready ? shadowReg : mem_data_data; // @[KvRingBuffer.scala 206:28 257:36 267:31]
  wire [3:0] _GEN_79 = _T_26 ? 4'h6 : 4'h4; // @[KvRingBuffer.scala 275:57 276:36 280:36]
  wire [3:0] _GEN_82 = io_deq_ready ? _GEN_79 : outputStateReg; // @[KvRingBuffer.scala 274:57]
  wire [3:0] _GEN_85 = valueLen == 32'h1 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 292:48 293:44 295:44]
  wire [9:0] _GEN_86 = valueLen == 32'h1 ? readValueChunkPtr : 10'h1; // @[KvRingBuffer.scala 292:48 296:47]
  wire [3:0] _GEN_89 = io_deq_ready ? _GEN_85 : 4'h7; // @[KvRingBuffer.scala 288:36 301:36]
  wire [9:0] _GEN_90 = io_deq_ready ? _GEN_86 : readValueChunkPtr; // @[KvRingBuffer.scala 288:36]
  wire [3:0] _GEN_98 = io_deq_ready ? _GEN_85 : outputStateReg; // @[KvRingBuffer.scala 307:57]
  wire [31:0] _T_43 = valueLen - 32'h1; // @[KvRingBuffer.scala 324:57]
  wire [31:0] _GEN_210 = {{22'd0}, readValueChunkPtr}; // @[KvRingBuffer.scala 324:44]
  wire  _T_44 = _GEN_210 == _T_43; // @[KvRingBuffer.scala 324:44]
  wire [3:0] _GEN_100 = _GEN_210 == _T_43 ? 4'ha : outputStateReg; // @[KvRingBuffer.scala 324:64 325:40]
  wire [9:0] _GEN_101 = _GEN_210 == _T_43 ? readValueChunkPtr : _nextVal_T_17; // @[KvRingBuffer.scala 324:64 327:43]
  wire [3:0] _GEN_102 = io_deq_ready ? _GEN_100 : 4'h9; // @[KvRingBuffer.scala 323:36 332:36]
  wire [9:0] _GEN_103 = io_deq_ready ? _GEN_101 : readValueChunkPtr; // @[KvRingBuffer.scala 323:36]
  wire [3:0] _GEN_107 = _T_44 ? 4'ha : 4'h8; // @[KvRingBuffer.scala 339:60 340:36 342:36]
  wire [3:0] _GEN_109 = io_deq_ready ? _GEN_107 : outputStateReg; // @[KvRingBuffer.scala 338:57]
  wire [3:0] _GEN_111 = io_deq_ready ? 4'h0 : 4'hb; // @[KvRingBuffer.scala 350:36 351:36 358:36]
  wire  _GEN_113 = io_deq_ready ? nextRead == writePtr & ~writeIsIncoming : _GEN_39; // @[KvRingBuffer.scala 192:18 350:36]
  wire  _GEN_114 = io_deq_ready ? 1'h0 : _GEN_41; // @[KvRingBuffer.scala 193:17 350:36]
  wire [3:0] _GEN_120 = io_deq_ready ? 4'h0 : outputStateReg; // @[KvRingBuffer.scala 364:57 365:32]
  wire [3:0] _GEN_124 = 4'hb == outputStateReg ? _GEN_120 : outputStateReg; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_126 = 4'hb == outputStateReg ? _GEN_113 : _GEN_39; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_127 = 4'hb == outputStateReg ? _GEN_114 : _GEN_41; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_128 = 4'ha == outputStateReg ? _GEN_111 : _GEN_124; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_130 = 4'ha == outputStateReg ? _GEN_113 : _GEN_126; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_131 = 4'ha == outputStateReg ? _GEN_114 : _GEN_127; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_132 = 4'ha == outputStateReg ? _GEN_74 : shadowReg; // @[KvRingBuffer.scala 206:28 208:28]
  wire [3:0] _GEN_133 = 4'h9 == outputStateReg ? _GEN_109 : _GEN_128; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_134 = 4'h9 == outputStateReg ? _GEN_103 : readValueChunkPtr; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_136 = 4'h9 == outputStateReg ? _GEN_39 : _GEN_130; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_137 = 4'h9 == outputStateReg ? _GEN_41 : _GEN_131; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_138 = 4'h9 == outputStateReg ? shadowReg : _GEN_132; // @[KvRingBuffer.scala 206:28 208:28]
  wire [3:0] _GEN_139 = 4'h8 == outputStateReg ? _GEN_102 : _GEN_133; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_140 = 4'h8 == outputStateReg ? _GEN_103 : _GEN_134; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_141 = 4'h8 == outputStateReg ? _GEN_74 : _GEN_138; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_143 = 4'h8 == outputStateReg ? _GEN_39 : _GEN_136; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_144 = 4'h8 == outputStateReg ? _GEN_41 : _GEN_137; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_145 = 4'h7 == outputStateReg ? _GEN_98 : _GEN_139; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_146 = 4'h7 == outputStateReg ? _GEN_90 : _GEN_140; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_147 = 4'h7 == outputStateReg ? shadowReg : _GEN_141; // @[KvRingBuffer.scala 206:28 208:28]
  wire  _GEN_149 = 4'h7 == outputStateReg ? _GEN_39 : _GEN_143; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_150 = 4'h7 == outputStateReg ? _GEN_41 : _GEN_144; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_151 = 4'h6 == outputStateReg ? _GEN_89 : _GEN_145; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_152 = 4'h6 == outputStateReg ? _GEN_90 : _GEN_146; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_153 = 4'h6 == outputStateReg ? _GEN_74 : _GEN_147; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_155 = 4'h6 == outputStateReg ? _GEN_39 : _GEN_149; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_156 = 4'h6 == outputStateReg ? _GEN_41 : _GEN_150; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_157 = 4'h5 == outputStateReg ? _GEN_82 : _GEN_151; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_158 = 4'h5 == outputStateReg ? _GEN_72 : _GEN_152; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_159 = 4'h5 == outputStateReg ? _GEN_73 : readKeyChunkPtr; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_160 = 4'h5 == outputStateReg ? shadowReg : _GEN_153; // @[KvRingBuffer.scala 206:28 208:28]
  wire  _GEN_162 = 4'h5 == outputStateReg ? _GEN_39 : _GEN_155; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_163 = 4'h5 == outputStateReg ? _GEN_41 : _GEN_156; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_164 = 4'h4 == outputStateReg ? _GEN_71 : _GEN_157; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_165 = 4'h4 == outputStateReg ? _GEN_72 : _GEN_158; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_166 = 4'h4 == outputStateReg ? _GEN_73 : _GEN_159; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_167 = 4'h4 == outputStateReg ? _GEN_74 : _GEN_160; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_169 = 4'h4 == outputStateReg ? _GEN_39 : _GEN_162; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_170 = 4'h4 == outputStateReg ? _GEN_41 : _GEN_163; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_171 = 4'h3 == outputStateReg ? mem_data_data : valueLen; // @[KvRingBuffer.scala 208:28 239:22 128:27]
  wire [9:0] _GEN_172 = 4'h3 == outputStateReg ? _GEN_62 : _GEN_165; // @[KvRingBuffer.scala 208:28]
  wire [9:0] _GEN_173 = 4'h3 == outputStateReg ? _GEN_66 : _GEN_166; // @[KvRingBuffer.scala 208:28]
  wire [3:0] _GEN_174 = 4'h3 == outputStateReg ? _GEN_64 : _GEN_164; // @[KvRingBuffer.scala 208:28]
  wire [31:0] _GEN_175 = 4'h3 == outputStateReg ? shadowReg : _GEN_167; // @[KvRingBuffer.scala 206:28 208:28]
  wire  _GEN_177 = 4'h3 == outputStateReg ? _GEN_39 : _GEN_169; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_178 = 4'h3 == outputStateReg ? _GEN_41 : _GEN_170; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_186 = 4'h2 == outputStateReg ? _GEN_39 : _GEN_177; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_195 = 4'h1 == outputStateReg ? _GEN_39 : _GEN_186; // @[KvRingBuffer.scala 208:28]
  wire  _GEN_204 = 4'h0 == outputStateReg ? _GEN_39 : _GEN_195; // @[KvRingBuffer.scala 208:28]
  wire  _io_deq_valid_T_3 = outputStateReg == 4'h5; // @[KvRingBuffer.scala 374:111]
  wire  _io_deq_valid_T_5 = outputStateReg == 4'h7; // @[KvRingBuffer.scala 374:148]
  wire  _io_deq_valid_T_9 = outputStateReg == 4'ha; // @[KvRingBuffer.scala 374:232]
  wire  _io_deq_valid_T_11 = outputStateReg == 4'h9; // @[KvRingBuffer.scala 374:273]
  wire  _io_deq_valid_T_13 = outputStateReg == 4'hb; // @[KvRingBuffer.scala 374:312]
  assign mem_data_en = 1'h1; // @[KvRingBuffer.scala 205:{24,24} 103:26]
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_data_data = mem[mem_data_addr]; // @[KvRingBuffer.scala 103:26]
  `else
  assign mem_data_data = mem_data_addr >= 14'h2ac0 ? _RAND_2[31:0] : mem[mem_data_addr]; // @[KvRingBuffer.scala 103:26]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_MPORT_data = _writeDataPtr_T ? io_enq_bits : writeReg; // @[KvRingBuffer.scala 153:36]
  assign mem_MPORT_addr = {{4'd0}, writeFullPtr};
  assign mem_MPORT_mask = 1'h1; // @[KvRingBuffer.scala 152:101]
  assign mem_MPORT_en = io_enq_valid | inputStateReg == 2'h1 | metadataOffsetPtr; // @[KvRingBuffer.scala 152:61]
  assign io_enq_ready = _writeDataPtr_T & _T_7; // @[KvRingBuffer.scala 373:51]
  assign io_deq_valid = outputStateReg == 4'h4 | outputStateReg == 4'h6 | outputStateReg == 4'h5 | outputStateReg == 4'h7
     | outputStateReg == 4'h8 | outputStateReg == 4'ha | outputStateReg == 4'h9 | outputStateReg == 4'hb; // @[KvRingBuffer.scala 374:294]
  assign io_deq_bits = _io_deq_valid_T_3 | _io_deq_valid_T_5 | _io_deq_valid_T_11 | _io_deq_valid_T_13 ? shadowReg :
    mem_data_data; // @[KvRingBuffer.scala 375:23]
  assign io_lastOutput = _io_deq_valid_T_9 | _io_deq_valid_T_13; // @[KvRingBuffer.scala 377:61]
  assign io_metadataValid = outputStateReg == 4'h2 | outputStateReg == 4'h3; // @[KvRingBuffer.scala 382:61]
  assign io_status_empty = emptyReg; // @[KvRingBuffer.scala 378:21]
  always @(posedge clock) begin
    if (mem_data_en) begin
      mem_data_addr <= {{4'd0}, readFullPtr}; // @[KvRingBuffer.scala 205:24]
    end
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[KvRingBuffer.scala 103:26]
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      readPtr <= 4'h0; // @[KvRingBuffer.scala 94:29]
    end else if (incrRead) begin // @[KvRingBuffer.scala 96:21]
      if (readPtr == 4'h8) begin // @[KvRingBuffer.scala 95:26]
        readPtr <= 4'h0;
      end else begin
        readPtr <= _nextVal_T_2;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 143:33]
      outputStateReg <= 4'h0; // @[KvRingBuffer.scala 143:33]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 212:54]
        outputStateReg <= 4'h1; // @[KvRingBuffer.scala 215:32]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      outputStateReg <= 4'h2;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      outputStateReg <= 4'h3;
    end else begin
      outputStateReg <= _GEN_174;
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      writePtr <= 4'h0; // @[KvRingBuffer.scala 94:29]
    end else if (incrWrite) begin // @[KvRingBuffer.scala 96:21]
      if (writePtr == 4'h8) begin // @[KvRingBuffer.scala 95:26]
        writePtr <= 4'h0;
      end else begin
        writePtr <= _nextVal_T_5;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 142:32]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 142:32]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 159:38]
          inputStateReg <= _GEN_11;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      inputStateReg <= 2'h2; // @[KvRingBuffer.scala 173:27]
    end else if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      inputStateReg <= 2'h0; // @[KvRingBuffer.scala 182:27]
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (io_isInputKey) begin // @[KvRingBuffer.scala 159:38]
          writeKeyChunkPtr <= _nextVal_T_8; // @[KvRingBuffer.scala 160:38]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 156:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
        writeKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 183:30]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 159:38]
          writeValueChunkPtr <= _nextVal_T_11; // @[KvRingBuffer.scala 162:40]
        end
      end
    end else if (!(2'h1 == inputStateReg)) begin // @[KvRingBuffer.scala 156:27]
      if (2'h2 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
        writeValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 184:32]
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 212:54]
        readKeyChunkPtr <= 10'h0; // @[KvRingBuffer.scala 213:33]
      end
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      readKeyChunkPtr <= 10'h1;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      readKeyChunkPtr <= 10'h0;
    end else begin
      readKeyChunkPtr <= _GEN_173;
    end
    if (reset) begin // @[KvRingBuffer.scala 94:29]
      readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 94:29]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      if (~emptyReg) begin // @[KvRingBuffer.scala 212:54]
        readValueChunkPtr <= 10'h0; // @[KvRingBuffer.scala 214:35]
      end
    end else if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
        readValueChunkPtr <= 10'h2;
      end else begin
        readValueChunkPtr <= _GEN_172;
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 127:25]
      keyLen <= 32'h0; // @[KvRingBuffer.scala 127:25]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
        if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
          keyLen <= _GEN_58;
        end
      end
    end
    if (reset) begin // @[KvRingBuffer.scala 128:27]
      valueLen <= 32'h0; // @[KvRingBuffer.scala 128:27]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
          valueLen <= _GEN_171;
        end
      end
    end
    emptyReg <= reset | _GEN_204; // @[KvRingBuffer.scala 130:{27,27}]
    if (reset) begin // @[KvRingBuffer.scala 131:26]
      fullReg <= 1'h0; // @[KvRingBuffer.scala 131:26]
    end else if (4'h0 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      fullReg <= _GEN_41;
    end else if (4'h1 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      fullReg <= _GEN_41;
    end else if (4'h2 == outputStateReg) begin // @[KvRingBuffer.scala 208:28]
      fullReg <= _GEN_41;
    end else begin
      fullReg <= _GEN_178;
    end
    if (reset) begin // @[KvRingBuffer.scala 145:27]
      writeReg <= 32'h0; // @[KvRingBuffer.scala 145:27]
    end else if (2'h0 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      if (io_enq_valid & ~fullReg) begin // @[KvRingBuffer.scala 158:44]
        if (!(io_isInputKey)) begin // @[KvRingBuffer.scala 159:38]
          writeReg <= _GEN_12;
        end
      end
    end else if (2'h1 == inputStateReg) begin // @[KvRingBuffer.scala 156:27]
      writeReg <= {{22'd0}, writeValueChunkPtr}; // @[KvRingBuffer.scala 174:22]
    end
    if (reset) begin // @[KvRingBuffer.scala 206:28]
      shadowReg <= 32'h0; // @[KvRingBuffer.scala 206:28]
    end else if (!(4'h0 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
      if (!(4'h1 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
        if (!(4'h2 == outputStateReg)) begin // @[KvRingBuffer.scala 208:28]
          shadowReg <= _GEN_175;
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
  for (initvar = 0; initvar < 10944; initvar = initvar+1)
    mem[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  mem_data_addr = _RAND_1[13:0];
  _RAND_3 = {1{`RANDOM}};
  readPtr = _RAND_3[3:0];
  _RAND_4 = {1{`RANDOM}};
  outputStateReg = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  writePtr = _RAND_5[3:0];
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
module Controller(
  input        clock,
  input        reset,
  input        io_control_start,
  output       io_control_busy,
  input        io_decoders_0_lastSeen,
  input        io_decoders_1_lastSeen,
  input        io_inputBuffers_0_status_empty,
  input        io_inputBuffers_0_status_halfFull,
  output       io_inputBuffers_0_control_moveReadPtr,
  input        io_inputBuffers_1_status_empty,
  input        io_inputBuffers_1_status_halfFull,
  output       io_inputBuffers_1_control_moveReadPtr,
  input        io_outputBuffer_empty,
  output [1:0] io_kvTransfer_command,
  output       io_kvTransfer_stop,
  output       io_kvTransfer_bufferInputSelect,
  output [1:0] io_kvTransfer_mask,
  input        io_kvTransfer_busy,
  output       io_merger_reset,
  output [1:0] io_merger_mask,
  input        io_merger_isResultValid,
  input        io_merger_haveWinner,
  input        io_merger_winnerIndex,
  input        io_merger_nextKvPairsToLoad_0,
  input        io_merger_nextKvPairsToLoad_1,
  output       io_encoder_lastDataIsProcessed
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] state; // @[Controller.scala 36:24]
  reg  mask_0; // @[Controller.scala 40:23]
  reg  mask_1; // @[Controller.scala 40:23]
  wire  _dataFinishedButBufferNotEmpty_T = ~io_inputBuffers_0_status_empty; // @[Controller.scala 45:72]
  wire  dataFinishedButBufferNotEmpty = io_decoders_0_lastSeen & ~io_inputBuffers_0_status_empty; // @[Controller.scala 45:69]
  wire  buffersStatus_0 = io_inputBuffers_0_status_halfFull | dataFinishedButBufferNotEmpty; // @[Controller.scala 46:64]
  wire  _dataFinishedButBufferNotEmpty_T_1 = ~io_inputBuffers_1_status_empty; // @[Controller.scala 45:72]
  wire  dataFinishedButBufferNotEmpty_1 = io_decoders_1_lastSeen & ~io_inputBuffers_1_status_empty; // @[Controller.scala 45:69]
  wire  buffersStatus_1 = io_inputBuffers_1_status_halfFull | dataFinishedButBufferNotEmpty_1; // @[Controller.scala 46:64]
  wire [1:0] maskAsUInt = {mask_1,mask_0}; // @[Cat.scala 33:92]
  wire [1:0] numberOfActiveBuffers = mask_0 + mask_1; // @[Bitwise.scala 51:90]
  wire  onlyOneBufferActive = numberOfActiveBuffers == 2'h1; // @[Controller.scala 54:53]
  wire  noActiveBuffers = numberOfActiveBuffers == 2'h0; // @[Controller.scala 55:49]
  wire [1:0] _buffersHaveData_T = {buffersStatus_1,buffersStatus_0}; // @[Cat.scala 33:92]
  wire [1:0] _buffersHaveData_T_1 = maskAsUInt & _buffersHaveData_T; // @[Controller.scala 56:39]
  wire  buffersHaveData = _buffersHaveData_T_1 == maskAsUInt & ~noActiveBuffers; // @[Controller.scala 56:84]
  wire [3:0] _GEN_1 = onlyOneBufferActive ? 4'h6 : 4'h2; // @[Controller.scala 68:44 70:27 73:27]
  wire [3:0] _GEN_2 = io_outputBuffer_empty ? 4'h0 : 4'h9; // @[Controller.scala 76:46 77:27 79:27]
  wire [3:0] _GEN_3 = noActiveBuffers ? _GEN_2 : state; // @[Controller.scala 36:24 75:42]
  wire [3:0] _GEN_5 = io_merger_haveWinner & io_merger_isResultValid ? 4'h5 : state; // @[Controller.scala 93:68 94:23 36:24]
  wire [3:0] _GEN_6 = ~io_kvTransfer_busy ? 4'h8 : state; // @[Controller.scala 107:40 108:23 36:24]
  wire [3:0] _GEN_7 = io_outputBuffer_empty ? 4'h0 : state; // @[Controller.scala 117:42 118:23 36:24]
  wire [3:0] _GEN_8 = 4'h9 == state ? _GEN_7 : state; // @[Controller.scala 59:20 36:24]
  wire [3:0] _GEN_9 = 4'h8 == state ? 4'h1 : _GEN_8; // @[Controller.scala 113:19 59:20]
  wire [3:0] _GEN_10 = 4'h7 == state ? _GEN_6 : _GEN_9; // @[Controller.scala 59:20]
  wire [3:0] _GEN_11 = 4'h6 == state ? 4'h7 : _GEN_10; // @[Controller.scala 103:19 59:20]
  wire [3:0] _GEN_12 = 4'h5 == state ? 4'h6 : _GEN_11; // @[Controller.scala 59:20 99:19]
  wire [3:0] _GEN_13 = 4'h4 == state ? _GEN_5 : _GEN_12; // @[Controller.scala 59:20]
  wire [3:0] _GEN_14 = 4'h3 == state ? 4'h4 : _GEN_13; // @[Controller.scala 59:20 89:19]
  wire  _io_inputBuffers_0_control_moveReadPtr_T_1 = onlyOneBufferActive ? mask_0 : io_merger_nextKvPairsToLoad_0; // @[Controller.scala 138:80]
  wire  _io_inputBuffers_1_control_moveReadPtr_T_1 = onlyOneBufferActive ? mask_1 : io_merger_nextKvPairsToLoad_1; // @[Controller.scala 138:80]
  wire  _io_kvTransfer_bufferInputSelect_T = mask_0 ? 1'h0 : 1'h1; // @[Mux.scala 47:70]
  wire  _T_13 = state == 4'h3; // @[Controller.scala 150:24]
  assign io_control_busy = state != 4'h0; // @[Controller.scala 124:30]
  assign io_inputBuffers_0_control_moveReadPtr = state == 4'h8 & _io_inputBuffers_0_control_moveReadPtr_T_1 &
    _dataFinishedButBufferNotEmpty_T; // @[Controller.scala 138:143]
  assign io_inputBuffers_1_control_moveReadPtr = state == 4'h8 & _io_inputBuffers_1_control_moveReadPtr_T_1 &
    _dataFinishedButBufferNotEmpty_T_1; // @[Controller.scala 138:143]
  assign io_kvTransfer_command = state == 4'h6 ? 2'h2 : {{1'd0}, _T_13}; // @[Controller.scala 148:38 149:31]
  assign io_kvTransfer_stop = state == 4'h2 | state == 4'h5; // @[Controller.scala 147:53]
  assign io_kvTransfer_bufferInputSelect = onlyOneBufferActive ? _io_kvTransfer_bufferInputSelect_T :
    io_merger_winnerIndex; // @[Controller.scala 146:43]
  assign io_kvTransfer_mask = {mask_1,mask_0}; // @[Cat.scala 33:92]
  assign io_merger_reset = state == 4'h3; // @[Controller.scala 157:30]
  assign io_merger_mask = {mask_1,mask_0}; // @[Cat.scala 33:92]
  assign io_encoder_lastDataIsProcessed = state == 4'h1 & noActiveBuffers & io_outputBuffer_empty | state == 4'h9 &
    io_outputBuffer_empty; // @[Controller.scala 57:104]
  always @(posedge clock) begin
    if (reset) begin // @[Controller.scala 36:24]
      state <= 4'h0; // @[Controller.scala 36:24]
    end else if (4'h0 == state) begin // @[Controller.scala 59:20]
      if (io_control_start) begin // @[Controller.scala 61:37]
        state <= 4'h1; // @[Controller.scala 62:23]
      end
    end else if (4'h1 == state) begin // @[Controller.scala 59:20]
      if (buffersHaveData) begin // @[Controller.scala 67:36]
        state <= _GEN_1;
      end else begin
        state <= _GEN_3;
      end
    end else if (4'h2 == state) begin // @[Controller.scala 59:20]
      state <= 4'h3; // @[Controller.scala 85:19]
    end else begin
      state <= _GEN_14;
    end
    mask_0 <= reset | ~(io_decoders_0_lastSeen & io_inputBuffers_0_status_empty); // @[Controller.scala 40:{23,23} 49:17]
    mask_1 <= reset | ~(io_decoders_1_lastSeen & io_inputBuffers_1_status_empty); // @[Controller.scala 40:{23,23} 49:17]
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
  state = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  mask_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  mask_1 = _RAND_2[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module CompactionUnit(
  input         clock,
  input         reset,
  input         io_control_start,
  output        io_control_busy,
  output [31:0] io_encoder_axi_m_tdata,
  output        io_encoder_axi_m_tvalid,
  input         io_encoder_axi_m_tready,
  output        io_encoder_axi_m_tlast,
  input  [31:0] io_decoders_0_axi_s_tdata,
  input         io_decoders_0_axi_s_tvalid,
  output        io_decoders_0_axi_s_tready,
  input  [31:0] io_decoders_1_axi_s_tdata,
  input         io_decoders_1_axi_s_tvalid,
  output        io_decoders_1_axi_s_tready
);
  wire  encoder_clock; // @[CompactionUnit.scala 23:25]
  wire  encoder_reset; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_control_lastDataIsProcessed; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_input_deq_ready; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_input_deq_valid; // @[CompactionUnit.scala 23:25]
  wire [31:0] encoder_io_input_deq_bits; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_input_lastOutput; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_input_metadataValid; // @[CompactionUnit.scala 23:25]
  wire [31:0] encoder_io_output_axi_m_tdata; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_output_axi_m_tvalid; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_output_axi_m_tready; // @[CompactionUnit.scala 23:25]
  wire  encoder_io_output_axi_m_tlast; // @[CompactionUnit.scala 23:25]
  wire  DummyDecoder_clock; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_reset; // @[CompactionUnit.scala 25:15]
  wire [31:0] DummyDecoder_io_input_axi_s_tdata; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_input_axi_s_tvalid; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_input_axi_s_tready; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_output_enq_ready; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_output_enq_valid; // @[CompactionUnit.scala 25:15]
  wire [31:0] DummyDecoder_io_output_enq_bits; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_output_lastInput; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_output_isInputKey; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_io_control_lastKvPairSeen; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_clock; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_reset; // @[CompactionUnit.scala 25:15]
  wire [31:0] DummyDecoder_1_io_input_axi_s_tdata; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_input_axi_s_tvalid; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_input_axi_s_tready; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_output_enq_ready; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_output_enq_valid; // @[CompactionUnit.scala 25:15]
  wire [31:0] DummyDecoder_1_io_output_enq_bits; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_output_lastInput; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_output_isInputKey; // @[CompactionUnit.scala 25:15]
  wire  DummyDecoder_1_io_control_lastKvPairSeen; // @[CompactionUnit.scala 25:15]
  wire  KVRingBuffer_clock; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_reset; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_enq_ready; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_enq_valid; // @[CompactionUnit.scala 28:15]
  wire [31:0] KVRingBuffer_io_enq_bits; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_lastInput; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_isInputKey; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_control_moveReadPtr; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_control_resetRead; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_deq_ready; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_deq_valid; // @[CompactionUnit.scala 28:15]
  wire [31:0] KVRingBuffer_io_deq_bits; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_outputKeyOnly; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_lastOutput; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_isOutputKey; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_status_empty; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_status_full; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_io_status_halfFull; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_clock; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_reset; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_enq_ready; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_enq_valid; // @[CompactionUnit.scala 28:15]
  wire [31:0] KVRingBuffer_1_io_enq_bits; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_lastInput; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_isInputKey; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_control_moveReadPtr; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_control_resetRead; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_deq_ready; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_deq_valid; // @[CompactionUnit.scala 28:15]
  wire [31:0] KVRingBuffer_1_io_deq_bits; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_outputKeyOnly; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_lastOutput; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_isOutputKey; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_status_empty; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_status_full; // @[CompactionUnit.scala 28:15]
  wire  KVRingBuffer_1_io_status_halfFull; // @[CompactionUnit.scala 28:15]
  wire  kvTransfer_clock; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_reset; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_enq_0_ready; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_enq_0_valid; // @[CompactionUnit.scala 30:28]
  wire [31:0] kvTransfer_io_enq_0_bits; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_enq_1_ready; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_enq_1_valid; // @[CompactionUnit.scala 30:28]
  wire [31:0] kvTransfer_io_enq_1_bits; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_deq_ready; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_deq_valid; // @[CompactionUnit.scala 30:28]
  wire [31:0] kvTransfer_io_deq_bits; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_deqKvPair_ready; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_deqKvPair_valid; // @[CompactionUnit.scala 30:28]
  wire [31:0] kvTransfer_io_deqKvPair_bits; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_lastInputs_0; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_lastInputs_1; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_isInputKey_0; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_isInputKey_1; // @[CompactionUnit.scala 30:28]
  wire [1:0] kvTransfer_io_control_command; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_control_stop; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_control_bufferInputSelect; // @[CompactionUnit.scala 30:28]
  wire [1:0] kvTransfer_io_control_mask; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_control_busy; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_bufferSelect; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_outputKeyOnly; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_incrKeyBufferPtr; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_clearKeyBuffer; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_lastOutput; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_resetBufferRead; // @[CompactionUnit.scala 30:28]
  wire  kvTransfer_io_isOutputKey; // @[CompactionUnit.scala 30:28]
  wire  keyBuffer_clock; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_reset; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_enq_ready; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_enq_valid; // @[CompactionUnit.scala 31:27]
  wire [31:0] keyBuffer_io_enq_bits; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_deq_ready; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_deq_valid; // @[CompactionUnit.scala 31:27]
  wire [31:0] keyBuffer_io_deq_bits; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_bufferInputSelect; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_incrWritePtr; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_clearBuffer; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_lastInput; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_bufferOutputSelect; // @[CompactionUnit.scala 31:27]
  wire  keyBuffer_io_lastOutput; // @[CompactionUnit.scala 31:27]
  wire  merger_clock; // @[CompactionUnit.scala 32:24]
  wire  merger_reset; // @[CompactionUnit.scala 32:24]
  wire  merger_io_enq_ready; // @[CompactionUnit.scala 32:24]
  wire  merger_io_enq_valid; // @[CompactionUnit.scala 32:24]
  wire [31:0] merger_io_enq_bits; // @[CompactionUnit.scala 32:24]
  wire  merger_io_bufferInputSelect; // @[CompactionUnit.scala 32:24]
  wire  merger_io_lastInput; // @[CompactionUnit.scala 32:24]
  wire  merger_io_control_reset; // @[CompactionUnit.scala 32:24]
  wire [1:0] merger_io_control_mask; // @[CompactionUnit.scala 32:24]
  wire  merger_io_control_isResultValid; // @[CompactionUnit.scala 32:24]
  wire  merger_io_control_haveWinner; // @[CompactionUnit.scala 32:24]
  wire  merger_io_control_winnerIndex; // @[CompactionUnit.scala 32:24]
  wire  merger_io_control_nextKvPairsToLoad_0; // @[CompactionUnit.scala 32:24]
  wire  merger_io_control_nextKvPairsToLoad_1; // @[CompactionUnit.scala 32:24]
  wire  outputBuffer_clock; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_reset; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_enq_ready; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_enq_valid; // @[CompactionUnit.scala 33:30]
  wire [31:0] outputBuffer_io_enq_bits; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_lastInput; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_isInputKey; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_deq_ready; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_deq_valid; // @[CompactionUnit.scala 33:30]
  wire [31:0] outputBuffer_io_deq_bits; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_lastOutput; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_metadataValid; // @[CompactionUnit.scala 33:30]
  wire  outputBuffer_io_status_empty; // @[CompactionUnit.scala 33:30]
  wire  controller_clock; // @[CompactionUnit.scala 34:28]
  wire  controller_reset; // @[CompactionUnit.scala 34:28]
  wire  controller_io_control_start; // @[CompactionUnit.scala 34:28]
  wire  controller_io_control_busy; // @[CompactionUnit.scala 34:28]
  wire  controller_io_decoders_0_lastSeen; // @[CompactionUnit.scala 34:28]
  wire  controller_io_decoders_1_lastSeen; // @[CompactionUnit.scala 34:28]
  wire  controller_io_inputBuffers_0_status_empty; // @[CompactionUnit.scala 34:28]
  wire  controller_io_inputBuffers_0_status_halfFull; // @[CompactionUnit.scala 34:28]
  wire  controller_io_inputBuffers_0_control_moveReadPtr; // @[CompactionUnit.scala 34:28]
  wire  controller_io_inputBuffers_1_status_empty; // @[CompactionUnit.scala 34:28]
  wire  controller_io_inputBuffers_1_status_halfFull; // @[CompactionUnit.scala 34:28]
  wire  controller_io_inputBuffers_1_control_moveReadPtr; // @[CompactionUnit.scala 34:28]
  wire  controller_io_outputBuffer_empty; // @[CompactionUnit.scala 34:28]
  wire [1:0] controller_io_kvTransfer_command; // @[CompactionUnit.scala 34:28]
  wire  controller_io_kvTransfer_stop; // @[CompactionUnit.scala 34:28]
  wire  controller_io_kvTransfer_bufferInputSelect; // @[CompactionUnit.scala 34:28]
  wire [1:0] controller_io_kvTransfer_mask; // @[CompactionUnit.scala 34:28]
  wire  controller_io_kvTransfer_busy; // @[CompactionUnit.scala 34:28]
  wire  controller_io_merger_reset; // @[CompactionUnit.scala 34:28]
  wire [1:0] controller_io_merger_mask; // @[CompactionUnit.scala 34:28]
  wire  controller_io_merger_isResultValid; // @[CompactionUnit.scala 34:28]
  wire  controller_io_merger_haveWinner; // @[CompactionUnit.scala 34:28]
  wire  controller_io_merger_winnerIndex; // @[CompactionUnit.scala 34:28]
  wire  controller_io_merger_nextKvPairsToLoad_0; // @[CompactionUnit.scala 34:28]
  wire  controller_io_merger_nextKvPairsToLoad_1; // @[CompactionUnit.scala 34:28]
  wire  controller_io_encoder_lastDataIsProcessed; // @[CompactionUnit.scala 34:28]
  DummyEncoder encoder ( // @[CompactionUnit.scala 23:25]
    .clock(encoder_clock),
    .reset(encoder_reset),
    .io_control_lastDataIsProcessed(encoder_io_control_lastDataIsProcessed),
    .io_input_deq_ready(encoder_io_input_deq_ready),
    .io_input_deq_valid(encoder_io_input_deq_valid),
    .io_input_deq_bits(encoder_io_input_deq_bits),
    .io_input_lastOutput(encoder_io_input_lastOutput),
    .io_input_metadataValid(encoder_io_input_metadataValid),
    .io_output_axi_m_tdata(encoder_io_output_axi_m_tdata),
    .io_output_axi_m_tvalid(encoder_io_output_axi_m_tvalid),
    .io_output_axi_m_tready(encoder_io_output_axi_m_tready),
    .io_output_axi_m_tlast(encoder_io_output_axi_m_tlast)
  );
  DummyDecoder DummyDecoder ( // @[CompactionUnit.scala 25:15]
    .clock(DummyDecoder_clock),
    .reset(DummyDecoder_reset),
    .io_input_axi_s_tdata(DummyDecoder_io_input_axi_s_tdata),
    .io_input_axi_s_tvalid(DummyDecoder_io_input_axi_s_tvalid),
    .io_input_axi_s_tready(DummyDecoder_io_input_axi_s_tready),
    .io_output_enq_ready(DummyDecoder_io_output_enq_ready),
    .io_output_enq_valid(DummyDecoder_io_output_enq_valid),
    .io_output_enq_bits(DummyDecoder_io_output_enq_bits),
    .io_output_lastInput(DummyDecoder_io_output_lastInput),
    .io_output_isInputKey(DummyDecoder_io_output_isInputKey),
    .io_control_lastKvPairSeen(DummyDecoder_io_control_lastKvPairSeen)
  );
  DummyDecoder DummyDecoder_1 ( // @[CompactionUnit.scala 25:15]
    .clock(DummyDecoder_1_clock),
    .reset(DummyDecoder_1_reset),
    .io_input_axi_s_tdata(DummyDecoder_1_io_input_axi_s_tdata),
    .io_input_axi_s_tvalid(DummyDecoder_1_io_input_axi_s_tvalid),
    .io_input_axi_s_tready(DummyDecoder_1_io_input_axi_s_tready),
    .io_output_enq_ready(DummyDecoder_1_io_output_enq_ready),
    .io_output_enq_valid(DummyDecoder_1_io_output_enq_valid),
    .io_output_enq_bits(DummyDecoder_1_io_output_enq_bits),
    .io_output_lastInput(DummyDecoder_1_io_output_lastInput),
    .io_output_isInputKey(DummyDecoder_1_io_output_isInputKey),
    .io_control_lastKvPairSeen(DummyDecoder_1_io_control_lastKvPairSeen)
  );
  KVRingBuffer KVRingBuffer ( // @[CompactionUnit.scala 28:15]
    .clock(KVRingBuffer_clock),
    .reset(KVRingBuffer_reset),
    .io_enq_ready(KVRingBuffer_io_enq_ready),
    .io_enq_valid(KVRingBuffer_io_enq_valid),
    .io_enq_bits(KVRingBuffer_io_enq_bits),
    .io_lastInput(KVRingBuffer_io_lastInput),
    .io_isInputKey(KVRingBuffer_io_isInputKey),
    .io_control_moveReadPtr(KVRingBuffer_io_control_moveReadPtr),
    .io_control_resetRead(KVRingBuffer_io_control_resetRead),
    .io_deq_ready(KVRingBuffer_io_deq_ready),
    .io_deq_valid(KVRingBuffer_io_deq_valid),
    .io_deq_bits(KVRingBuffer_io_deq_bits),
    .io_outputKeyOnly(KVRingBuffer_io_outputKeyOnly),
    .io_lastOutput(KVRingBuffer_io_lastOutput),
    .io_isOutputKey(KVRingBuffer_io_isOutputKey),
    .io_status_empty(KVRingBuffer_io_status_empty),
    .io_status_full(KVRingBuffer_io_status_full),
    .io_status_halfFull(KVRingBuffer_io_status_halfFull)
  );
  KVRingBuffer KVRingBuffer_1 ( // @[CompactionUnit.scala 28:15]
    .clock(KVRingBuffer_1_clock),
    .reset(KVRingBuffer_1_reset),
    .io_enq_ready(KVRingBuffer_1_io_enq_ready),
    .io_enq_valid(KVRingBuffer_1_io_enq_valid),
    .io_enq_bits(KVRingBuffer_1_io_enq_bits),
    .io_lastInput(KVRingBuffer_1_io_lastInput),
    .io_isInputKey(KVRingBuffer_1_io_isInputKey),
    .io_control_moveReadPtr(KVRingBuffer_1_io_control_moveReadPtr),
    .io_control_resetRead(KVRingBuffer_1_io_control_resetRead),
    .io_deq_ready(KVRingBuffer_1_io_deq_ready),
    .io_deq_valid(KVRingBuffer_1_io_deq_valid),
    .io_deq_bits(KVRingBuffer_1_io_deq_bits),
    .io_outputKeyOnly(KVRingBuffer_1_io_outputKeyOnly),
    .io_lastOutput(KVRingBuffer_1_io_lastOutput),
    .io_isOutputKey(KVRingBuffer_1_io_isOutputKey),
    .io_status_empty(KVRingBuffer_1_io_status_empty),
    .io_status_full(KVRingBuffer_1_io_status_full),
    .io_status_halfFull(KVRingBuffer_1_io_status_halfFull)
  );
  TopKvTransfer kvTransfer ( // @[CompactionUnit.scala 30:28]
    .clock(kvTransfer_clock),
    .reset(kvTransfer_reset),
    .io_enq_0_ready(kvTransfer_io_enq_0_ready),
    .io_enq_0_valid(kvTransfer_io_enq_0_valid),
    .io_enq_0_bits(kvTransfer_io_enq_0_bits),
    .io_enq_1_ready(kvTransfer_io_enq_1_ready),
    .io_enq_1_valid(kvTransfer_io_enq_1_valid),
    .io_enq_1_bits(kvTransfer_io_enq_1_bits),
    .io_deq_ready(kvTransfer_io_deq_ready),
    .io_deq_valid(kvTransfer_io_deq_valid),
    .io_deq_bits(kvTransfer_io_deq_bits),
    .io_deqKvPair_ready(kvTransfer_io_deqKvPair_ready),
    .io_deqKvPair_valid(kvTransfer_io_deqKvPair_valid),
    .io_deqKvPair_bits(kvTransfer_io_deqKvPair_bits),
    .io_lastInputs_0(kvTransfer_io_lastInputs_0),
    .io_lastInputs_1(kvTransfer_io_lastInputs_1),
    .io_isInputKey_0(kvTransfer_io_isInputKey_0),
    .io_isInputKey_1(kvTransfer_io_isInputKey_1),
    .io_control_command(kvTransfer_io_control_command),
    .io_control_stop(kvTransfer_io_control_stop),
    .io_control_bufferInputSelect(kvTransfer_io_control_bufferInputSelect),
    .io_control_mask(kvTransfer_io_control_mask),
    .io_control_busy(kvTransfer_io_control_busy),
    .io_bufferSelect(kvTransfer_io_bufferSelect),
    .io_outputKeyOnly(kvTransfer_io_outputKeyOnly),
    .io_incrKeyBufferPtr(kvTransfer_io_incrKeyBufferPtr),
    .io_clearKeyBuffer(kvTransfer_io_clearKeyBuffer),
    .io_lastOutput(kvTransfer_io_lastOutput),
    .io_resetBufferRead(kvTransfer_io_resetBufferRead),
    .io_isOutputKey(kvTransfer_io_isOutputKey)
  );
  KeyBuffer keyBuffer ( // @[CompactionUnit.scala 31:27]
    .clock(keyBuffer_clock),
    .reset(keyBuffer_reset),
    .io_enq_ready(keyBuffer_io_enq_ready),
    .io_enq_valid(keyBuffer_io_enq_valid),
    .io_enq_bits(keyBuffer_io_enq_bits),
    .io_deq_ready(keyBuffer_io_deq_ready),
    .io_deq_valid(keyBuffer_io_deq_valid),
    .io_deq_bits(keyBuffer_io_deq_bits),
    .io_bufferInputSelect(keyBuffer_io_bufferInputSelect),
    .io_incrWritePtr(keyBuffer_io_incrWritePtr),
    .io_clearBuffer(keyBuffer_io_clearBuffer),
    .io_lastInput(keyBuffer_io_lastInput),
    .io_bufferOutputSelect(keyBuffer_io_bufferOutputSelect),
    .io_lastOutput(keyBuffer_io_lastOutput)
  );
  Merger merger ( // @[CompactionUnit.scala 32:24]
    .clock(merger_clock),
    .reset(merger_reset),
    .io_enq_ready(merger_io_enq_ready),
    .io_enq_valid(merger_io_enq_valid),
    .io_enq_bits(merger_io_enq_bits),
    .io_bufferInputSelect(merger_io_bufferInputSelect),
    .io_lastInput(merger_io_lastInput),
    .io_control_reset(merger_io_control_reset),
    .io_control_mask(merger_io_control_mask),
    .io_control_isResultValid(merger_io_control_isResultValid),
    .io_control_haveWinner(merger_io_control_haveWinner),
    .io_control_winnerIndex(merger_io_control_winnerIndex),
    .io_control_nextKvPairsToLoad_0(merger_io_control_nextKvPairsToLoad_0),
    .io_control_nextKvPairsToLoad_1(merger_io_control_nextKvPairsToLoad_1)
  );
  KVRingBuffer_2 outputBuffer ( // @[CompactionUnit.scala 33:30]
    .clock(outputBuffer_clock),
    .reset(outputBuffer_reset),
    .io_enq_ready(outputBuffer_io_enq_ready),
    .io_enq_valid(outputBuffer_io_enq_valid),
    .io_enq_bits(outputBuffer_io_enq_bits),
    .io_lastInput(outputBuffer_io_lastInput),
    .io_isInputKey(outputBuffer_io_isInputKey),
    .io_deq_ready(outputBuffer_io_deq_ready),
    .io_deq_valid(outputBuffer_io_deq_valid),
    .io_deq_bits(outputBuffer_io_deq_bits),
    .io_lastOutput(outputBuffer_io_lastOutput),
    .io_metadataValid(outputBuffer_io_metadataValid),
    .io_status_empty(outputBuffer_io_status_empty)
  );
  Controller controller ( // @[CompactionUnit.scala 34:28]
    .clock(controller_clock),
    .reset(controller_reset),
    .io_control_start(controller_io_control_start),
    .io_control_busy(controller_io_control_busy),
    .io_decoders_0_lastSeen(controller_io_decoders_0_lastSeen),
    .io_decoders_1_lastSeen(controller_io_decoders_1_lastSeen),
    .io_inputBuffers_0_status_empty(controller_io_inputBuffers_0_status_empty),
    .io_inputBuffers_0_status_halfFull(controller_io_inputBuffers_0_status_halfFull),
    .io_inputBuffers_0_control_moveReadPtr(controller_io_inputBuffers_0_control_moveReadPtr),
    .io_inputBuffers_1_status_empty(controller_io_inputBuffers_1_status_empty),
    .io_inputBuffers_1_status_halfFull(controller_io_inputBuffers_1_status_halfFull),
    .io_inputBuffers_1_control_moveReadPtr(controller_io_inputBuffers_1_control_moveReadPtr),
    .io_outputBuffer_empty(controller_io_outputBuffer_empty),
    .io_kvTransfer_command(controller_io_kvTransfer_command),
    .io_kvTransfer_stop(controller_io_kvTransfer_stop),
    .io_kvTransfer_bufferInputSelect(controller_io_kvTransfer_bufferInputSelect),
    .io_kvTransfer_mask(controller_io_kvTransfer_mask),
    .io_kvTransfer_busy(controller_io_kvTransfer_busy),
    .io_merger_reset(controller_io_merger_reset),
    .io_merger_mask(controller_io_merger_mask),
    .io_merger_isResultValid(controller_io_merger_isResultValid),
    .io_merger_haveWinner(controller_io_merger_haveWinner),
    .io_merger_winnerIndex(controller_io_merger_winnerIndex),
    .io_merger_nextKvPairsToLoad_0(controller_io_merger_nextKvPairsToLoad_0),
    .io_merger_nextKvPairsToLoad_1(controller_io_merger_nextKvPairsToLoad_1),
    .io_encoder_lastDataIsProcessed(controller_io_encoder_lastDataIsProcessed)
  );
  assign io_control_busy = controller_io_control_busy; // @[CompactionUnit.scala 80:21]
  assign io_encoder_axi_m_tdata = encoder_io_output_axi_m_tdata; // @[CompactionUnit.scala 37:29]
  assign io_encoder_axi_m_tvalid = encoder_io_output_axi_m_tvalid; // @[CompactionUnit.scala 37:29]
  assign io_encoder_axi_m_tlast = encoder_io_output_axi_m_tlast; // @[CompactionUnit.scala 37:29]
  assign io_decoders_0_axi_s_tready = DummyDecoder_io_input_axi_s_tready; // @[CompactionUnit.scala 46:24]
  assign io_decoders_1_axi_s_tready = DummyDecoder_1_io_input_axi_s_tready; // @[CompactionUnit.scala 46:24]
  assign encoder_clock = clock;
  assign encoder_reset = reset;
  assign encoder_io_control_lastDataIsProcessed = controller_io_encoder_lastDataIsProcessed; // @[CompactionUnit.scala 120:47]
  assign encoder_io_input_deq_valid = outputBuffer_io_deq_valid; // @[CompactionUnit.scala 38:26]
  assign encoder_io_input_deq_bits = outputBuffer_io_deq_bits; // @[CompactionUnit.scala 38:26]
  assign encoder_io_input_lastOutput = outputBuffer_io_lastOutput; // @[CompactionUnit.scala 40:33]
  assign encoder_io_input_metadataValid = outputBuffer_io_metadataValid; // @[CompactionUnit.scala 41:36]
  assign encoder_io_output_axi_m_tready = io_encoder_axi_m_tready; // @[CompactionUnit.scala 37:29]
  assign DummyDecoder_clock = clock;
  assign DummyDecoder_reset = reset;
  assign DummyDecoder_io_input_axi_s_tdata = io_decoders_0_axi_s_tdata; // @[CompactionUnit.scala 46:24]
  assign DummyDecoder_io_input_axi_s_tvalid = io_decoders_0_axi_s_tvalid; // @[CompactionUnit.scala 46:24]
  assign DummyDecoder_io_output_enq_ready = KVRingBuffer_io_enq_ready; // @[CompactionUnit.scala 47:35]
  assign DummyDecoder_1_clock = clock;
  assign DummyDecoder_1_reset = reset;
  assign DummyDecoder_1_io_input_axi_s_tdata = io_decoders_1_axi_s_tdata; // @[CompactionUnit.scala 46:24]
  assign DummyDecoder_1_io_input_axi_s_tvalid = io_decoders_1_axi_s_tvalid; // @[CompactionUnit.scala 46:24]
  assign DummyDecoder_1_io_output_enq_ready = KVRingBuffer_1_io_enq_ready; // @[CompactionUnit.scala 47:35]
  assign KVRingBuffer_clock = clock;
  assign KVRingBuffer_reset = reset;
  assign KVRingBuffer_io_enq_valid = DummyDecoder_io_output_enq_valid; // @[CompactionUnit.scala 47:35]
  assign KVRingBuffer_io_enq_bits = DummyDecoder_io_output_enq_bits; // @[CompactionUnit.scala 47:35]
  assign KVRingBuffer_io_lastInput = DummyDecoder_io_output_lastInput; // @[CompactionUnit.scala 49:41]
  assign KVRingBuffer_io_isInputKey = DummyDecoder_io_output_isInputKey; // @[CompactionUnit.scala 48:42]
  assign KVRingBuffer_io_control_moveReadPtr = controller_io_inputBuffers_0_control_moveReadPtr; // @[CompactionUnit.scala 93:59]
  assign KVRingBuffer_io_control_resetRead = kvTransfer_io_resetBufferRead; // @[CompactionUnit.scala 54:39]
  assign KVRingBuffer_io_deq_ready = kvTransfer_io_enq_0_ready; // @[CompactionUnit.scala 58:30]
  assign KVRingBuffer_io_outputKeyOnly = kvTransfer_io_outputKeyOnly; // @[CompactionUnit.scala 55:37]
  assign KVRingBuffer_1_clock = clock;
  assign KVRingBuffer_1_reset = reset;
  assign KVRingBuffer_1_io_enq_valid = DummyDecoder_1_io_output_enq_valid; // @[CompactionUnit.scala 47:35]
  assign KVRingBuffer_1_io_enq_bits = DummyDecoder_1_io_output_enq_bits; // @[CompactionUnit.scala 47:35]
  assign KVRingBuffer_1_io_lastInput = DummyDecoder_1_io_output_lastInput; // @[CompactionUnit.scala 49:41]
  assign KVRingBuffer_1_io_isInputKey = DummyDecoder_1_io_output_isInputKey; // @[CompactionUnit.scala 48:42]
  assign KVRingBuffer_1_io_control_moveReadPtr = controller_io_inputBuffers_1_control_moveReadPtr; // @[CompactionUnit.scala 93:59]
  assign KVRingBuffer_1_io_control_resetRead = kvTransfer_io_resetBufferRead; // @[CompactionUnit.scala 54:39]
  assign KVRingBuffer_1_io_deq_ready = kvTransfer_io_enq_1_ready; // @[CompactionUnit.scala 58:30]
  assign KVRingBuffer_1_io_outputKeyOnly = kvTransfer_io_outputKeyOnly; // @[CompactionUnit.scala 55:37]
  assign kvTransfer_clock = clock;
  assign kvTransfer_reset = reset;
  assign kvTransfer_io_enq_0_valid = KVRingBuffer_io_deq_valid; // @[CompactionUnit.scala 58:30]
  assign kvTransfer_io_enq_0_bits = KVRingBuffer_io_deq_bits; // @[CompactionUnit.scala 58:30]
  assign kvTransfer_io_enq_1_valid = KVRingBuffer_1_io_deq_valid; // @[CompactionUnit.scala 58:30]
  assign kvTransfer_io_enq_1_bits = KVRingBuffer_1_io_deq_bits; // @[CompactionUnit.scala 58:30]
  assign kvTransfer_io_deq_ready = keyBuffer_io_enq_ready; // @[CompactionUnit.scala 62:22]
  assign kvTransfer_io_deqKvPair_ready = outputBuffer_io_enq_ready; // @[CompactionUnit.scala 74:25]
  assign kvTransfer_io_lastInputs_0 = KVRingBuffer_io_lastOutput; // @[CompactionUnit.scala 56:37]
  assign kvTransfer_io_lastInputs_1 = KVRingBuffer_1_io_lastOutput; // @[CompactionUnit.scala 56:37]
  assign kvTransfer_io_isInputKey_0 = KVRingBuffer_io_isOutputKey; // @[CompactionUnit.scala 57:37]
  assign kvTransfer_io_isInputKey_1 = KVRingBuffer_1_io_isOutputKey; // @[CompactionUnit.scala 57:37]
  assign kvTransfer_io_control_command = controller_io_kvTransfer_command; // @[CompactionUnit.scala 100:38]
  assign kvTransfer_io_control_stop = controller_io_kvTransfer_stop; // @[CompactionUnit.scala 99:35]
  assign kvTransfer_io_control_bufferInputSelect = controller_io_kvTransfer_bufferInputSelect; // @[CompactionUnit.scala 102:48]
  assign kvTransfer_io_control_mask = controller_io_kvTransfer_mask; // @[CompactionUnit.scala 101:35]
  assign keyBuffer_clock = clock;
  assign keyBuffer_reset = reset;
  assign keyBuffer_io_enq_valid = kvTransfer_io_deq_valid; // @[CompactionUnit.scala 62:22]
  assign keyBuffer_io_enq_bits = kvTransfer_io_deq_bits; // @[CompactionUnit.scala 62:22]
  assign keyBuffer_io_deq_ready = merger_io_enq_ready; // @[CompactionUnit.scala 69:19]
  assign keyBuffer_io_bufferInputSelect = kvTransfer_io_bufferSelect; // @[CompactionUnit.scala 63:36]
  assign keyBuffer_io_incrWritePtr = kvTransfer_io_incrKeyBufferPtr; // @[CompactionUnit.scala 64:31]
  assign keyBuffer_io_clearBuffer = kvTransfer_io_clearKeyBuffer; // @[CompactionUnit.scala 65:30]
  assign keyBuffer_io_lastInput = kvTransfer_io_lastOutput; // @[CompactionUnit.scala 66:28]
  assign merger_clock = clock;
  assign merger_reset = reset;
  assign merger_io_enq_valid = keyBuffer_io_deq_valid; // @[CompactionUnit.scala 69:19]
  assign merger_io_enq_bits = keyBuffer_io_deq_bits; // @[CompactionUnit.scala 69:19]
  assign merger_io_bufferInputSelect = keyBuffer_io_bufferOutputSelect; // @[CompactionUnit.scala 71:33]
  assign merger_io_lastInput = keyBuffer_io_lastOutput; // @[CompactionUnit.scala 70:25]
  assign merger_io_control_reset = controller_io_merger_reset; // @[CompactionUnit.scala 109:32]
  assign merger_io_control_mask = controller_io_merger_mask; // @[CompactionUnit.scala 110:31]
  assign outputBuffer_clock = clock;
  assign outputBuffer_reset = reset;
  assign outputBuffer_io_enq_valid = kvTransfer_io_deqKvPair_valid; // @[CompactionUnit.scala 74:25]
  assign outputBuffer_io_enq_bits = kvTransfer_io_deqKvPair_bits; // @[CompactionUnit.scala 74:25]
  assign outputBuffer_io_lastInput = kvTransfer_io_lastOutput; // @[CompactionUnit.scala 75:31]
  assign outputBuffer_io_isInputKey = kvTransfer_io_isOutputKey; // @[CompactionUnit.scala 76:32]
  assign outputBuffer_io_deq_ready = encoder_io_input_deq_ready; // @[CompactionUnit.scala 38:26]
  assign controller_clock = clock;
  assign controller_reset = reset;
  assign controller_io_control_start = io_control_start; // @[CompactionUnit.scala 79:33]
  assign controller_io_decoders_0_lastSeen = DummyDecoder_io_control_lastKvPairSeen; // @[CompactionUnit.scala 85:44]
  assign controller_io_decoders_1_lastSeen = DummyDecoder_1_io_control_lastKvPairSeen; // @[CompactionUnit.scala 85:44]
  assign controller_io_inputBuffers_0_status_empty = KVRingBuffer_io_status_empty; // @[CompactionUnit.scala 90:52]
  assign controller_io_inputBuffers_0_status_halfFull = KVRingBuffer_io_status_halfFull; // @[CompactionUnit.scala 92:55]
  assign controller_io_inputBuffers_1_status_empty = KVRingBuffer_1_io_status_empty; // @[CompactionUnit.scala 90:52]
  assign controller_io_inputBuffers_1_status_halfFull = KVRingBuffer_1_io_status_halfFull; // @[CompactionUnit.scala 92:55]
  assign controller_io_outputBuffer_empty = outputBuffer_io_status_empty; // @[CompactionUnit.scala 113:38]
  assign controller_io_kvTransfer_busy = kvTransfer_io_control_busy; // @[CompactionUnit.scala 98:35]
  assign controller_io_merger_isResultValid = merger_io_control_isResultValid; // @[CompactionUnit.scala 106:40]
  assign controller_io_merger_haveWinner = merger_io_control_haveWinner; // @[CompactionUnit.scala 105:37]
  assign controller_io_merger_winnerIndex = merger_io_control_winnerIndex; // @[CompactionUnit.scala 107:38]
  assign controller_io_merger_nextKvPairsToLoad_0 = merger_io_control_nextKvPairsToLoad_0; // @[CompactionUnit.scala 108:44]
  assign controller_io_merger_nextKvPairsToLoad_1 = merger_io_control_nextKvPairsToLoad_1; // @[CompactionUnit.scala 108:44]
endmodule
module TopCompactionUnit(
  input         clock,
  input         reset,
  input         io_control_S_AXI_ACLK,
  input         io_control_S_AXI_ARESETN,
  input  [3:0]  io_control_S_AXI_AWADDR,
  input  [2:0]  io_control_S_AXI_AWPROT,
  input         io_control_S_AXI_AWVALID,
  output        io_control_S_AXI_AWREADY,
  input  [31:0] io_control_S_AXI_WDATA,
  input  [3:0]  io_control_S_AXI_WSTRB,
  input         io_control_S_AXI_WVALID,
  output        io_control_S_AXI_WREADY,
  output [1:0]  io_control_S_AXI_BRESP,
  output        io_control_S_AXI_BVALID,
  input         io_control_S_AXI_BREADY,
  input  [3:0]  io_control_S_AXI_ARADDR,
  input  [2:0]  io_control_S_AXI_ARPROT,
  input         io_control_S_AXI_ARVALID,
  output        io_control_S_AXI_ARREADY,
  output [31:0] io_control_S_AXI_RDATA,
  output [1:0]  io_control_S_AXI_RRESP,
  output        io_control_S_AXI_RVALID,
  input         io_control_S_AXI_RREADY,
  output [31:0] io_encoder_axi_m_tdata,
  output        io_encoder_axi_m_tvalid,
  input         io_encoder_axi_m_tready,
  output        io_encoder_axi_m_tlast,
  input  [31:0] io_decoders_0_axi_s_tdata,
  input         io_decoders_0_axi_s_tvalid,
  output        io_decoders_0_axi_s_tready,
  input         io_decoders_0_axi_s_tlast,
  input  [31:0] io_decoders_1_axi_s_tdata,
  input         io_decoders_1_axi_s_tvalid,
  output        io_decoders_1_axi_s_tready,
  input         io_decoders_1_axi_s_tlast
);
  wire [31:0] controlAdapter_status; // @[CompactionUnit.scala 140:32]
  wire [31:0] controlAdapter_control; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_ACLK; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_ARESETN; // @[CompactionUnit.scala 140:32]
  wire [3:0] controlAdapter_S_AXI_AWADDR; // @[CompactionUnit.scala 140:32]
  wire [2:0] controlAdapter_S_AXI_AWPROT; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_AWVALID; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_AWREADY; // @[CompactionUnit.scala 140:32]
  wire [31:0] controlAdapter_S_AXI_WDATA; // @[CompactionUnit.scala 140:32]
  wire [3:0] controlAdapter_S_AXI_WSTRB; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_WVALID; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_WREADY; // @[CompactionUnit.scala 140:32]
  wire [1:0] controlAdapter_S_AXI_BRESP; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_BVALID; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_BREADY; // @[CompactionUnit.scala 140:32]
  wire [3:0] controlAdapter_S_AXI_ARADDR; // @[CompactionUnit.scala 140:32]
  wire [2:0] controlAdapter_S_AXI_ARPROT; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_ARVALID; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_ARREADY; // @[CompactionUnit.scala 140:32]
  wire [31:0] controlAdapter_S_AXI_RDATA; // @[CompactionUnit.scala 140:32]
  wire [1:0] controlAdapter_S_AXI_RRESP; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_RVALID; // @[CompactionUnit.scala 140:32]
  wire  controlAdapter_S_AXI_RREADY; // @[CompactionUnit.scala 140:32]
  wire  compactionUnit_clock; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_reset; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_control_start; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_control_busy; // @[CompactionUnit.scala 141:32]
  wire [31:0] compactionUnit_io_encoder_axi_m_tdata; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_encoder_axi_m_tvalid; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_encoder_axi_m_tready; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_encoder_axi_m_tlast; // @[CompactionUnit.scala 141:32]
  wire [31:0] compactionUnit_io_decoders_0_axi_s_tdata; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_decoders_0_axi_s_tvalid; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_decoders_0_axi_s_tready; // @[CompactionUnit.scala 141:32]
  wire [31:0] compactionUnit_io_decoders_1_axi_s_tdata; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_decoders_1_axi_s_tvalid; // @[CompactionUnit.scala 141:32]
  wire  compactionUnit_io_decoders_1_axi_s_tready; // @[CompactionUnit.scala 141:32]
  ControlAdapterVerilog controlAdapter ( // @[CompactionUnit.scala 140:32]
    .status(controlAdapter_status),
    .control(controlAdapter_control),
    .S_AXI_ACLK(controlAdapter_S_AXI_ACLK),
    .S_AXI_ARESETN(controlAdapter_S_AXI_ARESETN),
    .S_AXI_AWADDR(controlAdapter_S_AXI_AWADDR),
    .S_AXI_AWPROT(controlAdapter_S_AXI_AWPROT),
    .S_AXI_AWVALID(controlAdapter_S_AXI_AWVALID),
    .S_AXI_AWREADY(controlAdapter_S_AXI_AWREADY),
    .S_AXI_WDATA(controlAdapter_S_AXI_WDATA),
    .S_AXI_WSTRB(controlAdapter_S_AXI_WSTRB),
    .S_AXI_WVALID(controlAdapter_S_AXI_WVALID),
    .S_AXI_WREADY(controlAdapter_S_AXI_WREADY),
    .S_AXI_BRESP(controlAdapter_S_AXI_BRESP),
    .S_AXI_BVALID(controlAdapter_S_AXI_BVALID),
    .S_AXI_BREADY(controlAdapter_S_AXI_BREADY),
    .S_AXI_ARADDR(controlAdapter_S_AXI_ARADDR),
    .S_AXI_ARPROT(controlAdapter_S_AXI_ARPROT),
    .S_AXI_ARVALID(controlAdapter_S_AXI_ARVALID),
    .S_AXI_ARREADY(controlAdapter_S_AXI_ARREADY),
    .S_AXI_RDATA(controlAdapter_S_AXI_RDATA),
    .S_AXI_RRESP(controlAdapter_S_AXI_RRESP),
    .S_AXI_RVALID(controlAdapter_S_AXI_RVALID),
    .S_AXI_RREADY(controlAdapter_S_AXI_RREADY)
  );
  CompactionUnit compactionUnit ( // @[CompactionUnit.scala 141:32]
    .clock(compactionUnit_clock),
    .reset(compactionUnit_reset),
    .io_control_start(compactionUnit_io_control_start),
    .io_control_busy(compactionUnit_io_control_busy),
    .io_encoder_axi_m_tdata(compactionUnit_io_encoder_axi_m_tdata),
    .io_encoder_axi_m_tvalid(compactionUnit_io_encoder_axi_m_tvalid),
    .io_encoder_axi_m_tready(compactionUnit_io_encoder_axi_m_tready),
    .io_encoder_axi_m_tlast(compactionUnit_io_encoder_axi_m_tlast),
    .io_decoders_0_axi_s_tdata(compactionUnit_io_decoders_0_axi_s_tdata),
    .io_decoders_0_axi_s_tvalid(compactionUnit_io_decoders_0_axi_s_tvalid),
    .io_decoders_0_axi_s_tready(compactionUnit_io_decoders_0_axi_s_tready),
    .io_decoders_1_axi_s_tdata(compactionUnit_io_decoders_1_axi_s_tdata),
    .io_decoders_1_axi_s_tvalid(compactionUnit_io_decoders_1_axi_s_tvalid),
    .io_decoders_1_axi_s_tready(compactionUnit_io_decoders_1_axi_s_tready)
  );
  assign io_control_S_AXI_AWREADY = controlAdapter_S_AXI_AWREADY; // @[CompactionUnit.scala 158:30]
  assign io_control_S_AXI_WREADY = controlAdapter_S_AXI_WREADY; // @[CompactionUnit.scala 162:29]
  assign io_control_S_AXI_BRESP = controlAdapter_S_AXI_BRESP; // @[CompactionUnit.scala 163:28]
  assign io_control_S_AXI_BVALID = controlAdapter_S_AXI_BVALID; // @[CompactionUnit.scala 164:29]
  assign io_control_S_AXI_ARREADY = controlAdapter_S_AXI_ARREADY; // @[CompactionUnit.scala 169:30]
  assign io_control_S_AXI_RDATA = controlAdapter_S_AXI_RDATA; // @[CompactionUnit.scala 170:28]
  assign io_control_S_AXI_RRESP = controlAdapter_S_AXI_RRESP; // @[CompactionUnit.scala 171:28]
  assign io_control_S_AXI_RVALID = controlAdapter_S_AXI_RVALID; // @[CompactionUnit.scala 172:29]
  assign io_encoder_axi_m_tdata = compactionUnit_io_encoder_axi_m_tdata; // @[CompactionUnit.scala 144:31]
  assign io_encoder_axi_m_tvalid = compactionUnit_io_encoder_axi_m_tvalid; // @[CompactionUnit.scala 144:31]
  assign io_encoder_axi_m_tlast = compactionUnit_io_encoder_axi_m_tlast; // @[CompactionUnit.scala 144:31]
  assign io_decoders_0_axi_s_tready = compactionUnit_io_decoders_0_axi_s_tready; // @[CompactionUnit.scala 143:32]
  assign io_decoders_1_axi_s_tready = compactionUnit_io_decoders_1_axi_s_tready; // @[CompactionUnit.scala 143:32]
  assign controlAdapter_status = {31'h0,compactionUnit_io_control_busy}; // @[Cat.scala 33:92]
  assign controlAdapter_S_AXI_ACLK = io_control_S_AXI_ACLK; // @[CompactionUnit.scala 153:34]
  assign controlAdapter_S_AXI_ARESETN = io_control_S_AXI_ARESETN; // @[CompactionUnit.scala 154:37]
  assign controlAdapter_S_AXI_AWADDR = io_control_S_AXI_AWADDR; // @[CompactionUnit.scala 155:36]
  assign controlAdapter_S_AXI_AWPROT = io_control_S_AXI_AWPROT; // @[CompactionUnit.scala 156:36]
  assign controlAdapter_S_AXI_AWVALID = io_control_S_AXI_AWVALID; // @[CompactionUnit.scala 157:37]
  assign controlAdapter_S_AXI_WDATA = io_control_S_AXI_WDATA; // @[CompactionUnit.scala 159:35]
  assign controlAdapter_S_AXI_WSTRB = io_control_S_AXI_WSTRB; // @[CompactionUnit.scala 160:35]
  assign controlAdapter_S_AXI_WVALID = io_control_S_AXI_WVALID; // @[CompactionUnit.scala 161:36]
  assign controlAdapter_S_AXI_BREADY = io_control_S_AXI_BREADY; // @[CompactionUnit.scala 165:36]
  assign controlAdapter_S_AXI_ARADDR = io_control_S_AXI_ARADDR; // @[CompactionUnit.scala 166:36]
  assign controlAdapter_S_AXI_ARPROT = io_control_S_AXI_ARPROT; // @[CompactionUnit.scala 167:36]
  assign controlAdapter_S_AXI_ARVALID = io_control_S_AXI_ARVALID; // @[CompactionUnit.scala 168:37]
  assign controlAdapter_S_AXI_RREADY = io_control_S_AXI_RREADY; // @[CompactionUnit.scala 173:36]
  assign compactionUnit_clock = clock;
  assign compactionUnit_reset = reset;
  assign compactionUnit_io_control_start = controlAdapter_control[0]; // @[CompactionUnit.scala 147:48]
  assign compactionUnit_io_encoder_axi_m_tready = io_encoder_axi_m_tready; // @[CompactionUnit.scala 144:31]
  assign compactionUnit_io_decoders_0_axi_s_tdata = io_decoders_0_axi_s_tdata; // @[CompactionUnit.scala 143:32]
  assign compactionUnit_io_decoders_0_axi_s_tvalid = io_decoders_0_axi_s_tvalid; // @[CompactionUnit.scala 143:32]
  assign compactionUnit_io_decoders_1_axi_s_tdata = io_decoders_1_axi_s_tdata; // @[CompactionUnit.scala 143:32]
  assign compactionUnit_io_decoders_1_axi_s_tvalid = io_decoders_1_axi_s_tvalid; // @[CompactionUnit.scala 143:32]
endmodule
