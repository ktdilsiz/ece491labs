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
       
       // instantiate device under verification (counter)
       transmitter TRANS(.data(data), .send(send), .clk(clk), .rst(rst), .txd(txd), .rdy(rdy));
    
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
          #5
          rst = 1;
          #5
          rst = 0;
          #5
          if(rdy) send = 1;
          #20 send = 0;
          #100
          if(rdy) send = 1;
          data = 8'b10101010;
          #10 send = 0;
          #120

          $stop();  // all done - suspend simulation
       end // initial
       
endmodule 

