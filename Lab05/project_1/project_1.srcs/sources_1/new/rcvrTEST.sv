`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College
// Engineer: Zainab Hussein
// 
// Create Date: 10/25/2016 01:28:03 PM
// Design Name: Receiver testbench
// Module Name: rcvrTEST
// Project Name: Manchester Receiver
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision: 10/25/2015
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module rcvrTEST();

    logic rxd, clk, rst;
    logic [7:0] data;
    logic cardet, write, error;
 
     mx_rcvr #(.BAUD(2_500_000_0 / 16)) URVR(.clk(clk), .rst(rst), .rxd(rxd), .cardet(cardet), .data(data), .write(write), .error(error));
    
    logic BaudRate;
      clkenb #(.DIVFREQ(2_500_000_0 / 8)) CLKENB3(.clk(clk), .reset(rst), .enb(BaudRate));
    
    import check_p1::*;
  
    // clock generator
    always
    begin
     clk = 1;
     #5 clk = 0;
     #5 ;
    end
    
  //check rst 
   task check_rst;
    rst = 1; rxd = 0;
    @(posedge clk) #1;
    check("cardet reset", cardet, 1'h0);                      //cardet
    check("error reset", error, 1'h0);                        //error
    check("write reset", write, 1'h0);                        //write
    check("data reset", data, 8'h0);                         //data
    
    repeat (3) @(posedge clk) #1;
    check("cardet still reset", cardet, 1'h0);
    check("data still reset", data, 8'h0);
    check("write still reset", write, 1'h0);
    rst = 0;
    check("cardet not reset", cardet, 1'h0);                      //cardet
    check("error not reset", error, 1'h0);                        //error
    check("write not reset", write, 1'h0);                        //write
    check("data not reset", data, 8'h0);                         //data
   endtask
   
   //check input low error
  task check_erroreous_input;
     rst = 0; 
       
     check("cardet before error", cardet, 1'h0);
     check("data before error", data, 8'hxx);
     check("write before error", write, 1'h0);
     
     repeat (2) 
       begin 
           @(posedge clk) rxd = 1; #10 rxd = ~rxd;
           @(posedge clk) rxd = 0; #10 rxd = ~rxd;
       end
     
     repeat(2) @(posedge clk) rxd = 0;
     repeat(2) @(posedge clk) rxd = 1;
     
     check("cardet after error", cardet, 1'h0);
     check("data after error", data, 8'hxx);
     check("write after error", write, 1'h0);
     check("error after erroreous input", error, 1'h1);

  endtask
  
  //check premature error
  task check_premature_error;
  
    check("cardet after error", cardet, 1'h0);
    check("data after error", data, 8'hxx);
    check("write after error", write, 1'h0);
  
    check_sfd;
    
    @(posedge clk) rxd = 1; #10 rxd = ~rxd;
    @(posedge clk) rxd = 0; #10 rxd = ~rxd;
    @(posedge clk) rxd = 1; #10 rxd = ~rxd;
    @(posedge clk) rxd = 1; #10 rxd = ~rxd;
    @(posedge clk) rxd = 1; #10 rxd = ~rxd;
    @(posedge clk) rxd = 0; #10 rxd = ~rxd;

    check("cardet after error", cardet, 1'h0);
    check("data after error", data, 8'hxx);
    check("write after error", write, 1'h0);
    check("error after premature error", error, 1'h1);

  endtask
   
  //check preamble pattern
  task check_preamble;
    rst = 0; 
    
    check("cardet before preamble", cardet, 1'h0);
    check("data before preamble", data, 8'hxx);
    check("write before preamble", write, 1'h0);

  repeat (4) 
    begin 
        @(posedge BaudRate) rxd = 1; 
        @(posedge BaudRate) rxd = ~rxd;
        @(posedge BaudRate) rxd = 0; 
        @(posedge BaudRate) rxd = ~rxd;
    end
  
    check("cardet middle of preamble of 16 bits", cardet, 1'h1);
    check("data middle of preamble of 16 bits", data, 8'hxx);
    check("write middle of preamble of 16 bits", write, 1'h0);
  
  repeat (4) 
    begin 
        @(posedge BaudRate) rxd = 1; 
        @(posedge BaudRate) rxd = ~rxd;
        @(posedge BaudRate) rxd = 0; 
        @(posedge BaudRate) rxd = ~rxd;
    end

//  check("cardet after preamble of 16 bits", cardet, 1'h1);
//  check("data after preamble of 16 bits", data, 8'hxx);
//  check("write after preamble of 16 bits", write, 1'h0);
  
  endtask
  
  //check sfd pattern
  task check_sfd;
  
    check_preamble;
  
    rst = 0; 
    
    check("cardet before sfd", cardet, 1'h1);
    check("data before sfd", data, 8'hxx);
    check("write before sfd", write, 1'h0);
  
  repeat (4) 
    begin
        @(posedge BaudRate) rxd = 0; 
        @(posedge BaudRate) rxd = ~rxd;
    end

      @(posedge BaudRate) rxd = 1; 
      @(posedge BaudRate) rxd = 0; 

      @(posedge BaudRate) rxd = 0; 
      @(posedge BaudRate) rxd = 1; 

      @(posedge BaudRate) rxd = 1; 
      @(posedge BaudRate) rxd = 0; 

      @(posedge BaudRate) rxd = 1; 
      @(posedge BaudRate) rxd = 0; 

  
  check("cardet after sfd", cardet, 1'h1);
  check("data after sfd", data, 8'hxx);
  check("write after sfd", write, 1'h0);
  
  endtask
  
  //check data byte received
  task check_receive;
    
    check_sfd;
    
    check("cardet before receive", cardet, 1'h1);
    check("data before receive", data, 8'hxx);
    check("write before receive", write, 1'h0);
    
    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    check("write after receive", write, 1'h0);
    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;
    
    check("cardet after receive", cardet, 1'h1);
    check("data after receive", data, 8'b10111011);
    check("write after receive", write, 1'h1);
    
    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;
    check("write after receive", write, 1'h0);
    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;
  
    check("cardet after receive", cardet, 1'h1);
    check("data after receive", data, 8'b11111111);
    check("write after receive", write, 1'h1);
    
    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;
    check("write after receive", write, 1'h0);
    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;
    
    check("cardet after receive", cardet, 1'h1);
    check("data after receive", data, 8'b00000000);
    check("write after receive", write, 1'h1);
  
    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;
    check("write after receive", write, 1'h0);
    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 1; 
    @(posedge BaudRate) rxd = ~rxd;

    @(posedge BaudRate) rxd = 0; 
    @(posedge BaudRate) rxd = ~rxd;

    
    check("cardet after receive", cardet, 1'h1);
    check("data after receive", data, 8'b10101010);
    check("write after receive", write, 1'h1);
  
  endtask
  
  //check EOF
  task check_EOF;
  
    check("cardet before EOF", cardet, 1'h1);
    check("data before EOF", data, 8'bxx);
    check("write before EOF", write, 1'h1);
    
    rst = 0;
    repeat (2) @(posedge clk) rxd = 1;
    
    check("cardet after EOF", cardet, 1'h1);
    check("data after EOF", data, 8'bxx);
    check("write after EOF", write, 1'h1);
  
  endtask

  logic noise_error;

    always @(posedge clk) begin
        #1; // inject error (if any) after clock edge
        if ($urandom_range(100,1) <= 50) noise_error = 1;
        else noise_error = 0;

        //$display ("Error Value is %0d", noise_error);
    end
  
    initial begin

    rst = 1;
    #10;
    rxd = 0;
    rst = 0;

    #100;

    //check_rst;
    //check_preamble;
    //check_sfd;
    
    check_receive;

//    check_EOF;
//    check_erroreous_input;
//    check_premature_error;
//    check_summary_stop;

    #50;
    end
  
endmodule
