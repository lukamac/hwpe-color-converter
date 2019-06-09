// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2017 by Wilson Snyder.
//======================================================================

// Include common routines
#include <verilated.h>
#include <netpbm/pam.h>

// Include model header, generated from Verilating "top.v"
#include "Vrgb2ycbcr_wrap.h"

// If "verilator --trace" is used, include the tracing class
#if VM_TRACE
# include <verilated_vcd_c.h>
#endif

double clip(double x){
    if (x < 0.0)
        return 0.0;
    else if (x > 255.0)
        return 255.0;
    return x;
}

void rgb2ycbcr(int r, int g, int b, double *y, double *cb, double *cr) {
    *y  = clip(      (0.299   * r + 0.587  * g + 0.114  * b));
    *cb = clip(128 + (-0.1687 * r - 0.3313 * g + 0.5    * b));
    *cr = clip(128 + (0.5     * r - 0.4187 * g - 0.0813 * b));
}

// Current simulation time (64-bit unsigned)
vluint64_t main_time = 0;
// Called by $time in Verilog
double sc_time_stamp() {
    return main_time;  // Note does conversion to real, to match SystemC
}

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (0 && argc && argv && env) {}

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs
    Verilated::debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs
    Verilated::randReset(2);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    Verilated::commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v"
    Vrgb2ycbcr_wrap* top = new Vrgb2ycbcr_wrap; // Or use a const unique_ptr, or the VL_UNIQUE_PTR wrapper

#if VM_TRACE
    // If verilator was invoked with --trace argument,
    // and if at run time passed the +trace argument, turn on tracing
    VerilatedVcdC* tfp = NULL;
    const char* flag = Verilated::commandArgsPlusMatch("trace");
    if (flag && 0==strcmp(flag, "+trace")) {
        Verilated::traceEverOn(true);  // Verilator must compute traced signals
        VL_PRINTF("Enabling waves into logs/vlt_dump.vcd...\n");
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);  // Trace 99 levels of hierarchy
        Verilated::mkdir("logs");
        tfp->open("logs/vlt_dump_valid_on_14.vcd");  // Open the dump file
    }
#endif

    struct pam inpam, result, golden;
    tuple *tuplerow;
    tuple *ycbcr_golden_row;
    tuple *ycbcr_result_row;
    FILE *fresult;
    FILE *fgolden;

    pm_init(argv[0], 0);

    pnm_readpaminit(stdin, &inpam, PAM_STRUCT_SIZE(tuple_type));

    fgolden = fopen("golden.ppm", "w");
    fresult = fopen("result.ppm", "w");

    golden = inpam; golden.file = fgolden; golden.plainformat = 1;
    result = inpam; result.file = fresult; result.plainformat = 1;

    pnm_writepaminit(&golden);
    pnm_writepaminit(&result);

    tuplerow = pnm_allocpamrow(&inpam);
    ycbcr_golden_row = pnm_allocpamrow(&inpam);
    ycbcr_result_row = pnm_allocpamrow(&inpam);

    for (int row = 0; row < inpam.height; ++row) {
        pnm_readpamrow(&inpam, tuplerow);
        for (int column = 0; column < inpam.width; ++column) {
            double y, cb, cr;
            //pnm_YCbCrtuple(tuplerow[column], &YP, &CrP, &CbP);
            rgb2ycbcr(tuplerow[column][0], tuplerow[column][1], tuplerow[column][2], &y, &cb, &cr);
            ycbcr_golden_row[column][0] = y;
            ycbcr_golden_row[column][1] = cb;
            ycbcr_golden_row[column][2] = cr;

            top->r = tuplerow[column][0];
            top->g = tuplerow[column][1];
            top->b = tuplerow[column][2];
            top->eval();
            ycbcr_result_row[column][0] = top->y;
            ycbcr_result_row[column][1] = top->cb;
            ycbcr_result_row[column][2] = top->cr;
        }
        pnm_writepamrow(&golden, ycbcr_golden_row);
        pnm_writepamrow(&result, ycbcr_result_row);
    }
    pnm_freepamrow(tuplerow);
    pnm_freepamrow(ycbcr_golden_row);
    pnm_freepamrow(ycbcr_result_row);


    // Final model cleanup
    top->final();

    // Close trace if opened
#if VM_TRACE
    if (tfp) { tfp->close(); tfp = NULL; }
#endif

    //  Coverage analysis (since test passed)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    VerilatedCov::write("logs/coverage.dat");
#endif

    // Destroy model
    delete top; top = NULL;

    // Fin
    exit(0);
}
