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
    output logic rdy, txen
    );
    
    parameter BAUD = 9600;
    parameter TWICEBAUD = BAUD * 2;
    logic BaudRate;
    
    logic [7:0] tempdata;
        
    //logic clkEnb;
   // logic [7:0] k;

    clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
    clkenb #(.DIVFREQ(TWICEBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(TwiceBaudRate));
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
        WAIT = 4'b1111,
        EOF1 = 4'b1101,
        EOF2 = 4'b1100
    } state_t;

    state_t state, next;
    
    typedef enum logic [1:0] {
        FIRSTHALF = 2'b00,
        SECONDHALF = 2'b01    
    } state_enable;
    
    state_enable dataState, nextDataState;
    
   always_ff@(posedge clk)
   begin
    if(rst) 
        begin
            state <= IDLE;
        end
    else if(BaudRate)
        begin
            state <= next;
            dataState <= nextDataState;
        end 
    else if(TwiceBaudRate)
        begin
            dataState <= nextDataState;
        end
    else
        begin
            state <= state;
        end
        
    end
    
    always_comb
    begin 
    case(dataState)
        FIRSTHALF:
            begin
                tempdata = ~data;
                nextDataState = SECONDHALF;
            end
        SECONDHALF:
            begin
                tempdata = data;
                nextDataState = FIRSTHALF;
            end
        default:
            begin
            tempdata = 1;
            nextDataState = FIRSTHALF;
            end
        endcase
    end
    
    always_comb
    begin    
    case(state)
        IDLE:
            begin
                if(send)
                    begin
                    txd = 1;
                    next = TR0;
                    rdy = 1;
                    txen = 0;
                    end
                else
                    begin
                    txd = 1;
                    next = IDLE;
                    rdy = 1;
                    txen = 0;
                    end
            end    
        TR0:
               begin
                txd = tempdata[0];
                next = TR1;
                rdy = 0;
                txen = 1;
                end
        TR1:
                begin
                txd = tempdata[1];
                next = TR2;
                rdy = 0;
                txen = 1;
                end
        TR2:
                begin
                txd = tempdata[2];
                next = TR3;
                rdy = 0;
                txen = 1;
                end
        TR3:
                begin
                txd = tempdata[3];
                next = TR4;
                rdy = 0;
                txen = 1;
                end
        TR4:
                begin
                txd = tempdata[4];
                next = TR5;
                rdy = 0;
                txen = 1;
                end
        TR5:
                begin             
                txd = tempdata[5];
                next = TR6;
                rdy = 0;
                txen = 1;
                end
        TR6:
                begin
                txd = tempdata[6];
                next = TR7;
                rdy = 0;
                txen = 1;
                end
        TR7:
                begin
                    if(send && ~switch)
                    begin
                        txd = tempdata[7];
                        next = TR0;
                        rdy = 1;
                        txen = 1;
                    end                    
                else if (switch)
                    begin
                        txd = tempdata[7];
                        next = WAIT;
                        rdy = 1;
                        txen = 1;
                    end
                else
                    begin                
                        txd = tempdata[7];
                        next = IDLE;
                        rdy = 1;
                        txen = 1;
                    end
                end    
         EOF1:
            begin
                txen = 1;
                rdy = 1;
                txd = 1;
                next = EOF2;
            end
         EOF2:
               begin
                   txen = 1;
                   rdy = 1;
                   txd = 1;
                   next = IDLE;
               end
         WAIT:
            if(switch)
                begin
                   txd = 1;
                   rdy = 1;
                   txen = 0; 
                   next = WAIT; 
                end
            else
                begin
                    txd = 1;
                    rdy = 1;
                    txen = 0; 
                    next = IDLE;
                end
            
        default: 
            begin
                next = IDLE;
                rdy = 1;
                txd = 1;
                txen = 0;
            end     
        endcase
      end

endmodule
