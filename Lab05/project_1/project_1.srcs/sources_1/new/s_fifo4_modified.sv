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

// 4 entry deep fast fifo

module p_fifo4(
    input logic    clk, rst, clr,
    input logic    [LENGTH-1:0]	din,
    input logic    we, re, 
    output logic  [LENGTH-1:0]	dout,
    output logic   full, empty
);
////////////////////////////////////////////////////////////////////
//parametrized module
   parameter LENGTH = 8;
   parameter W = 8;
   parameter R = 8;
   
// Local Wires
    logic       [LENGTH-5:0]	mem[0:3];
    logic       [W-7:0]     wp;
    logic       [R-7:0]     rp;
    logic       [W-7:0]     wp_p1;
    logic       [W-7:0]     wp_p2;
    logic       [R-7:0]     rp_p1;
    logic       [R-7:0]     rp_p2;  //added to tackle case of reading empty fifo
    logic		            gb;
////////////////////////////////////////////////////////////////////
// Misc Logic
always @(posedge clk or negedge rst)
        if(!rst)	wp <= #1 2'h0;
        else
        if(clr)		wp <= #1 2'h0;
        else
        if(we)		wp <= #1 wp_p1;

assign wp_p1 = wp + 2'h1;
assign wp_p2 = wp + 2'h2;

always @(posedge clk or negedge rst)
        if(!rst)	rp <= #1 2'h0;
        else
        if(clr)		rp <= #1 2'h0;
        else
        if(re & ~empty)		rp <= #1 rp_p1;
        else
        if(re & empty)      rp <= #1 rp_p2;

assign rp_p1 = rp + 2'h1;
assign rp_p2 = rp + 2'h0;   //for case of reading empty fifo, the read pointer remains at previous rp
                            //contrary to how in the original fifo, the pointer moves to the next address

// Fifo Output
assign  dout = mem[ rp ];

// Fifo Input 
always @(posedge clk)
        if(we & full)     mem[ wp ] <= #1 mem[ wp ];    //Idiot-proofing here to add conditions to prevent overwriting of data when an additional
        else if(we & ~full)  mem[wp] <= #1 din;         //value to the capacity is added. 
        
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


