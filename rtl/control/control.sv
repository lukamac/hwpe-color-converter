`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import control_registers::*;

module control
#(
  parameter int unsigned ID_WIDTH = 16,
  parameter int unsigned N_CORES = 2,
  parameter int unsigned N_CONTEXT = 2
)
(
  input  logic clk_i,
  input  logic rst_ni,
  output logic clear_o,
  
  // source stream control and flags
  output ctrl_sourcesink_t     source_stream_ctrl_o,
  input  flags_sourcesink_t    source_stream_flags_i,
  
  // sink stream control and flags
  output ctrl_sourcesink_t      sink_stream_ctrl_o,
  input  flags_sourcesink_t     sink_stream_flags_i,
  
  // control module flags
  output flags_slave_t          ctrl_flags_o,
  
  // HWPE configuration interface on peripheral bus
  hwpe_ctrl_intf_periph.slave   slave_config_interface
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  ctrl_slave_t   slave_control;  // done and event flags must be set here
  ctrl_regfile_t registers;      // IO and generic registers values are contained here

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

// HWPE CONTROL
  hwpe_ctrl_slave #(
    .N_CORES (N_CORES),
    .N_CONTEXT (N_CONTEXT),
    .N_EVT (REGFILE_N_EVT),
    .N_IO_REGS (16),
    .N_GENERIC_REGS (0),
    .N_SW_EVT (0), // not used
    .ID_WIDTH (ID_WIDTH)
  ) hwpe_control (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .clear_o (clear_o),
    .cfg (slave_config_interface),
    .ctrl_i (slave_control),
    .flags_o (ctrl_flags_o),
    .reg_file (registers)
  );

//======================================================//
//                CONTROL LOGIC                         //
//======================================================//

  // CONTROL FOR HWPE_CTRL MODULE
  assign slave_control.done = sink_stream_flags_i.done; // everything is done when sink stream is done
  assign slave_control.evt = 0; // events currently not used
  
  // START TRIGGER ON STREAM INTERFACES
  assign source_stream_ctrl_o.req_start = ctrl_flags_o.start;
  assign sink_stream_ctrl_o.req_start = ctrl_flags_o.start;
  
  // RGB ADDRESGEN CONTROL
  assign source_stream_ctrl_o.addressgen_ctrl.base_addr   = registers.hwpe_params[RGB_BASE_ADDR_INDEX];
  assign source_stream_ctrl_o.addressgen_ctrl.line_stride = registers.hwpe_params[RGB_LINE_STRIDE_INDEX][31:16];
  assign source_stream_ctrl_o.addressgen_ctrl.line_length = registers.hwpe_params[RGB_LINE_LENGTH_INDEX][15:0];
  assign source_stream_ctrl_o.addressgen_ctrl.feat_stride = registers.hwpe_params[RGB_FEAT_STRIDE_INDEX][31:16];
  assign source_stream_ctrl_o.addressgen_ctrl.feat_length = registers.hwpe_params[RGB_FEAT_LENGTH_INDEX][15:0];
  assign source_stream_ctrl_o.addressgen_ctrl.loop_outer  = registers.hwpe_params[RGB_LOOP_OUTER_INDEX][16];
  assign source_stream_ctrl_o.addressgen_ctrl.feat_roll   = registers.hwpe_params[RGB_FEAT_ROLL_INDEX][15:0];
  assign source_stream_ctrl_o.addressgen_ctrl.trans_size  = registers.hwpe_params[TRANSACTION_SIZE_INDEX];
  assign source_stream_ctrl_o.addressgen_ctrl.realign_type = 0;
  assign source_stream_ctrl_o.addressgen_ctrl.line_length_remainder = 0;
  
  // YCBCR ADDRESGEN CONTROL
  assign sink_stream_ctrl_o.addressgen_ctrl.base_addr   = registers.hwpe_params[YCBCR_BASE_ADDR_INDEX];
  assign sink_stream_ctrl_o.addressgen_ctrl.line_stride = registers.hwpe_params[YCBCR_LINE_STRIDE_INDEX][31:16];
  assign sink_stream_ctrl_o.addressgen_ctrl.line_length = registers.hwpe_params[YCBCR_LINE_LENGTH_INDEX][15:0];
  assign sink_stream_ctrl_o.addressgen_ctrl.feat_stride = registers.hwpe_params[YCBCR_FEAT_STRIDE_INDEX][31:16];
  assign sink_stream_ctrl_o.addressgen_ctrl.feat_length = registers.hwpe_params[YCBCR_FEAT_LENGTH_INDEX][15:0];
  assign sink_stream_ctrl_o.addressgen_ctrl.loop_outer  = registers.hwpe_params[YCBCR_LOOP_OUTER_INDEX][16];
  assign sink_stream_ctrl_o.addressgen_ctrl.feat_roll   = registers.hwpe_params[YCBCR_FEAT_ROLL_INDEX][15:0];
  assign sink_stream_ctrl_o.addressgen_ctrl.trans_size  = registers.hwpe_params[TRANSACTION_SIZE_INDEX];
  assign sink_stream_ctrl_o.addressgen_ctrl.realign_type = 0;
  assign sink_stream_ctrl_o.addressgen_ctrl.line_length_remainder = 0;

endmodule
