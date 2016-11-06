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

module nexys4DDR (
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
		  output logic [7:0]  LED,
          output logic [7:0]  data_fifo,
          //output logic        data_m_trans,
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
		  output logic        UART_RXD_OUT,
		  output logic        UART_RXD_OUT_copy,
		  output logic        JAtxd,
		  output logic        JAtxen,
		  output logic        JAcardet,
		  output logic        JAwrite,
          output logic        JAerror
//		  output logic        UART_CTS		  
            );

        logic pleasemotherofgodwork, pulse;

        //debounce #(.DEBOUNCE_TIME_MS(1)) DEBOUNCER(.clk(CLK100MHZ), .button_in(BTNU), .button_out(pleasemotherofgodwork), .pulse(pulse));

        assign pleasemotherofgodwork = BTNU;

        assign LED[7] = pleasemotherofgodwork;
        assign LED[2] = BTNR || BTND;
            
        assign UART_RXD_OUT_copy = UART_RXD_OUT;
            
        logic [7:0] data_m_receiver;

        parameter BAUD = 50000;
        parameter OUTPUTBAUD = 19200;

        clkenb #(.DIVFREQ(BAUD)) CLKENBEIGHT(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRate));
        clkenb #(.DIVFREQ(OUTPUTBAUD/10)) CLKENBTEN(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRateTen));

        logic [5:0] length;
        logic [6:0] segments;
        logic [2:0] sev_data;
        logic rxd;
        assign length = {SW[14],SW[12:8]};


        // logic [5:0] write_count = 6'b000000;
        // always_ff@(posedge BaudRateTen)
        // begin
        //     if(BTNC)
        //         write_count <= 6'b000000;
        //     else if(BTNU && ~pleasemotherofgodwork)
        //         pleasemotherofgodwork <= 1'b1;
        //     else if(write_count == length)
        //     begin
        //         pleasemotherofgodwork <= 1'b0;
        //         write_count <= 6'b000000;
        //     end
        //     else
        //     begin
        //         pleasemotherofgodwork <= BTNU;
        //         write_count <= write_count + 1;
        //     end
        // end

        
        logic [7:0] tempdata;
        logic tempsend;
        
        logic [7:0] data;
        
        always_ff@(posedge CLK100MHZ)
        begin
            if(SW[13]) 
            begin
                tempdata <= data;
                tempsend <= send;
            end
            else 
            begin
                tempdata <= SW[7:0];
                tempsend <= pleasemotherofgodwork;
            end
        end

        logic re_fifo_top = 0;

        always_ff@(posedge CLK100MHZ)
        begin
            if(BTNC)
                re_fifo_top <= 1'b0;
            else if(SW[15] && BaudRateTen)
                re_fifo_top <= 1'b1;
            else if(~SW[15] && BaudRateTen)
                re_fifo_top <= 1'b0;
            else
                re_fifo_top <= re_fifo_top;

        end

        logic [4:0] time_count_wait;

        logic re_fifo_top_in;

        always_ff@(posedge BaudRate)
        begin
        if((~re_fifo_top || BTNC) && ~pleasemotherofgodwork)
            time_count_wait <= 5'b00000;
        else if(time_count_wait == 5'b11111)
            time_count_wait <= time_count_wait;
        else
            time_count_wait <= time_count_wait + 1;
        end

        
      // parameter LENGTH = 8;
      // parameter W = 8;
      // parameter R = 8;
      parameter numBits = 300;
      
      logic write, clr, re;
      //logic [7:0] data_m_receiver;
      //logic [7:0] data_fifo;
      //logic data_m_trans;  

      logic sendDebounced;

      logic readyMtrans;

      logic sendStart;

      always_ff@(posedge CLK100MHZ)
      begin
        if(BTNC)
            sendStart <= 1'b0;
        else if(re_fifo_top && BaudRateTen)
            sendStart <= 1'b1;
        else if(LED[6])
            sendStart <= 1'b0;
        else
            sendStart <= sendStart;
      end
      
  // add SystemVerilog code & module instantiations here
           
        transmitter #(.BAUD(OUTPUTBAUD)) TRANS (
            .data(data_fifo), 
            //.send(re_fifo_top && BaudRateTen && ~LED[5]), 
            .send(re_fifo_top && ~LED[5] && sendStart),
            //.send(send_into_trans2),
            .clk(CLK100MHZ), 
            .rst(BTNC), 
            .switch(1'b0), 
            .txd(UART_RXD_OUT), 
            .rdy(LED[6])
        );


        assign read_something = read_en_fifo;

        m_transmitter #(.BAUD(BAUD)) MTRANS(
            .data(~tempdata), 
            .send(tempsend), 
            .clk(CLK100MHZ), 
            .rst(BTNC), 
            .switch(BTNL), 
            .txd(data_m_trans), 
            .rdy(readyMtrans), 
            .txen(LED[1])
        );

    logic [7:0] data_fifo_in;

    logic empty_fifo, ready_trans;

    // logic read_en_fifo2;
    // logic send_into_trans2;

    assign read_en_fifo2 = read_en_fifo;
    assign send_into_trans2 = send_into_trans;

    assign empty_fifo = LED[5];
    assign ready_trans = LED[6];

    assign data_fifo_in = {data_m_receiver[0], 
    data_m_receiver[1], data_m_receiver[2], data_m_receiver[3], 
    data_m_receiver[4], data_m_receiver[5], data_m_receiver[6], data_m_receiver[7]};

 
        // p_fifo #(.BAUD(BAUD)) FIFO(  
        //     .clk(CLK100MHZ), 
        //     .rst(BTNC), 
        //     .clr(SW[14]), 
        //     .we(write), 
        //     .re(re_fifo_top_in ),
        //     .din(data_fifo_in),
        //     .full(LED[4]),
        //     .empty(LED[5]),
        //     .dout(data_fifo)
        //     );

        logic [7:0] dout_fifo_to_trans;

        always_ff@(posedge CLK100MHZ)
        begin
            if(testing)
                dout_fifo_to_trans <= data_fifo;
            else
                dout_fifo_to_trans <= dout_fifo_to_trans;
        end

        logic testing;

        assign testing = ~BaudRateTen;
        // data != 8'bxxxxxxxx;

         p_fifo4 #(.numBits(numBits)) FIFO(  
            .clk(CLK100MHZ), 
            .rst(~BTNC),        //needs that ~ cause rst is asserted low
            .clr(BTNC), 
            .we(write && BaudRate), 
            .re(re_fifo_top && BaudRateTen),
            //.re(read_en_fifo2),
            .din(data_fifo_in),
            .full(LED[4]),
            .empty(LED[5]),
            .dout(data_fifo)
            );

        mxtest_2 #(.WAIT_TIME(2_000_000)) U_MXTEST (
            .clk(CLK100MHZ), 
            .reset(BTNC), 
            .run(pleasemotherofgodwork), 
            .send(send),
            .length(length), 
            .data(data), 
            .ready(readyMtrans)
	    );
	    
	    mx_rcvr #(.BAUD(BAUD)) URCVR (
            .rxd(data_m_trans), 
            .clk(CLK100MHZ), 
            .rst(BTNC),
            .data(data_m_receiver),
            .cardet(LED[3]), 
            .write(write), 
            .error(JAerror)
           );
                      
        //instantiate seven seg display[]
        dispctl DISPCTL (
            .clk(CLK100MHZ), 
            .reset(BTNC), 
            .d7(data_m_receiver[7]), 
            .d6(data_m_receiver[6]), 
            .d5(data_m_receiver[5]), 
            .d4(data_m_receiver[4]), 
            .d3(data_m_receiver[3]), 
            .d2(data_m_receiver[2]), 
            .d1(data_m_receiver[1]), 
            .d0(data_m_receiver[0]),
            
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
    else if(BaudRate)
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
                if(~empty_fifo && ready_trans)
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
        
        assign JAtxd = UART_RXD_OUT;
        assign JAtxen = LED[1];
        assign JAcardet = LED[3]; //cardet
        assign JAwrite = write;
        //assign JA[7] = LED[0];

endmodule // nexys4DDR