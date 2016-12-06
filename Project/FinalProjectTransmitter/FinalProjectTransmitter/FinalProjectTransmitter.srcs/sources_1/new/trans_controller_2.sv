`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2016 01:37:41 PM
// Design Name: 
// Module Name: trans_controller_2
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


module trans_controller_2(
        input logic rxd_a_rcvr_in,
        input logic clk,
        input logic rst,
        output logic txd_m_trans_out
    );


	parameter BAUD = 50000;
	parameter OUTPUTBAUD = 9600;
	parameter NUMBITS = 64;

    parameter PREDATA = 8'h55;
    parameter SFDDATA = 8'hd0;


//////////////////////////////////////////////////////
//data wires
wire [7:0] data_a_rcvr_out, data_fifo_out;
reg [7:0] data_m_trans_in;
//m_trans wires
wire rdy_m_trans_out, txen_m_trans_out, error_m_trans_out;
reg send_m_trans_in;
//a_rcvr wires
wire error_a_rcvr_out, rdy_a_rcvr_out;
//fifo wires
wire full_fifo_out, empty_fifo_out;

///////////////////////////////////////////////////////

	m_transmitter #(.BAUD(BAUD)) TRAN(
    .data(data_m_trans_in), //55,55,d0
    .send(send_m_trans_in),
    .clk(clk), 
    .rst(rst), 
    .switch(0), //assuming not used
    .txd(txd_m_trans_out),
    .rdy(rdy_m_trans_out), 
    .txen(txen_m_trans_out),
    .error(error_m_trans_out) //add this output to mx_tran
    );

    receiver #(.BAUD(OUTPUTBAUD)) RCVR (
    .rxd(rxd_a_rcvr_in),
    .clk(clk), 
    .rst(rst),
    .ferr(error_a_rcvr_out),
    .rdy(rdy_a_rcvr_out),
    .data(data_a_rcvr_out)
    );

    p_fifo4 #(.numBits(NUMBITS)) FIFO(  
    .clk(clk), 
    .rst(~rst),        //needs that ~ cause rst is asserted low
    .clr(rst), 
    .we(write_p_fifo_in),
    .re(read_p_fifo_in),
    .din(data_a_rcvr_out),
    .full(full_fifo_out),
    .empty(empty_fifo_out),
    .dout(data_fifo_out)
    );

    logic write_p_fifo, read_p_fifo;
    assign write_p_fifo_in = write_p_fifo;
    assign read_p_fifo_in = read_p_fifo;

//////////////////////////////////////////////////////////

    clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
    clkenb #(.DIVFREQ(OUTPUTBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(OutputBaudRate));
    clkenb #(.DIVFREQ(BAUD/8)) CLKENBEIGHT(.clk(clk), .reset(rst), .enb(EightBaudRate));

    typedef enum logic [3:0] {
        IDLE = 4'b0000, 
        PREAMBLE1 = 4'b1010, 
        PREAMBLE2 = 4'b0001, 
        SFD = 4'b0010, 
        DEST = 4'b0011,
        SOURCE = 4'b0100, 
        TYPE = 4'b0101, 
        DATARCVR = 4'b0110,
        DATATRANS = 4'b0111
        // TR7 = 4'b1000, 
        // STOP = 4'b1001,
        // WAIT = 4'b1111,
        // EOF1 = 4'b1101,
        // EOF2 = 4'b1100
    } state_t;

    state_t state, next;
    
   always_ff@(posedge clk)
   begin
    if(rst) 
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

    always_comb
       begin 
        write_p_fifo = 0;
        read_p_fifo = 0;

        send_m_trans_in = 0;

       case(state)

        IDLE: begin

            if(~rdy_a_rcvr_out)
                next = DEST;

        end

        DEST: begin 

            if(rdy_a_rcvr_out && OutputBaudRate)
            begin
                next = SOURCE;
                write_p_fifo = 1;
            end

        end

        SOURCE: begin 

            if(rdy_a_rcvr_out && OutputBaudRate)
            begin
                next = TYPE;
                write_p_fifo = 1;
            end

        end

        TYPE: begin 

            if(rdy_a_rcvr_out && OutputBaudRate)
            begin
                next = DATARCVR;
                write_p_fifo = 1;
            end

        end

        DATARCVR: begin 

            //data_m_trans_in = PREDATA;

            if(rdy_a_rcvr_out && OutputBaudRate && rcvr_rdy_count == 2'd0)
            begin
                next = DATARCVR;
                write_p_fifo = 1;
            end

            if(rcvr_rdy_count == 2'd2)
            begin
                next = PREAMBLE1;
            end

        end

        PREAMBLE1: begin

            data_m_trans_in = PREDATA;

            if(EightBaudRate)
            begin
                send_m_trans_in = 1;
                next = PREAMBLE2;
            end

        end

        PREAMBLE2: begin 

            data_m_trans_in = PREDATA;

            if(EightBaudRate)
            begin
                send_m_trans_in = 1;
                if(state == PREAMBLE2)
                    next = SFD;
            end

        end

        SFD: begin 

            data_m_trans_in = SFDDATA;

            if(EightBaudRate && state == SFD)
            begin
                send_m_trans_in = 1;
                next = DATATRANS;
            end

        end        

        DATATRANS: begin 


        end


        default: begin
            next = IDLE;
        end

       endcase

   end


logic [1:0] rcvr_rdy_count = 2'd0;
always_ff @(posedge clk)
begin
    if(rst || rcvr_rdy_count == 2)
        rcvr_rdy_count = 2'd0;
    else if(rdy_a_rcvr_out && OutputBaudRate)
        rcvr_rdy_count = rcvr_rdy_count + 1;
    else if(OutputBaudRate)
        rcvr_rdy_count = 2'd0;
end

logic [1:0] trans_send_count = 2'd0;
always_ff @(posedge clk)
begin
    if(rst || trans_send_count == 2)
        trans_send_count = 2'd0;
    else if(EightBaudRate)
        trans_send_count = trans_send_count + 1;
end


endmodule
