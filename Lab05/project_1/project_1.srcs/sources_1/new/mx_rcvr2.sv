`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2016 11:35:49 PM
// Design Name: 
// Module Name: mx_rcvr2
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


module mx_rcvr2(
	input logic rxd, clk, rst,
    output logic [7:0] data,
    output logic cardet, write, error
   );

	assign error = h_out_bit;
	assign cardet = (state == RECEIVE) ? 1 : 0;
	//assign cardet = write;
   
   parameter BAUD = 9600;
   parameter TWICEBAUD = BAUD * 2;
   parameter SIXTEENBAUD = BAUD * 16;
   parameter SIXTYFOURBAUD = BAUD * 64;
   parameter BIT_RATE = 50_000;	


   clkenb #(.DIVFREQ(BAUD)) CLKENB(.clk(clk), .reset(rst), .enb(BaudRate));
   clkenb #(.DIVFREQ(TWICEBAUD)) CLKENB2(.clk(clk), .reset(rst), .enb(TwiceBaudRate));
   clkenb #(.DIVFREQ(SIXTEENBAUD)) CLKENB3(.clk(clk), .reset(rst), .enb(SixteenBaudRate));
   clkenb #(.DIVFREQ(BAUD * 4)) CLKENB4(.clk(clk), .reset(rst), .enb(FourthBaudRate));
   clkenb #(.DIVFREQ(BAUD * 8)) CLKENB5(.clk(clk), .reset(rst), .enb(EightBaudRate));


   typedef enum logic [3:0] {
       //IDLE =       4'b0000, 
       PREAMBLE =   4'b1010, 
       SFD =        4'b0001, 
       RECEIVE =    4'b0010, 
       EOF =        4'b0011
   } state_t;

   state_t state, next;

  always_ff@(posedge clk)
  begin
   if(rst) 
       begin
           state <= PREAMBLE;
       end
   else if(SixteenBaudRate)
       begin
           state <= next;
       end 
   end


   logic enb_pre, h_out_pre, l_out_pre;
   logic d_in_pre;
   logic [3:0] csum_pre;

   logic rst_pre, rst_bit, rst_baud, rst_sfd;
   logic [7:0] replace_pre, replace_sfd, replace_bit, replace_baud;


   
   //instantiate the correlator module
   correlator #(.LEN(8), .PATTERN(8'b10101010), .HTHRESH(7), .LTHRESH(1)) 
       COR_PREAM( 
       .clk(clk), 
       .reset(rst_pre || rst), 
       .enb(enb_pre), 
       .d_in(d_in_pre), 
       .replace(replace_pre),
       .csum(csum_pre), 
       .h_out(h_out_pre), 
       .l_out(l_out_pre));
       
   logic enb_sfd, h_out_sfd, l_out_sfd;
   logic d_in_sfd;
   logic [3:0] csum_sfd;
   
   //correlator module for sfd
   correlator #(.LEN(8), .PATTERN(8'b11010000), .HTHRESH(7), .LTHRESH(1))
    COR_SFD( 
    .clk(clk), 
    .reset(rst_sfd || rst), 
    .enb(enb_sfd), 
    .d_in(d_in_sfd), 
    .replace(replace_sfd),
    .csum(csum_sfd), 
    .h_out(h_out_sfd), 
    .l_out(l_out_sfd));
    
   logic enb_eof, h_out_eof, l_out_eof;
   logic d_in_eof, rst_eof;
   logic [4:0] csum_eof;
   logic [11:0] replace_eof = 12'bxxxxxxxxxxxx;
   
   //correlator module for eof
   correlator #(.LEN(12), .PATTERN(12'b111111111111), .HTHRESH(10), .LTHRESH(1))
    COR_EOF( 
    .clk(clk), 
    .reset(rst_eof || rst), 
    .enb(enb_eof), 
    .d_in(d_in_eof), 
    .replace(replace_eof),
    .csum(csum_eof), 
    .h_out(h_out_eof), 
    .l_out(l_out_eof));
    
    logic enb_bit, h_out_bit, l_out_bit;
    logic d_in_bit;
    logic [3:0] csum_bit;

 //correlator module for bit
 correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(7), .LTHRESH(1)) 
    COR_BIT( 
    .clk(clk), 
    .reset(rst_bit || rst), 
    .enb(enb_bit), 
    .d_in(d_in_bit), 
    .replace(replace_bit),
    .csum(csum_bit), 
    .h_out(h_out_bit), 
    .l_out(l_out_bit));
   
    logic enb_baud, h_out_baud, l_out_baud;
    logic d_in_baud;
    logic [3:0] csum_baud;
   
  //correlator module for baudrate mismatch
 correlator #(.LEN(8), .PATTERN(8'b11110000), .HTHRESH(7), .LTHRESH(1)) 
    COR_MIS_BAUD( 
    .clk(clk), 
    .reset(rst_baud || rst), 
    .enb(enb_baud), 
    .d_in(d_in_baud), 
    .replace(replace_baud),
    .csum(csum_baud), 
    .h_out(h_out_baud), 
    .l_out(l_out_baud));

    //////////////////////////////////////////////////////////////////////////////////


    logic reset_time_count = 0;
    logic reset_bit_count = 0;
    logic bit_up; 
    logic [2:0] bit_count = 3'b111;
    logic [3:0] time_count = 4'b0000;
    logic time_up, time_up_double, time_down;  
    
    always_ff@(posedge clk)
        begin
            if((rst || reset_bit_count))
                begin 
                    bit_count <= 3'b111;
                end
             else if(bit_up)
                begin
                    bit_count <= bit_count - 1;
                end
          end
                     
   always_ff@(posedge clk)
         begin
             if((reset_time_count || rst))
                 begin 
                     time_count <= 4'b0000;
                 end
              else if(time_down)
              begin
              		time_count <= time_count - 1;
              end
              else if(time_up_double && SixteenBaudRate)
                 begin
                     time_count <= time_count + 2;
                 end   
              else if(time_up && SixteenBaudRate)
                 begin
                     time_count <= time_count + 1;
                 end
              else
                 begin
                     time_count <= time_count;
                 end
           end

   logic enable_data;  
   logic d0,d1,d2,d3,d4,d5,d6,d7;  
    
    assign data = {d7,d6,d5,d4,d3,d2,d1,d0};
        
   always_ff@(posedge clk) 
   begin
       if(enable_data)
       begin
         case (bit_count)
               3'd0 : d0 = rxd;
               3'd1 : d1 = rxd;
               3'd2 : d2 = rxd;
               3'd3 : d3 = rxd;
               3'd4 : d4 = rxd;
               3'd5 : d5 = rxd;
               3'd6 : d6 = rxd;
               3'd7 : d7 = rxd;
         endcase
       end
   end // always_ff 

   // logic enable_data;  
   // logic d0,d1,d2,d3,d4,d5,d6,d7;  
    
   //  assign data = {d6,d5,d4,d3,d2,d1,d0,d7};
        
   // always_ff@(posedge clk) 
   // begin
   //     if(enable_data)
   //     begin
   //       case (bit_count)
   //             3'd0 : d0 = (h_out_bit) ? 1 : 0;
   //             3'd1 : d1 = (h_out_bit) ? 1 : 0;
   //             3'd2 : d2 = (h_out_bit) ? 1 : 0;
   //             3'd3 : d3 = (h_out_bit) ? 1 : 0;
   //             3'd4 : d4 = (h_out_bit) ? 1 : 0;
   //             3'd5 : d5 = (h_out_bit) ? 1 : 0;
   //             3'd6 : d6 = (h_out_bit) ? 1 : 0;
   //             3'd7 : d7 = (h_out_bit) ? 1 : 0;
   //       endcase
   //     end
   // end // always_ff 


  logic input_pre_check = 1'b0;
  logic input_pre_check_up;

  always_ff@(posedge clk)
    begin
        if((rst))
            begin 
                input_pre_check <= 1'b0;
            end
        else if(input_pre_check_up)
            begin
                input_pre_check <= 1'b1;
            end
         else if(FourthBaudRate)
            begin
                input_pre_check <= 1'b0;
            end
      end


  logic input_check = 1'b0;
  logic input_check_up;

  always_ff@(posedge clk)
    begin
        if((rst))
            begin 
                input_check <= 1'b0;
            end
        else if(input_check_up)
            begin
                input_check <= 1'b1;
            end
         else if(TwiceBaudRate)
            begin
                input_check <= 1'b0;
            end
      end

   	logic [1:0] fourth_count = 2'd0;
   	logic fourth_count_up;
   	logic totalReset = 0;
   	logic fourth_count_reset = 0;

   	always_ff@(posedge clk)
   		if((totalReset || rst || fourth_count == 2'd3 || fourth_count_reset) && (~h_out_bit && ~l_out_bit))
   			fourth_count <= 0;
   		else if(fourth_count_up && FourthBaudRate)
   			fourth_count <= fourth_count + 1;

  logic [4:0] time_count_sfd_error;
  logic reset_time_count_sfd_error;
  logic time_sfd_error_up = 0;

 always_ff@(posedge clk)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(reset_time_count_sfd_error || rst)
             begin 
                 time_count_sfd_error <= 5'b00000;
             end
          else if(time_sfd_error_up && BaudRate)
             begin
                 time_count_sfd_error <= time_count_sfd_error + 1;
             end 
          else
             begin
                 time_count_sfd_error <= time_count_sfd_error;
             end
       end   	


  logic [3:0] time_count_empty;
  logic reset_time_count_empty;
  logic time_empty_up = 0;

 always_ff@(posedge clk)
     begin
         //if((reset_time_count_sfd || rst || time_count_sfd == 4'b1111))
         if(reset_time_count_empty || rst || (~time_empty_up && time_count_empty != 4'b1111))
             begin 
                 time_count_empty <= 4'b0000;
             end
          else if(time_empty_up && EightBaudRate)
             begin
                 time_count_empty <= time_count_empty + 1;
             end 
          else
             begin
                 time_count_empty <= time_count_empty;
             end
       end   


logic check_first_byte = 0;
logic check_first_byte_up = 0;
logic check_first_byte_down = 0;

always_ff@(posedge clk)
    begin
    	if(rst || check_first_byte_down)
    		check_first_byte <= 1'b0;
    	else if(check_first_byte_up && BaudRate)
    		check_first_byte <= 1'b1;
    end


   always_comb
   begin  

   	check_first_byte_up = 0;
   	check_first_byte_down = 0;

   	input_check_up = 0;
   	input_pre_check_up = 0;

   	time_up = 0;
   	time_down = 0;
   	time_up_double = 0;
   	time_sfd_error_up = 0;
   	bit_up = 0;
   	enable_data = 0;
   	reset_time_count = 0;
   	reset_bit_count = 0;
   	reset_time_count_sfd_error = 0;
   	reset_time_count_empty = 0;

   	d_in_pre = 0;
   	d_in_sfd = 0;
   	d_in_bit = rxd;
   	d_in_eof = rxd;
   	d_in_baud = rxd;

   	enb_bit = 0;
   	enb_eof = 0;
   	enb_sfd = 0;
   	enb_pre = 0;
   	enb_baud = 0;

   	rst_bit = 0;
   	rst_sfd = 0;
   	rst_pre = 0;
   	rst_baud = 0;
   	rst_eof = 0;

   	write = 0;

   	time_empty_up = 0;

   	fourth_count_up = 0;
   	fourth_count_reset = 0;

   	//cardet = 0;
   	//error = 0;

   	replace_pre = 8'bxxxxxxxx;
   	replace_sfd = 8'bxxxxxxxx;
   	replace_bit = 8'bxxxxxxxx;
   	replace_baud = 8'bxxxxxxxx;
   	replace_eof = 12'bxxxxxxxxxxxx;

	case(state)
       PREAMBLE:
       begin
       	next = PREAMBLE;
       	time_up = 1;
       	reset_time_count_sfd_error = 1;
       	reset_time_count_empty = 1;
       	check_first_byte_down = 1;

       	if(time_count % 2 == 1 && SixteenBaudRate)
           begin
              enb_bit = 1;
           end

        if(h_out_bit == 1 && ~input_pre_check && TwiceBaudRate)
          begin
            d_in_pre = 1; enb_pre = 1;
            input_pre_check_up = 1;
          end

        if(l_out_bit == 1 && ~input_pre_check && TwiceBaudRate) 
          begin
            d_in_pre = 0; enb_pre = 1;
            input_pre_check_up = 1;
          end

          //ERROR IS HERE KEMAL AND ZAINAB LOOK AHAHA WOLOLOLO
        if(h_out_pre && SixteenBaudRate)
       	begin
        	next = SFD;
        	time_up_double = 1;
        	//rst_pre = 1;
       	end

       	//if(time_down) time_down = 0;


       end

       SFD:
       begin
       	next = SFD;
       	time_up = 1;
       	time_sfd_error_up = 1;
       	//cardet = 1;

       	if(((time_count >= 3 && time_count <= 6) || 
       		(time_count <= 4'he && time_count >= 4'hb)) && 
       		SixteenBaudRate)
       	begin
       		enb_bit = 1;
       	end

        if(h_out_bit == 1 && FourthBaudRate && (fourth_count == 0))
          begin
            d_in_sfd = 1; enb_sfd = 1;
            input_check_up = 1;
            fourth_count_up = 1;
            fourth_count_reset = 0;
          end
        if(l_out_bit == 1 && FourthBaudRate && (fourth_count == 0)) 
          begin
            d_in_sfd = 0; enb_sfd = 1;
            input_check_up = 1;
            fourth_count_up = 1;
            fourth_count_reset = 0;
          end


        if(fourth_count != 0)
        	fourth_count_up = 1;


        if(h_out_sfd && SixteenBaudRate)
        begin
        	next = RECEIVE;
        	time_up_double = 1;
        	//rst_sfd = 1;
        end

        if(time_count_sfd_error == 5'd30)
        begin
        	next = PREAMBLE;
       		reset_time_count = 1;
       		reset_bit_count = 1;

       		rst_pre = 1;
       		rst_sfd = 1;
       		rst_bit = 1;

       		fourth_count_reset = 1;
        end

    //    if((time_count % 2 == 1) && SixteenBaudRate)
	   // begin
	       
	   //     enb_eof = 1;
	               
	   // end

       end

       RECEIVE:
       begin
       	next = RECEIVE;
       	time_up = 1;
       	//cardet = 1;

       	if(((time_count >= 3 && time_count <= 6) || 
       		(time_count <= 4'he && time_count >= 4'hb)) && 
       		SixteenBaudRate)
       	begin
       		enb_bit = 1;
       	end

       if((time_count % 2 == 1) && SixteenBaudRate)
	   begin
	       
	       enb_eof = 1;
	               
	   end

        if(h_out_bit == 1 && FourthBaudRate && (fourth_count == 0))
          begin
            //enable_data = 1;
            bit_up = 1;

            input_check_up = 1;
            fourth_count_up = 1;
            fourth_count_reset = 0;            
          end
        if(l_out_bit == 1 && FourthBaudRate && (fourth_count == 0)) 
          begin
            //enable_data = 1;
            bit_up = 1;

            input_check_up = 1;
            fourth_count_up = 1;
            fourth_count_reset = 0;            
          end

        if(fourth_count == 1 && FourthBaudRate)
        	enable_data = 1;

        if(fourth_count != 0)
        	fourth_count_up = 1;          

        if(bit_count == 0)
        begin
        	if(check_first_byte && BaudRate)
        		write = 1;
        end

        if(~check_first_byte && bit_count == 7)
        	check_first_byte_up = 1;

        if(h_out_eof == 1)
        begin
            next = EOF;
        end

        // if(l_out_eof == 1)
        // begin
        //     next = PREAMBLE;
       	// 	reset_time_count = 1;
       	// 	reset_bit_count = 1;

       	// 	rst_pre = 1;
       	// 	rst_sfd = 1;
       	// 	rst_bit = 1;

       	// 	fourth_count_reset = 1;
        // end


        if(~h_out_bit && ~l_out_bit)
        	time_empty_up = 1;

        if(time_count_empty == 4'b1111)
        begin
        	next = PREAMBLE;
       		reset_time_count = 1;
       		reset_bit_count = 1;

       		rst_pre = 1;
       		rst_sfd = 1;
       		rst_bit = 1;

       		fourth_count_reset = 1;
        end

       end

       EOF:
       begin
       	next = EOF;
       	time_up = 1;

       	enb_eof = 1;

       	//cardet = 1;

       	if(~h_out_eof)
       	begin
       		next = PREAMBLE;
       		reset_time_count = 1;
       		reset_bit_count = 1;

       		rst_pre = 1;
       		rst_sfd = 1;
       		rst_bit = 1;

       		fourth_count_reset = 1;
       	end

       end

       default:
       begin
       	next = PREAMBLE;
       		reset_time_count = 1;
       		reset_bit_count = 1;

       		rst_pre = 1;
       		rst_sfd = 1;
       		rst_bit = 1;

       		fourth_count_reset = 1;

       end
   endcase
end


endmodule
