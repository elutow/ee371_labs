// Common constants and functions for other modules

`ifndef _COMMON_SV
`define _COMMON_SV

// Total number of colors
`define TOTAL_COLORS 5
// Number of bits necessary to represent all colors
localparam COLOR_WIDTH = $clog2(`TOTAL_COLORS);
// Add colors in descending order
localparam COLOR_BLACK = COLOR_WIDTH'('d5);
localparam COLOR_WHITE = COLOR_WIDTH'('d4);
localparam COLOR_RED = COLOR_WIDTH'('d3);
localparam COLOR_GREEN = COLOR_WIDTH'('d2);
localparam COLOR_BLUE = COLOR_WIDTH'('d1);
// Full transparency
localparam COLOR_NONE = COLOR_WIDTH'('d0);

`endif // _COMMON_SV

// vim: set expandtab shiftwidth=4 softtabstop=4:
