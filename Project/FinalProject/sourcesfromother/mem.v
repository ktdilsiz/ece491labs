//-----------------------------------------------------------------------------
// Title         : Block Memory Module
// Project       : ECE 491 - Senior Design 1
//-----------------------------------------------------------------------------
// File          : mem.v
// Author        : John Nestor  <nestorj@lafayette.edu>
// Created       : 12.11.2004
// Last modified : 12.11.2004
//-----------------------------------------------------------------------------
// Description :
// This verilog code infers a Xilinx Block RAM with a write port and a read port.
// The write port uses clock clk_a; the read port uses clk_b.
// Note that the address for the read port addr_b must be set before the clock
// edge; new data is available after the clock edge.
//
// This module was based on a template available in the Xilinx ISE software.
// To see templates for other configurations, use the "Edit->Language Templates"
// menu in ISE and select "Synthesis Constructs->Common Functions-Block RAM".
//-----------------------------------------------------------------------------

module mem(clk_a, addr_a, dati_a, we_a, clk_b, addr_b, dato_b);
   parameter RAM_WIDTH = 8;
   parameter RAM_DEPTH = 256;

    input clk_a;
    input [RAM_WIDTH-1:0] addr_a;
    input [RAM_WIDTH-1:0] dati_a;
    input we_a;
    input clk_b;
    input [RAM_WIDTH-1:0] addr_b;
    output [RAM_WIDTH-1:0] dato_b;


   
   reg [RAM_WIDTH-1:0] MEM [RAM_DEPTH-1:0];
   reg [RAM_WIDTH-1:0] addr_b_r; // address register

   always @(posedge clk_a) begin
      if (we_a)
         MEM[addr_a] <= dati_a;
   end

   always @(posedge clk_b)
      addr_b_r <= addr_b;

   assign dato_b = MEM[addr_b_r];   


endmodule
