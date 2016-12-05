`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2016 12:27:41 AM
// Design Name: 
// Module Name: tran_controller_fifo
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


module tran_controller_fifo(
 // un-comment the ports that you will use
         input logic         CLK100MHZ,
         input logic [15:0]  SW,
         input logic           BTNC,
         input logic           BTNU, 
         input logic           BTNL, 
         input logic           BTNR,
         input logic           BTND,
         output logic [6:0]  SEGS,
         output logic [7:0]  AN,
         output logic           DP,
//          output logic [7:0]  LED,
         output logic [7:0]  data_m_receiver,
         output logic [7:0]  data_mx_out,
         output logic        txd_mtrans_out,
//        output logic        data_m_trans,
//          input logic         UART_TXD_IN,
//          input logic         UART_RTS,          
         output logic        UART_RXD_OUT,
//          output logic        UART_RXD_OUT_copy,
         output logic        JAtxd,
         output logic        JAtxen,
         output logic        JAcardet,
         output logic        JAwrite,
         output logic        JAerror,
         input logic        inJA1,
         output logic        outJA2, outJA3, outJA4
//          output logic        UART_CTS          
           );

       assign rxdata = inJA1;
       assign outJA2 = txd_mtrans_out;
       assign outJA3 = (SW[15]) ? 1 : 0  ;
       assign outJA4 = (txen_mtrans_out) ? 0 : 1 ;
       
       logic [7:0] data_fifo_in;
       //logic [7:0] data_mx_out;

       parameter BAUD = 50000;
       parameter OUTPUTBAUD = 9600;

       clkenb #(.DIVFREQ(BAUD)) CLKENBEIGHT(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRate));
       clkenb #(.DIVFREQ(OUTPUTBAUD)) CLKENDOUTPUT(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRateOutput));

       clkenb #(.DIVFREQ(OUTPUTBAUD/10)) CLKENBTEN(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRateTen));

       logic [5:0] length;
       logic [6:0] segments;
       logic [2:0] sev_data;

       assign length = {SW[13:8]};
       
       //single_pulser PULSER(.clk(CLK100MHZ), .din(BTNU), .d_pulse(buttonPulsed));

//       assign UART_RXD_OUT_copy = UART_RXD_OUT;

//    logic buttonDebounced = 0;
//    logic buttonPressed = 0;

//    always_ff @(posedge CLK100MHZ)
//        begin
//            if(buttonPresed)
//                buttonDebounced <= 0;
//            else if(BTNU && SW[15])
//                begin
//                    buttonDebounced <= 1;
//                    buttonPressed <= 1;
//                end
//            else if(SW[15])
//                buttonDebounced <= 1;
                       
//        end

       assign JAtxen = txen_mtrans_out;
       assign JAerror = error_mr_out;
       assign JAcardet = cardet_mr_out;
       assign JAwrite = write_mr_out;
       
       logic [7:0] tempdata;
       logic tempsend;
       
       always_ff@(posedge CLK100MHZ)
       begin
           if(SW[14]) 
           begin
               tempdata <= data_mx_out;
               tempsend <= send_mx_out;
           end
           else 
           begin
               tempdata <= SW[7:0];
               tempsend <= BTNU;
           end
       end

       
     parameter numBits = 64;
     
     logic write, clr, re;
     logic ready_trans;
     
     logic read_en_fifo_test;
     assign read_en_fifo_test = read_en_fifo;
     logic send_into_trans_test;
     assign send_into_trans_test = send_into_trans;

     logic [7:0] data_hold = 8'h00;
     logic [2:0] wait_delay;
     logic wait_delay_up;

     always_ff @(posedge CLK100MHZ) begin
         if(BTNC)
             data_hold <= 8'h00;
         else if(write_mr_out) begin
             data_hold <= data_m_receiver;
             wait_delay_up <= 1;
         end else begin
             data_hold <= data_hold;
             wait_delay_up <= 0;
         end
     end

     always_ff @(posedge CLK100MHZ) begin 
         if(BTNC)
             wait_delay <= 0;
         else if((wait_delay_up)) begin
             wait_delay <= wait_delay + 1;
         end 
         else if(wait_delay != 0 && BaudRate) begin
             wait_delay <= wait_delay + 1;
         end else begin
             wait_delay <= wait_delay;
         end
     end


 // add SystemVerilog code & module instantiations here

         wire [7:0] data_fifo_out;
          
       transmitter #(.BAUD(OUTPUTBAUD)) TRANS (
           .data(data_fifo_out),  
           .send(send_into_trans_test),
           .clk(CLK100MHZ), 
           .rst(BTNC), 
           .switch(1'b0), 
           .txd(UART_RXD_OUT), 
           .rdy(ready_trans)
       );
       
       logic error_arcvr, rdy_arcvr;
       logic [7:0] data_arcvr;
       
        receiver #(.BAUD(OUTPUTBAUD)) RCVR (
        .rxd(UART_RXD_OUT),
        .clk(CLK100MHZ), 
        .rst(BTNC),
        .ferr(error_arcvr),
        .rdy(rdy_arcvr),
        .data(data_arcvr)
           );
           

   //logic txd_mtrans_out;
   logic txen_mtrans_out, error_mtrans_out, cardet_mtrans_in;

       m_transmitter #(.BAUD(BAUD)) MTRANS(
           .data(~tempdata), 
           .send(tempsend), 
           .clk(CLK100MHZ), 
           .rst(BTNC), 
           .switch(BTNL), 
           .cardet(cardet_mtrans_in),
           .txd(txd_mtrans_out), 
           .rdy(ready_mtrans_out), 
           .txen(txen_mtrans_out),
           .error(error_mtrans_out)
       );

//    logic [7:0] data_fifo_in;

   assign data_fifo_in = {data_m_receiver[0], 
   data_m_receiver[1], data_m_receiver[2], data_m_receiver[3], 
   data_m_receiver[4], data_m_receiver[5], data_m_receiver[6], data_m_receiver[7]};

   logic [7:0] data_fifo_in_hold;

   assign data_fifo_in_hold = {data_hold[0], 
   data_hold[1], data_hold[2], data_hold[3], 
   data_hold[4], data_hold[5], data_hold[6], data_hold[7]};

        p_fifo4 #(.numBits(numBits)) FIFO(  
           .clk(CLK100MHZ), 
           .rst(~BTNC),        //needs that ~ cause rst is asserted low
           .clr(BTNC), 
           //.we(write_mr_out && BaudRate && ~error_mr_out), 
           .we(write_in_fifo),
           .re(read_en_fifo_test && BaudRateOutput),
           //.din(data_fifo_in),
           .din(data_fifo_in_hold),
           .full(full_fifo_out),
           .empty(empty_fifo_out),
           .dout(data_fifo_out)
           );

        assign write_in_fifo = (wait_delay == 3'b111 && ~error_mtrans_out && BaudRate && data_coming_in && addr_match);

       //logic ready_mtrans_out, 
       logic send_mx_out;

       mxtest_2 #(.WAIT_TIME(2_000_000_0)) U_MXTEST (
           .clk(CLK100MHZ), 
           .reset(BTNC), 
           .run(BTNU || BTND), 
           .send(send_mx_out),
           .length(length), 
           .data(data_mx_out), 
           .ready(ready_mtrans_out)
       );

       logic cardet_mr_out; 
       //logic write_mr_out, 
       //logic error_mr_out;
       
       mx_rcvr2 #(.BAUD(BAUD)) URCVR (
           //.rxd(txd_mtrans_out), 
           //.rxd(rxdata),
           .rxd(rxdata || txd_mtrans_out),
           .clk(CLK100MHZ), 
           .rst(BTNC),
           .button(BTNR),
           .data(data_m_receiver),
           .cardet(cardet_mr_out), 
           .write(write_mr_out), 
           .error(error_mr_out)
          );
                     
       //instantiate seven seg display[]
       dispctl DISPCTL (
           .clk(CLK100MHZ), 
           .reset(BTNC), 
           .d7(data_fifo_in[0]), 
           .d6(data_fifo_in[1]), 
           .d5(data_fifo_in[2]), 
           .d4(data_fifo_in[3]), 
           .d3(data_fifo_in[4]), 
           .d2(data_fifo_in[5]), 
           .d1(data_fifo_in[6]), 
           .d0(data_fifo_in[7]),
           
           .dp7(1'b0), 
           .dp6(1'b0), 
           .dp5(1'b0), 
           .dp4(1'b0), 
           .dp3(1'b0),
           .dp2(1'b0), 
           .dp1(1'b0), 
           .dp0(1'b0),
           .seg(SEGS),
           .dp(DP),
           .an(AN)
       );

   typedef enum logic [1:0] {
       IDLE = 2'b00,
       SEND = 2'b01,
       WAIT = 2'b10    
   } state_enable;
   
   state_enable state, next;

always_ff@(posedge CLK100MHZ)
  begin
   if(BTNC) 
       begin
           state <= IDLE;
       end
   else if(BaudRateOutput)
       begin
           state <= next;

       end 
   else
       begin
           state <= state;
       end
       
   end

   logic read_en_fifo;
   logic send_into_trans;

   always_comb
   begin 
       read_en_fifo = 0;
       send_into_trans = 0;
   case(state)
       IDLE:
           begin
               next = IDLE;
               if(~empty_fifo_out && ready_trans)
                   next = SEND;
           end
       SEND:
           begin
               next = SEND;
               send_into_trans = 1;
               if(~ready_trans)
               begin
                   next = WAIT;
                   read_en_fifo = 1;
               end
           end
       WAIT:
           begin
               next = WAIT;
               if(ready_trans)
                   next = IDLE;
           end

       default:
           begin
               next = IDLE;
               read_en_fifo = 0;
           end
       endcase
   end


   logic [7:0] data_counter;
   //logic data_coming_in;

   assign data_coming_in = (data_counter > 2);

  logic [7:0] dest_addr;
  logic [7:0] source_addr = 8'd64;
  logic [7:0] type_data;  
  
  always_ff @(posedge CLK100MHZ) begin
   if(BTNC || ~cardet_mtrans_in) begin
     data_counter <= 0;
   end else if(wait_delay == 3'b111 && ~error_mtrans_out && BaudRate) begin
     if(data_counter == 8'd0) dest_addr <= data_arcvr;
     if(data_counter == 8'd1) source_addr <= data_arcvr;
     if(data_counter == 8'd2) type_data <= data_arcvr;
     data_counter <= data_counter + 1;
   end
  end


  logic addr_match;
  logic [7:0] mac_addr, preamble, sfd;
  
  assign mac_addr = 8'd64;
  assign preamble = 8'h55;
  assign sfd = 8'h04;

  always_ff @(posedge CLK100MHZ) begin
    if(BTNC || ~cardet_mtrans_in) begin
     addr_match <= 0;
    end else if(mac_addr == dest_addr || dest_addr == 8'd42)begin
     addr_match <= 1;
    end
  end

       
       assign JAtxd = UART_RXD_OUT;
    
endmodule
