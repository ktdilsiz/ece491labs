`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2016 03:49:20 PM
// Design Name: 
// Module Name: TransmitterTest
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


module TransmitterTest();
    
      // signals for connecting the counter      
       
       logic [7:0] data;
       logic send;
       logic clk, rst;
       logic txd;
       logic rdy;
       logic switch;
       
       // instantiate device under verification (counter)        
       nexys4DDR #(.BAUD(25_000_000)) NEXYS(.CLK100MHZ(clk), .SW(data), .BTNC(rst), .BTND(send), .BTNL(switch), .LED(rdy), .UART_RXD_OUT(txd));
      // clock generator with period=20 time units
      always
         begin
        clk = 0;
        #5 clk = 1;
        #5 ;
         end
    
    
       // initial block generates stimulus
       initial begin
          data = 8'b10101110;
          send = 0;
          rst = 0;
          switch = 0;
          #5
          rst = 1;
          #5
          rst = 0;
          #15
          //regular
          if(rdy) send = 1;
          #420
          //SEND ON STOP BIT
          if(rdy) send = 1;
          data = 8'b00101010;
          #50 send = 0;
          #400
          //regular
          if(rdy) send = 1;
          data = 8'b10101110;
          #50 send = 0;
          #400
          
          $stop();  // all done - suspend simulation
       end // initial
       
endmodule 

