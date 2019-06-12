`timescale 1ns / 1ps

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;

module streamer
#(
    parameter STREAM_WIDTH  = 96
)
(
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  logic                  clear_i,

    hwpe_stream_intf_tcdm.master  tcdm_load[STREAM_WIDTH/32],
    hwpe_stream_intf_tcdm.master  tcdm_store[STREAM_WIDTH/32],

    input ctrl_sourcesink_t       source_stream_ctrl_i,
    output flags_sourcesink_t     source_stream_flags_o,

    input ctrl_sourcesink_t       sink_stream_ctrl_i,
    output flags_sourcesink_t     sink_stream_flags_o
);

//======================================================//
//                SIGNALS AND INTERFACES                //
//======================================================//
logic stream_source_fifo_ready;

hwpe_stream_intf_tcdm tcdm_internal_source[STREAM_WIDTH/32] (
    .clk ( clk_i )
);

hwpe_stream_intf_tcdm tcdm_internal_sink[STREAM_WIDTH/32] (
    .clk ( clk_i )
);

hwpe_stream_intf_stream #( STREAM_WIDTH )
rgb ( clk_i );

hwpe_stream_intf_stream #( STREAM_WIDTH )
ycbcr ( clk_i );

//======================================================//
//                    INSTANTIATIONS                    //
//======================================================//

// HWPE STREAM
for (genvar i = 0; i < STREAM_WIDTH/32; i++) begin
    hwpe_stream_tcdm_fifo_load #(
      .FIFO_DEPTH (8),
      .LATCH_FIFO (0)
    ) fifo_load (
      .clk_i (clk_i),
      .rst_ni (rst_ni),
      .clear_i (clear_i),
      .flags_o (),
      .ready_i (stream_source_fifo_ready),
      .tcdm_slave (tcdm_internal_source[i]),
      .tcdm_master (tcdm_load[i])
    );
end

hwpe_stream_source #(
    .DATA_WIDTH (STREAM_WIDTH),
    .NB_TCDM_PORTS (STREAM_WIDTH/32),
    .DECOUPLED (1),
    .LATCH_FIFO (0),
    .TRANS_CNT (16)
) stream_source (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .test_mode_i (1'b0),
    .clear_i (clear_i),
    .tcdm (tcdm_internal_source),
    .stream (rgb),
    .tcdm_fifo_ready_o (stream_source_fifo_ready),
    .ctrl_i (source_stream_ctrl_i),
    .flags_o (source_stream_flags_o)
);

hwpe_rgb2ycbcr #(
    .STREAM_WIDTH(STREAM_WIDTH),
    .REGISTERED(0)
) hwpe_rgb2ycbcr_inst (
    .clk(clk_i),
    .rst_n(rst_ni),
    .clear(clear_i),
    .rgb(rgb),
    .ycbcr(ycbcr)
);

hwpe_stream_sink #(
    .DATA_WIDTH (STREAM_WIDTH),
    .NB_TCDM_PORTS (STREAM_WIDTH/32),
    .USE_TCDM_FIFOS (1)
) stream_sink (
    .clk_i (clk_i),
    .rst_ni (rst_ni),
    .test_mode_i (1'b0),
    .clear_i (clear_i),
    .tcdm (tcdm_internal_sink),
    .stream (ycbcr),
    .ctrl_i (sink_stream_ctrl_i),
    .flags_o (sink_stream_flags_o)
);

for (genvar i = 0; i < STREAM_WIDTH/32; i++) begin
    hwpe_stream_tcdm_fifo_store #(
        .FIFO_DEPTH (8),
        .LATCH_FIFO (0)
    ) fifo_store (
        .clk_i (clk_i),
        .rst_ni (rst_ni),
        .clear_i (clear_i),
        .flags_o (),
        .tcdm_slave (tcdm_internal_sink[i]),
        .tcdm_master (tcdm_store[i])
    );
end

endmodule
