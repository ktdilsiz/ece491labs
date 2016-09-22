`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College 
// Engineer(s): 
// Kemal Dilsiz
// Zainab Hussein 
// 
// Create Date: 09/20/2016 01:54:21 PM
// Design Name: Receiver
// Module Name: receiver
// Project Name: Lab04 ECE 491
// Target Devices: Nexys 4 DDR
// Tool Versions: System Verilog, Vivado
// Description: 
// Will receive asynchronous serial transmission and convert it into 8 bit wide data.
// 
// Baud Rate is passed from the top level and SIXTEENBAUD is used for this receiver where we sample the input.
//
// Dependencies: 
// 
// Revision: 9/20/2016
// Revision 0.01 - File Created
// Additional Comments:
// No
// 
//////////////////////////////////////////////////////////////////////////////////


module receiver(
    input logic rxd,
    input logic clk, rst,
    output logic ferr,
    output logic rdy,
    output logic [7:0] data
    );
    
    parameter BAUD = 9600;
    parameter SIXTEENBAUD = BAUD * 16;
    logic BaudRate, rxd_prev;
    logic [2:0] state_count;

    //clkenb is used for getting a enable signal that follows the desired baudrate
    clkenb #(.DIVFREQ(SIXTEENBAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
    
    typedef enum logic [3:0] {
        IDLE = 4'b0000, 
        START = 4'b1010, 
        RECEIVE = 4'b0001, 
//        TR1 = 4'b0010, 
//        TR2 = 4'b0011,
//        TR3 = 4'b0100, 
//        TR4 = 4'b0101, 
//        TR5 = 4'b0110, 
//        TR6 = 4'b0111, 
//        TR7 = 4'b1000, 
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
       
    logic trigger; 
    always_ff@(posedge clk)
        begin
            if(rst)
                begin 
                    state_count <= 3'b0;
                end
             else if(trigger)
                begin
                    state_count <= state_count;
                end
          end
        
       logic time_count, increase;  
   
   always_ff@(posedge clk)
         begin
             if(rst)
                 begin 
                     time_count <= 4'b0;
                 end
              else if(increase)
                 begin
                     time_count <= time_count + 1;
                 end
              else
                 begin
                     time_count <= time_count;
                 end
           end
    
    always_comb
       begin
        case(state)
            IDLE:
                begin
                    rdy = 0;
                    ferr = 0;
                    if((time_count == 0) && rxd ) 
                        begin
                            next = IDLE;
                        end
                     else if(~rxd)
                        begin
                            increase = 1;
                            next = START;
                        end
                            
//                    if((time_count == 7) && (~rxd))
//                        begin
                            
//                        end
//                    else if(time_count > 0)
//                        begin
//                            increase = 1;
//                        end
//                    else if(~rxd)
//                        begin
//                            time_count = time_count + 1;
//                        end
                    
                end
            
            START:
                begin
                    increase = 1;
                    next = START;
                    if((time_count == 7) && rxd)
                        begin
                            next = IDLE;
                            ferr = 1;
                        end
                    if((time_count == 14) && rxd)
                        begin
                            next = IDLE;
                            ferr = 1;
                        end
                end
            
            RECEIVE:
                begin
                    increase = 1;
                    next = RECEIVE;
                    if(time_count == 8)
                        begin
                            trigger = 1;
                            data[state_count] = rxd;
                            rdy = 0;
                            ferr = 0;
                        end 
                    if(state_count == 7)
                        begin
                            next = STOP;
                        end
                end
            STOP:
                begin
                   rdy = 1;
                   increase = 1;
                   next = STOP;
                   if(time_count == 8 && ~rxd)
                       begin
                            ferr = 1;
                            next = IDLE;
                       end
                   else if(time_count == 8 && rxd)
                       begin
                            ferr = 0;
                       end 
                   else if(time_count == 0)
                       begin
                            next = IDLE;
                       end
               end
            
            default:
                begin
                next = IDLE;
                rdy = 1;
                ferr = 0;
                end
        endcase
       
    end
    
endmodule
