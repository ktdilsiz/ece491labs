`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FIFO 4 entries deep                                        ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/sasc/      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: sasc_fifo4.v,v 1.1.1.1 2002/09/16 16:16:41 rudi Exp $
//
//  $Date: 2002/09/16 16:16:41 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: sasc_fifo4.v,v $
//               Revision 1.1.1.1  2002/09/16 16:16:41  rudi
//               Initial Checkin
//`include "timescale.v"


module p_fifo4(
 input logic    clk, rst, clr,
 input logic    we, re, 
 input logic    [7:0]	din,
 output logic   full, empty,
 output logic  [7:0]	dout

);

////////////////////////////////////////////////////////////////////
   //parametrized module
parameter numBits = 64;
parameter DIVBITS = $clog2(numBits);

////////////////////////////////////////////////////////////////////
//
// Local Wires
logic   [7:0] mem[0:numBits-1];
logic   [DIVBITS-1:0]   wp;
logic   [DIVBITS-1:0]   rp;
logic   [DIVBITS-1:0]   wp_p1;
logic   [DIVBITS-1:0]   wp_p2;
logic   [DIVBITS-1:0]   rp_p1;
logic   gb;

////////////////////////////////////////////////////////////////////

// Misc Logic
always @(posedge clk or negedge rst)        //do not change the clk to baudrate, use clk. It just acts like a buffer, so i increased the size to accomodate the the biggest possible data bytes we could get
        if(!rst)	wp <= #1 2'h0;
        else
        if(clr)		wp <= #1 2'h0;
        else
        if(we)		
            begin
                if(full == 1)
                    begin
                    wp <= wp;
                    end
                else
                    begin
                    wp <= #1 wp_p1;
                    end
            end

assign wp_p1 = (wp_p1 == numBits) ? 2'h0 : wp + 2'h1;
assign wp_p2 = (wp_p2 == numBits) ? 2'h0 : wp + 2'h2;

always @(posedge clk or negedge rst)
        if(!rst)	rp <= #1 2'h0;
        else
        if(clr)		rp <= #1 2'h0;
        else
        if(re)
            begin
                if(empty == 1)
                begin
                    rp <= rp;
                end
                else
                begin
                    rp <= #1 rp_p1;
                end
            end
        

assign rp_p1 = (rp_p1 == numBits) ? 2'h0 : rp + 2'h1;

// Fifo Output
assign  dout = (rp == 0)? mem[numBits - 1] : mem[ rp - 1 ];

// Fifo Input 
always @(posedge clk)
        if(we)
            begin
                if(full == 0)
                begin
                    mem[ wp ] <= #1 din;
                end
            end

        
// Status
assign empty = (wp == rp) & !gb;
assign full  = (wp == rp) &  gb;

// Guard Bit ...
always @(posedge clk)
	if(!rst)			gb <= #1 1'b0;
	else
	if(clr)				gb <= #1 1'b0;
	else
	if((wp_p1 == rp) & we)		gb <= #1 1'b1;
	else
	if(re)				gb <= #1 1'b0;

endmodule


