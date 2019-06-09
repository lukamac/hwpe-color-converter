import rgb2ycbcr_package::CHANNEL_WIDTH;
import rgb2ycbcr_package::NB_CHANNELS;
import rgb2ycbcr_package::rgb_struct;
import rgb2ycbcr_package::ycbcr_struct;

module hwpe_rgb2ycbcr #(
    parameter STREAM_WIDTH = 96
)(
    hwpe_stream_intf_stream rgb,
    hwpe_stream_intf_stream ycbcr
);

localparam NB_DATA = (STREAM_WIDTH / CHANNEL_WIDTH) / NB_CHANNELS;

rgb_struct [NB_DATA-1:0] rgb_data;
ycbcr_struct [NB_DATA-1:0] ycbcr_data;

assign rgb_data = rgb.data;

for (genvar i = 0; i < NB_DATA; i++) begin
    rgb2ycbcr rgb2ycbcr_inst (
        .in(rgb_data[i]),
        .out(ycbcr_data[i])
    );
end

assign rgb.ready = ycbcr.ready;
assign ycbcr.valid = rgb.valid;
assign ycbcr.strb  = rgb.strb;
assign ycbcr.data = ycbcr_data;

endmodule
