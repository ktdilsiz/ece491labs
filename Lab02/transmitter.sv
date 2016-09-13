`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2016 02:27:00 PM
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module transmitter (
    input logic [7:0] data,
    input logic send,
    input logic clk, rst, switch,
    output logic txd,
    output logic rdy
    );
    
    parameter BAUD = 9600;
    logic BaudRate;
    
    //logic clkEnb;
   // logic [7:0] k;

    clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
    //reg_parm #(.W(8)) REG1(.clk(clk), .reset(rst), .lden(Iden), .d(data), .k(k));

    typedef enum logic [3:0] {
        IDLE = 4'b0000, 
        START = 4'b1010, 
        TR0 = 4'b0001, 
        TR1 = 4'b0010, 
        TR2 = 4'b0011,
        TR3 = 4'b0100, 
        TR4 = 4'b0101, 
        TR5 = 4'b0110, 
        TR6 = 4'b0111, 
        TR7 = 4'b1000, 
        STOP = 4'b1001,
        WAIT = 4'b1111
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
    case(state)
        IDLE:
            begin
                if(send)
                    begin
                    txd = 1;
                    next = START;
                    rdy = 0;
                    end
                else
                    begin
                    txd = 1;
                    next = IDLE;
                    rdy =1;
                    end
            end
            
        START:
                begin
                txd = 0;
                next = TR0;
                rdy = 0;
                end
        TR0:
               begin
                txd = data[0];
                next = TR1;
                rdy = 0;
                end
        TR1:
                begin
                txd = data[1];
                next = TR2;
                rdy = 0;
                end
        TR2:
                begin
                txd = data[2];
                next = TR3;
                rdy = 0;
                end
        TR3:
                begin
                txd = data[3];
                next = TR4;
                rdy = 0;
                end
        TR4:
                begin
                txd = data[4];
                next = TR5;
                rdy = 0;
                end
        TR5:
                begin             
                txd = data[5];
                next = TR6;
                rdy = 0;
                end
        TR6:
                begin
                txd = data[6];
                next = TR7;
                rdy = 0;
                end
        TR7:
                begin
                txd = data[7];
                next = STOP;
                rdy = 0;
                end
        STOP:
            begin
                if(send && ~switch)
                    begin
                    txd = 1;
                    next = START;
                    rdy = 0;
                    end
                else if (switch)
                    begin
                    txd = 1;
                    next = WAIT;
                    rdy = 0;
                    end
                else
                    begin
                    txd = 1;
                    next = IDLE;
                    rdy = 1;
                    end
            end
            
         WAIT:
            if(switch)
                begin
                   txd = 1;
                   rdy = 0;
                   next = WAIT; 
                end
            else
                begin
                    txd = 1;
                    rdy = 0;
                    next = IDLE;
                end
            
        default: 
            begin
                next = IDLE;
                rdy = 1;
                txd = 1;
            end     
        endcase
      end

endmodule
