import rgb2ycbcr_package::CHANNEL_WIDTH;
import rgb2ycbcr_package::NB_CHANNELS;
import rgb2ycbcr_package::rgb_struct;
import rgb2ycbcr_package::ycbcr_struct;

module hwpe_rgb2ycbcr #(
    parameter STREAM_WIDTH = 96,
    parameter REGISTERED = 0
)(
    logic clk,
    logic rst_n,
    logic clear,
    hwpe_stream_intf_stream rgb,
    hwpe_stream_intf_stream ycbcr
);

localparam NB_DATA = (STREAM_WIDTH / (NB_CHANNELS * CHANNEL_WIDTH));

rgb_struct [NB_DATA-1:0] rgb_data;
ycbcr_struct [NB_DATA-1:0] ycbcr_data;

logic ycbcr_valid_reg;
ycbcr_struct [STREAM_WIDTH-1:0] ycbcr_data_reg;
logic [STREAM_WIDTH/32 - 1:0] ycbcr_strb_reg;

assign rgb_data = rgb.data;

for (genvar i = 0; i < NB_DATA; i++) begin
    rgb2ycbcr rgb2ycbcr_inst (
        .in(rgb_data[i]),
        .out(ycbcr_data[i])
    );
end

assign rgb.ready = ycbcr.ready;

generate
if (REGISTERED == 0) begin

    assign ycbcr.valid = rgb.valid;
    assign ycbcr.strb  = rgb.strb;
    assign ycbcr.data = ycbcr_data;

end else if (REGISTERED == 1) begin

    always_ff @(posedge clk, negedge rst_n)
    begin
        if (~rst_n) begin
            ycbcr_valid_reg <= '0;
            ycbcr_data_reg  <= '0;
            ycbcr_strb_reg  <= '0;
        end else if (clear) begin
            ycbcr_valid_reg <= '0;
            ycbcr_data_reg  <= '0;
            ycbcr_strb_reg  <= '0;
        end else begin
            ycbcr_valid_reg <= rgb.valid;
            ycbcr_data_reg  <= ycbcr_data;
            ycbcr_strb_reg  <= rgb.strb;
        end
    end

    assign ycbcr.valid = ycbcr_valid_reg;
    assign ycbcr.strb  = ycbcr_strb_reg;
    assign ycbcr.data  = ycbcr_data_reg;

end
endgenerate

endmodule
