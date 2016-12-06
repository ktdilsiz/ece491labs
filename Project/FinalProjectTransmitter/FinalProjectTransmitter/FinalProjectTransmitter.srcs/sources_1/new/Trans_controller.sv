// Code your design here
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2016 08:48:13 PM
// Design Name: 
// Module Name: Trans_controller
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


module Trans_controller(
    input logic clk, 
    input logic rst,
    input logic [7:0] xdata,
    input logic [9:0] SW,
    input logic xwr,
    input logic xsnd,
    input logic cardet,
    output logic xrdy,
    output logic xerrcnt,
    output logic txen,
    output logic txd
    
    );
    
    parameter BAUD = 50000;
    parameter OUTPUTBAUD = 9600;
    
    logic clk_in, clk_out, error;
    logic [7:0] data_in; 
     //mtrans fed by BRAM       
     m_transmitter #(.BAUD(BAUD)) TRAN(
    .data(xdata), //55,55,d0
    .send(xsnd),
    .clk(clk), 
    .rst(rst), 
    .switch(0), //assuming not used
    .cardet(cardet), //connection to mx_rcvr
    .txd(txd),
    .rdy(xrdy), 
    .txen(txen),
    .error(error) //add this output to mx_tran
        );
        
    logic error_arcvr, rdy_arcvr, rxd;
    logic [7:0] data_arcvr;
    //async rcvr feeds BRAM           
    receiver #(.BAUD(OUTPUTBAUD)) RCVR (
    .rxd(rxd),
    .clk(clk), 
    .rst(rst),
    .ferr(error_arcvr),
    .rdy(rdy_arcvr),
    .data(data_arcvr)
    );
                   
    parameter numBits = 64;
    logic read_en_fifo_test, full_fifo_out, empty_fifo_out; 
   //fifo as BRAM                
    p_fifo4 #(.numBits(numBits)) FIFO(  
    .clk(clk), 
    .rst(~rst),        //needs that ~ cause rst is asserted low
    .clr(rst), 
    .we(xwr && rdy_arcvr),
    .re(xrdy && BaudRateOutput),
    .din(data_arcvr),
    .full(full_fifo_out),
    .empty(empty_fifo_out),
    .dout(xdata)
    );
      
//    tran_bram_controller T_BRAM(
//    .write(xwr),
//    .read(rrd),
//    .clk_system(clk),
//    .clk_in(clk_in),
//    .clk_out(clk_out),
//    .rst(rst),
//    .data_in(data_in)
//    );
    
    //error counter
    always_ff@(posedge clk)
      begin
          if(rst)
              xerrcnt <= 1'b0;
          else if(error)
              xerrcnt <= xerrcnt + 1'b1;
          else
              xerrcnt <= xerrcnt;
      end 
    
    clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(clk_in));
    clkenb #(.DIVFREQ(OUTPUTBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(clk_out));
    clkenb #(.DIVFREQ(BAUD)) CLKENBEIGHT(.clk(clk), .reset(rst), .enb(BaudRate));
    
    logic [7:0] data_counter;
    //data counter
    always_ff @(posedge clk_in) begin
       if(rst) begin
           data_counter <= 0;
       end else if(xwr) begin
           data_counter <= data_counter + 1;
       end
    end
 
   logic [7:0] preamble, sfd;
    
    assign preamble = 8'h55;
    assign sfd = 8'h04;

 typedef enum logic [1:0] {
        RANDOM = 2'b00,
        PREAMBLE1 = 2'b01,
        PREAMBLE2 = 2'b10,  
        SFD = 2'b11  
    } state_sync;
    
    state_sync state, next;
    logic [7:0] sync_data;
    always_comb
       begin 
        sync_data = 8'h0; //goes into transmitter before the BRAM data
       case(state)
           RANDOM:
               begin
               next = RANDOM;
               if(~xwr && ~cardet) //want before data count starts
                begin
                   sync_data = preamble;
			cardet = 0;
                   next = PREAMBLE1;
                end  
               end
           PREAMBLE1:
               begin
                    next = PREAMBLE1;
                    if(~xwr && ~cardet)
                        begin
                        sync_data = preamble;
			cardet = 0;
                        next = PREAMBLE2;
                        end
               end
           PREAMBLE2:
               begin
                    next = PREAMBLE2;
                    if(~xwr && cardet)
                        begin
                        sync_data = sfd;
			cardet = 1;
                        next = SFD;
                        end
               end
    
            SFD:
             begin
                   next = SFD;
                   if(~xwr && cardet)
                    begin
                    sync_data = sfd;
			cardet = 1;
                    next = RANDOM;
                    end
             end
           default:
               begin
                    next = RANDOM;
                    sync_data = 8'h0;
			cardet = 0;
               end
           endcase
       end
     
       //transmit dest-source-type
       typedef enum logic [1:0] {
              IDLE = 2'b00,
              DEST = 2'b01,
              SOURCE = 2'b10,
              TYPE = 2'b11
          } state_iden;
          
          state_iden state, next_iden;

      logic button; //want to connect this to external button/switch   
      logic [7:0] bram_data, dest_addr, source_addr, type_data; 
      assign type_data = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,SW[9], SW[8]};
      
  always_comb
         begin 
          bram_data = 8'h0; //goes into transmitter before the BRAM data
         case(state)
             IDLE:
                 begin
                 next_iden = IDLE;
                 if(xwr) //want before data count starts
                  begin
                     bram_data = 8'h0;
                     next_iden = DEST;
                  end  
                 end
             DEST:
                 begin
                      next_iden = DEST; 
                      if(xwr)          //need switch to allow user input
                          begin
                          bram_data = dest_addr;
                          next_iden = SOURCE;
                          end
                 end
             SOURCE:
                 begin
                      next_iden = SOURCE;
                      if(xwr)
                          begin
                          bram_data = source_addr;
                          next_iden = TYPE;
                          end
                 end
      
              TYPE:
               begin
                     next_iden = TYPE;
                     if(xwr)
                      begin
                      bram_data = type_data;
                      next_iden = IDLE;
                      end
               end
             default:
                 begin
                      next_iden = IDLE;
                      bram_data = 8'h0;
                 end
             endcase
         end
       assign dest_addr = SW[7:0];
       assign source_addr = 8'h40;
  assign type_addr = SW[9:8];
       
       //BACKOFF CONFIGURATION 
  	//counter for number of transmission trial attempts 
  	//	logic trial, trial_rst;
  //always_ff@(posedge clk)
   // begin
     // if(rst) trial = 3'b000;
    //  else if(trial_rst) trial = trial + trial;
    //  else trial = trial;
   // end
  
  		//counter for random number for the wait time before each trial
  		//logic ran_wait, 
  		//logic ran_wait_rst = 7;
 // always_ff@(posedge clk)
   // begin
     // if(rst) ran_wait = 4'b0000;
     // else if(ran_wait_rst) ran_wait = 
 //   end

       //clabacchio sequence with statistical properties similar to random numbers
	 //random number generator for wait times (synthesizable) 
	//FIGURE OUT WHAT SIGNALS COLLISION TO TRIGGER BACKOFF (cardet seems probable)
        logic [4:0] ran_wait;
  always @(posedge clk) 
    begin
      ran_wait <= { ran_wait[3:0], ran_wait[4] ^ ran_wait[3] };
  end
        
        //while loop limiting # of trials to 5  
  int trial;
  initial begin 
    do
      begin
        trial++;
      end
    while(trial < 5);
  end       
        
    	
endmodule
