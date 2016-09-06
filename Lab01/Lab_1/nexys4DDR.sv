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
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
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
            
          logic [4:0] k0,k1,k2,k3,k4,k5,k6,k7;
          
// add SystemVerilog code & module instantiations here

//getting rule violation: multiple driver nets issue, thinking it could be order of module error, rather than syntax

            reg_parm #(.W(5)) PARM_1(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[7]), .d(SW[15:11]), .k(k0));
            reg_parm #(.W(5)) PARM_2(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[6]), .d(SW[15:11]), .k(k1));
            reg_parm #(.W(5)) PARM_3(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[5]), .d(SW[15:11]), .k(k2));
            reg_parm #(.W(5)) PARM_4(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[4]), .d(SW[15:11]), .k(k3));
            reg_parm #(.W(5)) PARM_5(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[3]), .d(SW[15:11]), .k(k4));
            reg_parm #(.W(5)) PARM_6(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[2]), .d(SW[15:11]), .k(k5));
            reg_parm #(.W(5)) PARM_7(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[1]), .d(SW[15:11]), .k(k6));
            reg_parm #(.W(5)) PARM_8(.clk(CLK100MHZ), .reset(BTNC), .lden(SW[0]), .d(SW[15:11]), .k(k7));
              
            
        
            dispctl DISP (.clk(CLK100MHZ), .reset(BTNC), .d7(k7[4:1]), .d6(k6[4:1]), .d5(k5[4:1]), 
                            .d4(k4[4:1]), .d3(k3[4:1]), .d2(k2[4:1]), .d1(k1[4:1]), .d0(k0[4:1]),
                            .dp7(k7[0]), .dp6(k6[0]), .dp5(k5[0]), .dp4(k4[0]), .dp3(k3[0]),
                            .dp2(k2[0]), .dp1(k1[0]), .dp0(k0[0]),
                            .seg(SEGS),
                            .dp(DP),
                            .an(AN)
             
             );




endmodule // nexys4DDR
