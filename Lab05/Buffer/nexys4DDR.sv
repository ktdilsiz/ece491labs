`timescale 1ns / 1ps
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

module nexys4DDR2 (
		  // un-comment the ports that you will use
          input logic        CLK100MHZ,
		  input logic [7:0]  SW,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
		  input logic 	      BTNL, 
		  input logic 	      BTNR,
		  input logic 	      BTND,
//		  output logic [6:0]  SEGS,
//		  output logic [7:0]  AN,
//		  output logic 	      DP,
		  output logic  [3:0] LED,
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
		  output logic        UART_RXD_OUT,
		  output UART_RXD_OUT_copy,
		  output logic        JArdy 
//		  output logic        UART_CTS		  
            );
            
        assign UART_RXD_OUT_copy = UART_RXD_OUT;
            
        parameter BAUD = 9600;
//        parameter LENGTH = 8;
//        parameter W =  8;
//        parameter R = 8;
        parameter numBits = 4;
        parameter DIVBITS = $clog2(numBits);
        logic [7:0] data;
        
        // add SystemVerilog code & module instantiations here
            
            p_fifo FIFO(  
            .clk(CLK100MHZ), 
            .rst(BTNC), 
            .clr(BTNL), 
            .we(BTNU), 
            .re(BTNR),
            .din(SW),
            .full(LED[3]),
            .empty(LED[2]),
            .dout(data)
            );
            
        //debounce DEBOUNDER(.clk(CLK100MHZ), .button_in(BTND), .button_out(send), .pulse());
        transmitter #(.BAUD(BAUD)) TRANS(
            .data(data), 
            .send(BTND), 
            .clk(CLK100MHZ), 
            .rst(BTNC), 
            .switch(0), 
            .txd(UART_RXD_OUT), 
            .rdy(LED[1])
            ); //set switch to null so I can use BTNL for something else
        

        assign JArdy = LED[1];
      

endmodule // nexys4DDR