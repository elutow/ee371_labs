/*
 * Color VGA Framebuffer
 *
 * Stephen A. Edwards, Columbia University
 */

module VGA_framebuffer
#(parameter WIDTH=640, HEIGHT=480) // NOTE: VGA driver is currently hardcoded to 640x480
(
 input logic        clk50, reset,
 input logic [7:0] r, g, b, // Pixel color

 output logic [$clog2(WIDTH)-1:0] request_x,
 output logic [$clog2(HEIGHT)-1:0] request_y,
 output logic [7:0] VGA_R, VGA_G, VGA_B,
 output logic       VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);

/*
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 *
 *HCOUNT 1599 0             1279       1599 0
 *            _______________              ________
 * __________|    Video      |____________|  Video
 *
 *
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 */

   parameter HACTIVE      = 11'd 1280,
             HFRONT_PORCH = 11'd 32,
             HSYNC        = 11'd 192,
             HBACK_PORCH  = 11'd 96,
             HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH; //1600

   parameter VACTIVE      = 10'd 480,
             VFRONT_PORCH = 10'd 10,
             VSYNC        = 10'd 2,
             VBACK_PORCH  = 10'd 33,
             VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH; //525

   logic [10:0] hcount; // Horizontal counter
   logic endOfLine;

   always_ff @(posedge clk50)
     if (reset)          hcount <= 0;
     else if (endOfLine) hcount <= 0;
     else                hcount <= hcount + 11'd 1;

   assign endOfLine = hcount == HTOTAL - 1;

   // Vertical counter
   logic [9:0] vcount;
   logic endOfField;

   always_ff @(posedge clk50)
     if (reset)          vcount <= 0;
     else if (endOfLine)
       if (endOfField)   vcount <= 0;
       else              vcount <= vcount + 10'd 1;

   assign endOfField = vcount == VTOTAL - 1;

   // Horizontal sync: from 0x520 to 0x57F
   // 101 0010 0000 to 101 0111 1111
   assign VGA_HS = !( (hcount[10:7] == 4'b1010) & (hcount[6] | hcount[5]));
   assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);

   assign VGA_SYNC_n = 1; // For adding sync to video signals; not used for VGA

   // Horizontal active: 0 to 1279     Vertical active: 0 to 479
   // 101 0000 0000  1280           01 1110 0000  480
   // 110 0011 1111  1599           10 0000 1100  524
   logic blank;
   assign blank = ( hcount[10] & (hcount[9] | hcount[8]) ) |
          ( vcount[9] | (vcount[8:5] == 4'b1111) );

   assign request_x = hcount >= WIDTH ? $clog2(WIDTH)'(639) : hcount[$clog2(WIDTH)-1:0];
   assign request_y = vcount >= HEIGHT ? $clog2(HEIGHT)'(479) : vcount[$clog2(HEIGHT)-1:0];

   always_ff @(posedge clk50) begin
      if (hcount[0]) begin
         VGA_R <= r;
         VGA_G <= g;
         VGA_B <= b;
         VGA_BLANK_n <= ~blank; // Keep blank in sync with pixel data
      end
   end

   assign VGA_CLK = hcount[0]; // 25 MHz clock: pixel latched on rising edge

endmodule

// vim: set expandtab shiftwidth=3 softtabstop=3:
