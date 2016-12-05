// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2016 03:14:11 PM
// Design Name: 
// Module Name: Trans_contoller_bench
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


module Trans_contoller_bench();
    import check_p1::*;
    // signals connecting to transmitter controller
    
    logic clk,
    logic rst,
    logic[7:0]  xdata,
  	logic [9:0] SW,
    logic xwr,
    logic xsnd,
    logic cardet,
    logic xerrcnt,
    logic txen,
    logic txd,
    logic xrdy
    
    // instantiate device under verification (transmitter controller)
    Trans_controller #(.BAUD(800_000/ 16) TRANS(.clk, .rst, .xdata, .SW, .xwr, .xsnd, .cardet, .xrdy, 						.xerrcnt, .txen, .txd );

    logic BaudRate;
    clkenb #(.DIVFREQ(800_000 / 8)) CLKENB3(.clk(clk), .reset(rst), .enb(BaudRate));
    
    // clock generator
    always
    begin
     clk = 1;
     #5 clk = 0;
     #5 ;
    end

     //check data transmission
     task check_data_transmission;
      xdata = 8'b10101110;
      xsnd = 0;
      rst = 1; 
      SW = 10'b0011100001; //{type,dest_addr}
      xwr = 0;
      cardet = 0;
      @(posedge clk) #1;
       check("xrdy reset", 0);
       check("xerrcnt reset", 0);
       check("txen reset", 0);
       check("txd reset", 1);
       
       repeat (3) @(posedge clk) #1;
       rst = 0; 
       xdata = 8'b10101010;
       check("xrdy reset", 0);
       check("xerrcnt reset", 0);
       check("txen reset", 0);
       check("txd reset", 1);
       
       @(posedge clk) #1;
       xsnd = 1;
       xdata = 8'00001011;
       xwr = 0;
       cardet = 1;
       check("mtrans rdy", 1);
       check("xerrcnt nil", 0);
       check("txen nil", 0);
       check("txd nil", 1);
       
       repeat (3) @(posedge clk) #1;
       xwr = 1;
       xdata = 8'b00011100;
       check("mtrans rdy", 1);
       check("xerrcnt nil", 0);
       check("txen enabled", 1);
       check("txd gets xdata", 0);
       
       @(posedge clk) #1;
       check("txd gets xdata", 0);
       
       @(posedge clk) #1;
       check("txd gets xdata", 1);
       
       @(posedge clk) #1;
       check("txd gets xdata", 1);
       
       @(posedge clk) #1;
       check("txd gets xdata", 1);
       
       @(posedge clk) #1;
       check("txd gets xdata", 0);
       
       @(posedge clk) #1;
       check("txd gets xdata", 0);
       
       @(posedge clk) #1;
       check("txd gets xdata", 0);
       
       @(posedge clk) #1;
       cardet = 0;
       xwr = 0;
       xsnd = 0; 
       check("txd still xdata", 0); 
       check("mtrans not rdy", 0);
       check("xerrcnt nil", 0);
       check("txen enabled", 0);
       
     endtask  
     
     initial begin
       rst = 0;
       xdata = 8'b00000000;
       xsnd = 0;
       SW = 10'b0000000000;
       xwr = 0;
       cardet = 0;
       check_data_transmission;
       check_summary_stop;
     end
                       
                       
    
endmodule
