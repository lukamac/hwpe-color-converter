import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module hwpe_color_converter #(
    parameter N_CORES = 2,
    parameter ID_WIDTH = 16,
    parameter STREAM_WIDTH = 96
)(
    input  logic                  clk,
    input  logic                  rst_n,

    output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt,
  
    hwpe_stream_intf_tcdm.master  tcdm[(STREAM_WIDTH/32)*2],
    hwpe_ctrl_intf_periph.slave   slave_config_interface
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
  logic clear;
  flags_sourcesink_t source_stream_flags;
  ctrl_sourcesink_t source_stream_ctrl;
  flags_sourcesink_t sink_stream_flags;
  ctrl_sourcesink_t sink_stream_ctrl;
  flags_slave_t control_flags;
  
//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

  streamer #(
    .STREAM_WIDTH(STREAM_WIDTH)
  ) streamer_inst (
    .clk_i(clk),
    .rst_ni(rst_n),
    .clear_i(clear),
    .tcdm_load(tcdm[0 +: STREAM_WIDTH/32]),
    .tcdm_store(tcdm[STREAM_WIDTH/32 +: STREAM_WIDTH/32]),
    .source_stream_ctrl_i(source_stream_ctrl),
    .source_stream_flags_o(source_stream_flags),
    .sink_stream_ctrl_i(sink_stream_ctrl),
    .sink_stream_flags_o(sink_stream_flags)
  );

  control #(
    .ID_WIDTH(ID_WIDTH),
    .N_CORES(N_CORES),
    .N_CONTEXT(2)
  ) control_inst (
    .clk_i(clk),
    .rst_ni(rst_n),
    .clear_o(clear),
    .source_stream_ctrl_o(source_stream_ctrl),
    .source_stream_flags_i(source_stream_flags),
    .sink_stream_ctrl_o(sink_stream_ctrl),
    .sink_stream_flags_i(sink_stream_flags),
    .ctrl_flags_o(control_flags),
    .slave_config_interface(slave_config_interface)
  );
  
  assign evt = control_flags.evt[N_CORES-1:0];

endmodule
