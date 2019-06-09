import rgb2ycbcr_package::rgb_struct;
import rgb2ycbcr_package::ycbcr_struct;

module rgb2ycbcr (
    input  rgb_struct   in,
    output ycbcr_struct out
);

logic [14:0] r;
logic [14:0] g;
logic [14:0] b;

logic [14:0] y;
logic [14:0] cb;
logic [14:0] cr;

assign r = {2'b00, in.r, 5'b00000};
assign g = {2'b00, in.g, 5'b00000};
assign b = {2'b00, in.b, 5'b00000};

always_comb begin
    y  = 15'h0010 /*0.5*/   + ( ((r>>2) + (r>>4)) + ((g>>1) + (g>>4)) + (b>>3));
    cb = 15'h1010 /*128.5*/ + (-((r>>3) + (r>>5)) - ((g>>2) + (g>>4)) + (b>>1));
    cr = 15'h1010 /*128.5*/ + ( (r>>1)            - ((g>>1) - (g>>4)) - (b>>4));
end

always_comb begin
    if (y[14])
        out.y = 8'h00;
    else if (y[13])
        out.y = 8'hFF;
    else
        out.y = y[12:5];
end

always_comb begin
    if (cb[14])
        out.cb = 8'h00;
    else if (cb[13])
        out.cb = 8'hFF;
    else
        out.cb = cb[12:5];
end

always_comb begin
    if (cr[14])
        out.cr = 8'h00;
    else if (cr[13])
        out.cr = 8'hFF;
    else
        out.cr = cr[12:5];
end

endmodule
