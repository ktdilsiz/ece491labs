`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2016 01:19:50 AM
// Design Name: 
// Module Name: topmodulefinal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module topmodulefinal(
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [15:0]  SW,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
		  input logic 	      BTNL, 
		  input logic 	      BTNR,
		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
//		  output logic [7:0]  LED,
          // output logic [7:0]  data_m_receiver,
          // output logic [7:0]  data_mx_out,
           output logic        txd_mtrans_out,
//        output logic        data_m_trans,
		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
//		  output logic        UART_RXD_OUT,
//		  output logic        UART_RXD_OUT_copy,
		  output logic        JAtxd,
		  output logic        JAtxen,
		  output logic        JAcardet,
		  output logic        JAwrite,
          output logic        JAerror,
          input logic        inJA1,
          output logic        outJA2, outJA3, outJA4
//		  output logic        UART_CTS		  
            );

      //assign txd_mtrans_out = 1'b0;
      assign outJA2 = txd_mtrans_out;
      assign outJA4 = txen_m_trans_out ? 0 : 1 ;
      assign outJA3 = 1'b1;
      assign JAtxen = inJA1;
      //assign JAtxd = 1'b1;

      assign JAtxd = txd_mtrans_out;
      assign JAcardet = UART_TXD_IN;

      logic [7:0] dest_addr;
      logic [7:0] source_addr;
      logic [1:0] type_data;

      assign dest_addr = SW[7:0];
      assign source_addr = SW[7:0];

      logic [7:0] data_m_receiver;


      trans_controller_2 #(.BAUD(50000), .OUTPUTBAUD(9600))
      TRANS_CONTROLLER(
        .rxd_a_rcvr_in(UART_TXD_IN),
        .clk(CLK100MHZ),
        .rst(BTNC),
        .txd_m_trans_out(txd_mtrans_out),
        .txen_m_trans_out(txen_m_trans_out)
        );

        // rcvr_controller #(.BAUD(50000), .OUTPUTBAUD(9600))
        // RCVR_CONTROLLER(
        // 	.clk(CLK100MHZ),
        // 	.receive_switch(SW[15]),
        // 	.rst(BTNC),
        //   .mac_addr(source_addr),
        // 	.rxd_rcvr_out(UART_RXD_OUT),
        //   .data_m_receiver(data_m_receiver),
        // 	.JAcardet(JAcardet),
        // 	.JAwrite(JAwrite),
        // 	.JAerror(JAerror),
        // 	.inJA1(inJA1),
        // 	.outJA3(outJA3)
        // 	);

        // dispctl DISPCTL (
        //     .clk(CLK100MHZ), 
        //     .reset(BTNC), 
        //     .d7(data_m_receiver[0]), 
        //     .d6(data_m_receiver[1]), 
        //     .d5(data_m_receiver[2]), 
        //     .d4(data_m_receiver[3]), 
        //     .d3(data_m_receiver[4]), 
        //     .d2(data_m_receiver[5]), 
        //     .d1(data_m_receiver[6]), 
        //     .d0(data_m_receiver[7]),
            
        //     .dp7(1'b0), 
        //     .dp6(1'b0), 
        //     .dp5(1'b0), 
        //     .dp4(1'b0), 
        //     .dp3(1'b0),
        //     .dp2(1'b0), 
        //     .dp1(1'b0), 
        //     .dp0(1'b0),
        //     .seg(SEGS),
        //     .dp(DP),
        //     .an(AN)
        // );

        endmodule // topmodulefinal