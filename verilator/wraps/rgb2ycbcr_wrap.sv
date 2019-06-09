module rgb2ycbcr_wrap (
    input logic [7:0] r,
    input logic [7:0] g,
    input logic [7:0] b,

    output logic [7:0] y,
    output logic [7:0] cb,
    output logic [7:0] cr
);

    rgb2ycbcr rgb2ycbcr_inst (
        .in({r, g, b}),
        .out({y, cb, cr})
    );

endmodule
