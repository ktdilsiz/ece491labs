`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2016 08:26:15 PM
// Design Name: 
// Module Name: mx_rcvr
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
module mx_rcvr(
    input logic rxd, clk, rst,
    output logic [7:0] data,
    output logic cardet, write, error
   );
   
   parameter BAUD = 9600;
   parameter TWICEBAUD = BAUD * 2;
   parameter SIXTEENBAUD = BAUD * 16;
   parameter BIT_RATE = 50_000;
   
   logic BaudRate, TwiceBaudrate, SixteenBaudRate;
   logic [7:0] tempdata;
       
   //logic clkEnb;
  // logic [7:0] k;

   clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
   clkenb #(.DIVFREQ(TWICEBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(TwiceBaudRate));
   clkenb #(.DIVFREQ(SIXTEENBAUD)) CLKENB3(.clk(clk), .reset(rst), .enb(SixteenBaudRate));
   
   typedef enum logic [3:0] {
       IDLE =       4'b0000, 
       PREAMBLE =   4'b1010, 
       SFD =        4'b0001, 
       RECEIVE =    4'b0010, 
       EOF =        4'b0011
//       TR3 = 4'b0100, 
//       TR4 = 4'b0101, 
//       TR5 = 4'b0110, 
//       TR6 = 4'b0111, 
//       TR7 = 4'b1000, 
//       STOP = 4'b1001,
//       WAIT = 4'b1111,
//       EOF1 = 4'b1101,
//       EOF2 = 4'b1100
   } state_t;

   state_t state, next;
   
//   typedef enum logic [1:0] {
//       FIRSTHALF = 2'b00,
//       SECONDHALF = 2'b01    
//   } state_enable;
   
//   state_enable dataState, nextDataState;
   
  always_ff@(posedge clk)
  begin
   if(rst) 
       begin
           state <= IDLE;
       end
   else if(BaudRate)
       begin
           state <= next;
           dataState <= nextDataState;
       end 
   else if(SixteenBaudRate)
       begin
           dataState <= nextDataState;
       end
   else
       begin
           state <= state;
       end
       
   end
   
    //decoder instantiated    

   logic enb, csum, h_out, l_out;
   logic [7:0] d_in;
   
   //instantiate the correlator module
   correlator #(.LEN(8), .PATTERN(8'b10101010), .HTHRESH(6), .LTHRESH(2)) 
       COR_PREAM( 
       .clk(clk), 
       .reset(rst), 
       .enb(enb), 
       .d_in(d_in), 
       .csum(csum), 
       .h_out(h_out), 
       .l_out(l_out));
       
   logic enb_sfd, csum_sfd, h_out_sfd, l_out_sfd;
   logic [7:0] d_in_sfd;
   
   //correlator module for sfd
   correlator #(.LEN(8), .PATTERN(8'b00001011), .HTHRESH(6), .LTHRESH(2))
    COR_SFD( 
    .clk(clk), 
    .reset(rst_sfd), 
    .enb(enb_sfd), 
    .d_in(d_in_sfd), 
    .csum(csum_sfd), 
    .h_out(h_out_sfd), 
    .l_out(l_out_sfd));
    
    logic enb_bit, csum_bit, h_out_bit, l_out_bit;
    logic [7:0] d_in_bit;

 //correlator module for bit
 correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(6), .LTHRESH(2)) 
    COR_BIT( 
    .clk(clk), 
    .reset(rst_bit), 
    .enb(enb_bit), 
    .d_in(d_in_bit), 
    .csum(csum_bit), 
    .h_out(h_out_bit), 
    .l_out(l_out_bit));
   
    logic enb_baud, csum_baud, h_out_baud, l_out_baud;
    logic [7:0] d_in_baud;
   
  //correlator module for baudrate mismatch
 correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(6), .LTHRESH(2)) 
    COR_MIS_BAUD( 
    .clk(clk), 
    .reset(rst_baud), 
    .enb(enb_baud), 
    .d_in(d_in_baud), 
    .csum(csum_baud), 
    .h_out(h_out_baud), 
    .l_out(l_out_baud));
   
   
   always_comb
   begin    
   case(state)
       IDLE:
           begin
           cardet = 0;
           write = 0;
           error = error;
           data = xx;
           end
  
//       PREAMBLE:
       
       
//       SFD:
       
       
//       RECEIVE:
       
//       EOF:
           
      
             
       default: 
           begin
               next = IDLE;
               cardet = 1;
               write = 1;
               error = 0;
           end     
       endcase
     end

    );
endmodule
