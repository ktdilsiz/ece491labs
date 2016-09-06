//-----------------------------------------------------------------------------
// Title         : Nexys4 Simple Top-Level File
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : nexys4DDR.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
// Created       : 22.07.2016
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description :
// This file provides a starting point for Lab 1 and includes some basic I/O
// ports.  To use, un-comment the port declarations and the corresponding
// configuration statements in the constraints file "Nexys4DDR.xdc".
// This module only declares some basic i/o ports; additional ports
// can be added - see the board documentation and constraints file
// more information
//
// Modification comments with the code
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
// 09.06.2016 : modified (Kemal Dilsiz)
//-----------------------------------------------------------------------------

module nexys4DDR (
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [15:0]  SW,
		  input logic 	      BTNC,
//		  input logic 	      BTNU, 
//		  input logic 	      BTNL, 
//		  input logic 	      BTNR,
//		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP
//		  output logic [15:0] LED,
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
//		  output logic        UART_RXD_OUT,
//		  output logic        UART_CTS		  
            );
            
            
    // wires created to connect the modules, reg_parms to the main dispctl module
    logic [4:0] k_0,k_1,k_2,k_3,k_4,k_5,k_6,k_7;
          
    //Input d comes from switches 15 to 11 (parameter W is set to 5 for 5 bit input)
    reg_parm #(.W(5)) REGPARM_1(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[7]), .d(SW[15:11]), .k(k_0));
    reg_parm #(.W(5)) REGPARM_2(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[6]), .d(SW[15:11]), .k(k_1));
    reg_parm #(.W(5)) REGPARM_3(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[5]), .d(SW[15:11]), .k(k_2));
    reg_parm #(.W(5)) REGPARM_4(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[4]), .d(SW[15:11]), .k(k_3));
    reg_parm #(.W(5)) REGPARM_5(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[3]), .d(SW[15:11]), .k(k_4));
    reg_parm #(.W(5)) REGPARM_6(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[2]), .d(SW[15:11]), .k(k_5));
    reg_parm #(.W(5)) REGPARM_7(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[1]), .d(SW[15:11]), .k(k_6));
    reg_parm #(.W(5)) REGPARM_8(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[0]), .d(SW[15:11]), .k(k_7));

    //all the inputs are put to their respective positions
    dispctl DISPCTL (.clk(CLK100MHZ), .reset(BTNC), 
                            .d7(k_7[4:1]), 
                            .d6(k_6[4:1]), 
                            .d5(k_5[4:1]), 
                            .d4(k_4[4:1]), 
                            .d3(k_3[4:1]), 
                            .d2(k_2[4:1]), 
                            .d1(k_1[4:1]), 
                            .d0(k_0[4:1]),
                            
                            .dp7(k_7[0]), 
                            .dp6(k_6[0]), 
                            .dp5(k_5[0]), 
                            .dp4(k_4[0]), 
                            .dp3(k_3[0]),
                            .dp2(k_2[0]), 
                            .dp1(k_1[0]), 
                            .dp0(k_0[0]),
                            .seg(SEGS),
                            .dp(DP),
                            .an(AN)
             );

endmodule // nexys4DDR
