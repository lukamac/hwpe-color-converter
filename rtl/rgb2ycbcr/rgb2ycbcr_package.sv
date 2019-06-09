package rgb2ycbcr_package;

    parameter CHANNEL_WIDTH = 8;
    parameter NB_CHANNELS = 3;

    typedef struct packed {
        logic [CHANNEL_WIDTH-1:0] r;
        logic [CHANNEL_WIDTH-1:0] g;
        logic [CHANNEL_WIDTH-1:0] b;
    } rgb_struct;

    typedef struct packed {
        logic [CHANNEL_WIDTH-1:0] y;
        logic [CHANNEL_WIDTH-1:0] cb;
        logic [CHANNEL_WIDTH-1:0] cr;
    } ycbcr_struct;

endpackage
