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
   
   typedef enum logic [1:0] {
       FIRSTHALF = 2'b00,
       SECONDHALF = 2'b01    
   } state_enable;
   
   state_enable dataState, nextDataState;
   
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
   
   always_comb
   begin 
   case(dataState)
       FIRSTHALF:
           begin
               tempdata = ~data;
               nextDataState = SECONDHALF;
           end
       SECONDHALF:
           begin
               tempdata = data;
               nextDataState = FIRSTHALF;
           end
       default:
           begin
           tempdata = 1;
           nextDataState = FIRSTHALF;
           end
       endcase
   end
   
    //decoder instantiated    

   logic enb, csum, h_out, l_out;
   logic [7:0] d_in;
   
   //instantiate the correlator module
//   //correlator module for preamble
//   correlator #(parameter LEN=16, PATTERN=16'b1010101010101010, HTHRESH=13, LTHRESH=3, W=$clog2(LEN)+1) 
//   UPREAMBLE(.clk(clk), .reset(rst), .enb(enb), .d_in(d_in), .csum(csum), .h_out(h_out), .l_out(l_out));
   
//   //correlator module for sfd
//  correlator #(parameter LEN=8, PATTERN=8'b00001011, HTHRESH=7, LTHRESH=1, W=$clog2(LEN)+1) 
//  USFD(.clk(clk), .reset(rst), .enb(enb), .d_in(d_in), .csum(csum), .h_out(h_out), .l_out(l_out));
   
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
