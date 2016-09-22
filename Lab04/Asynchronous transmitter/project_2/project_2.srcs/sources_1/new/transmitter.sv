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

module transmitter(
    input logic [7:0] data,
    input logic send,
    input logic clk, rst,
    output logic txd,
    output logic rdy
    );
    
//    logic [2:0] count = 0;
//    logic reset;
    
    typedef enum logic [3:0] {
    IDLE = 4'b0000, START = 4'b1010, TR0 = 4'b0001, TR1 = 4'b0010, TR2 = 4'b0011,
    TR3 = 4'b0100, TR4 = 4'b0101, TR5 = 4'b0110, 
    TR6 = 4'b0111, TR7 = 4'b1000, STOP = 4'b1001
    } state_t;

    state_t state, next;
    
   always_ff@(posedge clk)
    if(rst) 
        begin
            state <= IDLE;
        end
    else   
        begin
            state <= next;
        end
        
//        reg [2:0] counter;
//        reg [2:0] counter_next;
        
//        always @(*) begin
//           counter_next = counter + 1;
//        end
        
//        always @(posedge clk) 
//        begin
//           if (rst)
//              counter <= 4'b0;
//           else
//              counter <= counter_next;
//        end
    
//    always_comb
//    begin
//    rdy = 1;
//    txd = 1;
//    case(state)
    
//        IDLE:
//            begin
//                if(send)
//                    begin
//                        txd = 0;
//                        rdy = 1;
//                        count = 0;
//                        next = TRANSFER;
//                    end
//                else
//                    begin
//                        txd = 1;
//                        rdy = 1;
//                        count = counter - 2;
//                        next = IDLE;
                     
//                    end
//            end
            
//        TRANSFER:
//            begin
//                if(count == 6)
//                    begin
//                        count = counter -2;
//                        txd = data[count];
//                        rdy = 0;
//                        next = STOP;
//                    end    
//                else
//                    begin
//                        count = counter -2;
//                        txd = data[count];
//                        rdy = 0;
//                        next = TRANSFER;
//                    end
//            end    
               
//         STOP:
//            begin
//                count = 0;
//                txd = 1;
//                rdy = 1;
//                next = IDLE;
//            end         
                
//        endcase
//      end
    
    always_comb
    begin
    txd = 1;
    rdy = 1;
    case(state)
        IDLE:
            begin
                if(send)
                    begin
                    txd = 0;
                    next = START;
                    end
                else
                    begin
                    txd = 1;
                    next = IDLE;
                    end
            end
            
        START:
            begin
            txd = 0;
            next = TR0;
            end
        TR0:
            begin
            txd = data[0];
            next = TR1;
            end
        TR1:
            begin
            txd = data[1];
            next = TR2;
            end
        TR2:
            begin
            txd = data[2];
            next = TR3;
            end
        TR3:
            begin
            txd = data[3];
            next = TR4;
            end
        TR4:
            begin
            txd = data[4];
            next = TR5;
            end
        TR5:
            begin               
            txd = data[5];
            next = TR6;
            end
        TR6:
            begin
            txd = data[6];
            next = TR7;
            end
        TR7:
            begin
            txd = data[7];
            next = STOP;
            end
        STOP:
            begin
                if(send)
                    begin
                    txd = 0;
                    next = START;
                    end
                else
                    begin
                    txd = 1;
                    next = IDLE;
                    end
            end
//            begin
//            txd = 1;
//            next = IDLE;
//            end     
        endcase
      end
    
        
    
endmodule
