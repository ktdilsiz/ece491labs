`timescale 1ns / 1ps

module rcvr_controller(
      // un-comment the ports that you will use
      input logic         clk,
      input logic         receive_switch,
      input logic         rst,
      input logic  [7:0]  mac_addr,

      output logic        rxd_rcvr_out,
      output logic [7:0] data_m_receiver,
      output logic        JAcardet,
      output logic        JAwrite,
      output logic        JAerror,

      input logic        inJA1,
      output logic        outJA3
//      output logic        UART_CTS      
            );

        assign rxdata = inJA1;
        //assign outJA2 = txd_mtrans_out;
        assign outJA3 = (receive_switch) ? 1 : 0  ;
        // assign outJA4 = (txen_mtrans_out) ? 0 : 1 ;
        
      logic [7:0] data_fifo_in;
      //logic [7:0] data_m_receiver;

        parameter BAUD = 50000;
        parameter OUTPUTBAUD = 9600;

        clkenb #(.DIVFREQ(BAUD)) CLKENBEIGHT(.clk(clk), .reset(rst), .enb(BaudRate));
        clkenb #(.DIVFREQ(OUTPUTBAUD)) CLKENDOUTPUT(.clk(clk), .reset(rst), .enb(BaudRateOutput));
        clkenb #(.DIVFREQ(OUTPUTBAUD/10)) CLKENBTEN(.clk(clk), .reset(rst), .enb(BaudRateTen));
        
        assign JAerror = error_mr_out;
        assign JAcardet = cardet_mr_out;
        assign JAwrite = write_mr_out;
                
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

      always_ff @(posedge clk) begin
        if(rst)
          data_hold <= 8'h00;
        else if(write_mr_out) begin
          data_hold <= data_m_receiver;
          wait_delay_up <= 1;
        end else begin
          data_hold <= data_hold;
          wait_delay_up <= 0;
        end
      end

      always_ff @(posedge clk) begin 
        if(rst)
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
            .clk(clk), 
            .rst(rst), 
            .switch(1'b0), 
            .txd(rxd_rcvr_out), 
            .rdy(ready_trans)
        );

    assign data_fifo_in = {data_m_receiver[0], 
    data_m_receiver[1], data_m_receiver[2], data_m_receiver[3], 
    data_m_receiver[4], data_m_receiver[5], data_m_receiver[6], data_m_receiver[7]};

    logic [7:0] data_fifo_in_hold;

    assign data_fifo_in_hold = {data_hold[0], 
    data_hold[1], data_hold[2], data_hold[3], 
    data_hold[4], data_hold[5], data_hold[6], data_hold[7]};

         p_fifo4 #(.numBits(numBits)) FIFO(  
            .clk(clk), 
            .rst(~rst),        //needs that ~ cause rst is asserted low
            .clr(rst), 
            .we(write_in_fifo),
            .re(read_en_fifo_test && BaudRateOutput),
            .din(data_fifo_in_hold),
            .full(full_fifo_out),
            .empty(empty_fifo_out),
            .dout(data_fifo_out)
            );

         assign write_in_fifo = (wait_delay == 3'b111 && ~error_mr_out && BaudRate && data_coming_in && addr_match);

      logic cardet_mr_out; 
      //logic write_mr_out, 
      //logic error_mr_out;
      
      mx_rcvr2 #(.BAUD(BAUD)) URCVR (
            .rxd(rxdata),
            .clk(clk), 
            .rst(rst),
            .button(1'b0),
            .data(data_m_receiver),
            .cardet(cardet_mr_out), 
            .write(write_mr_out), 
            .error(error_mr_out)
           );


    typedef enum logic [1:0] {
        IDLE = 2'b00,
        SEND = 2'b01,
        WAIT = 2'b10    
    } state_enable;
    
    state_enable state, next;

always_ff@(posedge clk)
   begin
    if(rst) 
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

   always_ff @(posedge clk) begin
    if(rst || ~cardet_mr_out) begin
      data_counter <= 0;
    end else if(wait_delay == 3'b111 && ~error_mr_out && BaudRate) begin
      if(data_counter == 8'd0) dest_addr <= data_fifo_in_hold;
      if(data_counter == 8'd1) source_addr <= data_fifo_in_hold;
      if(data_counter == 8'd2) type_data <= data_fifo_in_hold;
      data_counter <= data_counter + 1;
    end
   end

   logic [7:0] dest_addr;
   logic [7:0] source_addr;
   logic [7:0] type_data;

   logic addr_match;

   always_ff @(posedge clk) begin
     if(rst || ~cardet_mr_out) begin
      addr_match <= 0;
     end else if(mac_addr == dest_addr || dest_addr == 8'd42)begin
      addr_match <= 1;
     end
   end

endmodule // nexys4DDR