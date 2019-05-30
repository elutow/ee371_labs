
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module terasic_camera(
		input logic reset, take_picture, READ_Request,
		output logic [7:0] out_r, out_g, out_b,

		//////////// CLOCK //////////
		input 		          		CLOCK2_50,
		input 		          		CLOCK3_50,
		input 		          		CLOCK_50,

		//////////// SDRAM //////////
		output		    [12:0]		DRAM_ADDR,
		output		    [1:0]		  DRAM_BA,
		output		          		DRAM_CAS_N,
		output		          		DRAM_CKE,
		output		          		DRAM_CLK,
		output		          		DRAM_CS_N,
		inout 		    [15:0]		DRAM_DQ,
		output		          		DRAM_RAS_N,
		output		          		DRAM_WE_N,

		//////////// VGA //////////
		input VGA_HS,
		input VGA_VS,
		input VGA_CLK,

		//////////// GPIO_1, GPIO_1 connect to D8M-GPIO //////////
		output 		          		CAMERA_I2C_SCL,
		inout 		          		CAMERA_I2C_SDA,
		output		          		CAMERA_PWDN_n,
		output		          		MIPI_CS_n,
		inout 		          		MIPI_I2C_SCL,
		inout 		          		MIPI_I2C_SDA,
		output		          		MIPI_MCLK,
		input 		          		MIPI_PIXEL_CLK,
		input 		     [9:0]		MIPI_PIXEL_D,
		input 		          		MIPI_PIXEL_HS,
		input 		          		MIPI_PIXEL_VS,
		output		          		MIPI_REFCLK,
		output		          		MIPI_RESET_n
);

//=============================================================================
// REG/WIRE declarations
//=============================================================================


wire	[15:0]SDRAM_RD_DATA;
wire			DLY_RST_0;
wire			DLY_RST_1;

wire			SDRAM_CTRL_CLK;
wire        D8M_CK_HZ ;
wire        D8M_CK_HZ2 ;
wire        D8M_CK_HZ3 ;

wire [7:0] RED   ;
wire [7:0] GREEN  ;
wire [7:0] BLUE 		 ;

wire        RESET_N  ;

wire        I2C_RELEASE ;
wire        AUTO_FOC ;
wire        CAMERA_I2C_SCL_MIPI ;
wire        CAMERA_I2C_SCL_AF;
wire        CAMERA_MIPI_RELAESE ;
wire        MIPI_BRIDGE_RELEASE ;

wire        LUT_MIPI_PIXEL_HS;
wire        LUT_MIPI_PIXEL_VS;
wire [9:0]  LUT_MIPI_PIXEL_D  ;
wire        MIPI_PIXEL_CLK_;
wire [9:0]  PCK;
//=======================================================
// Structural coding
//=======================================================
//--INPU MIPI-PIXEL-CLOCK DELAY
CLOCK_DELAY  del1(  .iCLK (MIPI_PIXEL_CLK),  .oCLK (MIPI_PIXEL_CLK_ ) );


assign LUT_MIPI_PIXEL_HS=MIPI_PIXEL_HS;
assign LUT_MIPI_PIXEL_VS=MIPI_PIXEL_VS;
assign LUT_MIPI_PIXEL_D =MIPI_PIXEL_D ;

//------UART OFF --
assign UART_RTS =0;
assign UART_TXD =0;
//------HEX OFF --
//assign HEX2           = 7'h7F;
//assign HEX3           = 7'h7F;
//assign HEX4           = 7'h7F;
//assign HEX5           = 7'h7F;

//------ MIPI BRIGE & CAMERA RESET  --
assign CAMERA_PWDN_n  = 1;
assign MIPI_CS_n      = 0;
assign MIPI_RESET_n   = RESET_N ;

//------ CAMERA MODULE I2C SWITCH  --
assign I2C_RELEASE    = CAMERA_MIPI_RELAESE & MIPI_BRIDGE_RELEASE;
assign CAMERA_I2C_SCL =( I2C_RELEASE  )?  CAMERA_I2C_SCL_AF  : CAMERA_I2C_SCL_MIPI ;

//----- RESET RELAY  --
RESET_DELAY			u2	(
							.iRST  ( ~reset ),
                     .iCLK  ( CLOCK2_50 ),
							.oRST_0( DLY_RST_0 ),
							.oRST_1( DLY_RST_1 ),
							.oRST_2( ),
						   .oREADY( RESET_N)

						);

//------ MIPI BRIGE & CAMERA SETTING  --
MIPI_BRIDGE_CAMERA_Config    cfin(
                      .RESET_N           ( RESET_N ),
                      .CLK_50            ( CLOCK2_50 ),
                      .MIPI_I2C_SCL      ( MIPI_I2C_SCL ),
                      .MIPI_I2C_SDA      ( MIPI_I2C_SDA ),
                      .MIPI_I2C_RELEASE  ( MIPI_BRIDGE_RELEASE ),
                      .CAMERA_I2C_SCL    ( CAMERA_I2C_SCL_MIPI ),
                      .CAMERA_I2C_SDA    ( CAMERA_I2C_SDA ),
                      .CAMERA_I2C_RELAESE( CAMERA_MIPI_RELAESE )
             );

//------MIPI / VGA REF CLOCK  --
pll_test pll_ref(
	                   .inclk0 ( CLOCK3_50 ),
	                   .areset ( reset ),
	                   .c0( MIPI_REFCLK    ) //20Mhz

    );

//------SDRAM CLOCK GENNERATER  --
sdram_pll u6(
		               .areset( 0 ) ,
		               .inclk0( CLOCK_50 ),
		               .c1    ( DRAM_CLK ),       //100MHZ   -90 degree
		               .c0    ( SDRAM_CTRL_CLK )  //100MHZ     0 degree

	               );

// Picture taking logic
logic [22:0] WR1_ADDR = 0, WR1_MAX_ADDR = 0, RD1_ADDR = 0, RD1_MAX_ADDR = 0;
logic [22:0] counter;

always_ff @(posedge MIPI_PIXEL_CLK_) begin
	if (take_picture) begin
		WR1_ADDR     <= 2 * 640 * 480;
		WR1_MAX_ADDR <= 3 * 640 * 480;
	end
	else if (counter == 640 * 480) begin
		RD1_ADDR     <= 0 * 640 * 480;
		RD1_MAX_ADDR <= 1 * 640 * 480;
		WR1_ADDR     <= 0 * 640 * 480;
		WR1_MAX_ADDR <= 1 * 640 * 480;
	end

	if (reset) begin
		counter <= 0;
		WR1_ADDR     <= 0 * 640 * 480;
		WR1_MAX_ADDR <= 1 * 640 * 480;
		RD1_ADDR     <= 0 * 640 * 480;
		RD1_MAX_ADDR <= 1 * 640 * 480;
	end
	else begin
		if (counter == (640 * 480)) counter <= 0;
		else counter <= counter + 1;
	end
end

//------SDRAM CONTROLLER --
Sdram_Control	   u7	(	//	HOST Side
								 .RESET_N     ( reset ),
								 .CLK         ( SDRAM_CTRL_CLK ) ,
								 //	FIFO Write Side 1
								 .WR1_DATA    ( LUT_MIPI_PIXEL_D[9:0] ),
								 .WR1         ( LUT_MIPI_PIXEL_HS & LUT_MIPI_PIXEL_VS ) ,

								 .WR1_ADDR    ( WR1_ADDR ),
								 .WR1_MAX_ADDR(WR1_MAX_ADDR),
								 .WR1_LENGTH  ( 256 ) ,
								 .WR1_LOAD    ( !DLY_RST_0 ),
								 .WR1_CLK     ( MIPI_PIXEL_CLK_),

								 //	FIFO Read Side 1
								 .RD1_DATA    ( SDRAM_RD_DATA[9:0] ),
								 .RD1         ( READ_Request ),
								 .RD1_ADDR    ( RD1_ADDR ),
								 .RD1_MAX_ADDR( RD1_MAX_ADDR ),
								 .RD1_LENGTH  ( 256  ),
								 .RD1_LOAD    ( !DLY_RST_1 ),
								 .RD1_CLK     ( VGA_CLK ),

								 //	SDRAM Side
								 .SA          ( DRAM_ADDR ),
								 .BA          ( DRAM_BA ),
								 .CS_N        ( DRAM_CS_N ),
								 .CKE         ( DRAM_CKE ),
								 .RAS_N       ( DRAM_RAS_N ),
								 .CAS_N       ( DRAM_CAS_N ),
								 .WE_N        ( DRAM_WE_N ),
								 .DQ          ( DRAM_DQ ),
								 .DQM         ( DRAM_DQM  )
);

//------ CMOS CCD_DATA TO RGB_DATA --

RAW2RGB_J				u4	(
							.RST          ( VGA_VS ),
							.iDATA        ( SDRAM_RD_DATA[9:0] ),

							//-----------------------------------
                     .VGA_CLK      ( VGA_CLK ),
                     .READ_Request ( READ_Request ),
                     .VGA_VS       ( VGA_VS ),
							.VGA_HS       ( VGA_HS ),

							.oRed         ( RED  ),
							.oGreen       ( GREEN),
							.oBlue        ( BLUE )


							);
//------AOTO FOCUS ENABLE  --
AUTO_FOCUS_ON  vd(
                      .CLK_50      ( CLOCK2_50 ),
                      .I2C_RELEASE ( I2C_RELEASE ),
                      .AUTO_FOC    ( AUTO_FOC )
               ) ;


//------AOTO FOCUS ADJ  --
FOCUS_ADJ adl(
                      .CLK_50        ( CLOCK2_50 ) ,
                      .RESET_N       ( I2C_RELEASE ),
                      .RESET_SUB_N   ( I2C_RELEASE ),
                      .AUTO_FOC      ( AUTO_FOC ), // Auto focus on by default now
                      .SW_Y          ( 0 ),
                      .SW_H_FREQ     ( 0 ),
                      .SW_FUC_LINE   ( 0 ), // SW[9], off by default
                      .SW_FUC_ALL_CEN( 0 ), // SW[9], off by default
                      .VIDEO_HS      ( VGA_HS ),
                      .VIDEO_VS      ( VGA_VS ),
                      .VIDEO_CLK     ( VGA_CLK ),
		                .VIDEO_DE      (READ_Request) ,
                      .iR            ( RED ),
                      .iG            ( GREEN ),
                      .iB            ( BLUE ),
                      .oR            ( out_r ) ,
                      .oG            ( out_g ) ,
                      .oB            ( out_b ) ,

                      .READY         ( READY ),
                      .SCL           ( CAMERA_I2C_SCL_AF ),
                      .SDA           ( CAMERA_I2C_SDA )
);

//--LED DISPLAY--
CLOCKMEM  ck1 ( .CLK(VGA_CLK )   ,.CLK_FREQ  (25000000  ) , . CK_1HZ (D8M_CK_HZ   )  )        ;//25MHZ
CLOCKMEM  ck2 ( .CLK(MIPI_REFCLK   )   ,.CLK_FREQ  (20000000   ) , . CK_1HZ (D8M_CK_HZ2  )  ) ;//20MHZ
CLOCKMEM  ck3 ( .CLK(MIPI_PIXEL_CLK_)   ,.CLK_FREQ  (25000000  ) , . CK_1HZ (D8M_CK_HZ3  )  )  ;//25MHZ
endmodule
