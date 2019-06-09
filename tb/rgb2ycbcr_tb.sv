import rgb2ycbcr_package::*;

module rgb2ycbcr_tb;

rgb_struct in;
ycbcr_struct out;

rgb2ycbcr dut(in, out);

initial begin
    in.r = 255;
    in.g = 255;
    in.b = 255;

    #5

    in.r = 0;
    in.g = 0;
    in.b = 0;

    #5

    in.r = 50;
    in.g = 180;
    in.b = 100;

    #5 $finish;
end

endmodule
