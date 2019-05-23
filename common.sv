// Common constants and functions for other modules

// Number of bits necessary to represent all colors
`define COLOR_WIDTH $clog2(5)
// Add colors in descending order
`define COLOR_BLACK `COLOR_WIDTH'd5
`define COLOR_WHITE `COLOR_WIDTH'd4
`define COLOR_RED `COLOR_WIDTH'd3
`define COLOR_GREEN `COLOR_WIDTH'd2
`define COLOR_BLUE `COLOR_WIDTH'd1
// Full transparency
`define COLOR_NONE `COLOR_WIDTH'd0

// vim: set expandtab shiftwidth=4 softtabstop=4:
