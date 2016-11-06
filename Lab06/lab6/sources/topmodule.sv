`timescale 1ns / 1ps

module topmodule (
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
          output logic [7:0]  data_m_receiver,
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

	    logic [7:0] data_fifo_in;
        logic [7:0] data_mx_out;

        parameter BAUD = 50000;
        parameter OUTPUTBAUD = 19200;

        clkenb #(.DIVFREQ(BAUD)) CLKENBEIGHT(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRate));
        clkenb #(.DIVFREQ(OUTPUTBAUD)) CLKENDOUTPUT(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRateOutput));

        clkenb #(.DIVFREQ(OUTPUTBAUD/10)) CLKENBTEN(.clk(CLK100MHZ), .reset(BTNC), .enb(BaudRateTen));

        logic [5:0] length;
        logic [6:0] segments;
        logic [2:0] sev_data;

        assign length = {SW[14],SW[12:8]};
        
        logic [7:0] tempdata;
        logic tempsend;
        
        always_ff@(posedge CLK100MHZ)
        begin
            if(SW[13]) 
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

    logic txd_mtrans_out, txen_mtrans_out;

        m_transmitter #(.BAUD(BAUD)) MTRANS(
            .data(tempdata), 
            .send(tempsend), 
            .clk(CLK100MHZ), 
            .rst(BTNC), 
            .switch(BTNL), 
            .txd(txd_mtrans_out), 
            .rdy(ready_mtrans_out), 
            .txen(txen_mtrans_out)
        );

//    logic [7:0] data_fifo_in;

    assign data_fifo_in = {data_m_receiver[0], 
    data_m_receiver[1], data_m_receiver[2], data_m_receiver[3], 
    data_m_receiver[4], data_m_receiver[5], data_m_receiver[6], data_m_receiver[7]};

         p_fifo4 #(.numBits(numBits)) FIFO(  
            .clk(CLK100MHZ), 
            .rst(~BTNC),        //needs that ~ cause rst is asserted low
            .clr(BTNC), 
            .we(write_mr_out && BaudRate), 
            .re(read_en_fifo_test && BaudRateOutput),
            .din(data_fifo_in),
            .full(full_fifo_out),
            .empty(empty_fifo_out),
            .dout(data_fifo_out)
            );

        //logic ready_mtrans_out, 
        logic send_mx_out;

        mxtest_2 #(.WAIT_TIME(2_000_000)) U_MXTEST (
            .clk(CLK100MHZ), 
            .reset(BTNC), 
            .run(BTNU), 
            .send(send_mx_out),
            .length(length), 
            .data(data_mx_out), 
            .ready(ready_mtrans_out)
	    );

	    logic cardet_mr_out; 
	    //logic write_mr_out, 
	    logic error_mr_out;
	    
	    mx_rcvr #(.BAUD(BAUD)) URCVR (
            .rxd(txd_mtrans_out), 
            .clk(CLK100MHZ), 
            .rst(BTNC),
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
        
        assign JAtxd = UART_RXD_OUT;

endmodule // nexys4DDR