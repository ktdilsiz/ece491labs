//-----------------------------------------------------------------------------
// Title         : debounce -- Button debouncer
// Project       : Lab 7
//-----------------------------------------------------------------------------
// File          : debounce.sv
// Author        : Jon Wallace
// Created       : 15 Oct. 2015
// Last modified : 15 Oct. 2015
//-----------------------------------------------------------------------------
// Description :
// This module provides code to debounce a raw button input.
// Inputs:
//	clk		Clock
//	button_in	Raw button input with bounce
// Outputs:
//	button_out	Debounced button
//	pulse		Provides a one-clock pulse when button is pressed
//-----------------------------------------------------------------------------
module debounce(input logic clk,
		input logic  button_in,
		output logic button_out,
		output logic pulse);

   parameter DEBOUNCE_TIME_MS = 5;
   parameter CLKFREQ = 100_000_000;
   parameter WAIT_COUNT = DEBOUNCE_TIME_MS*(CLKFREQ/1000);
   
   // States for button debouncing
   logic 		     button_state, button_state_next;
   // Counter for debouncing
   logic [26:0] 	     count_reg, count_next;

   // Counter and button state register
   always_ff @(posedge clk)
     begin
	button_state <= button_state_next;
	count_reg <= count_next;
     end

   // Next-state / output logic
   always_comb
     begin
	// Defaults
	button_state_next = button_state;
	count_next = count_reg;
	pulse = 1'b0;
	
	// Does the button input match the stored button state?
	if (button_in == button_state)
	  // Yes, so just reset the counter
	  count_next = 0;
	else if (count_reg == WAIT_COUNT-1)
	  begin
	     // No, so if the counter is done, transition to the other state
	     button_state_next = ~button_state;
	     count_next = 0;
	     // Generate a pulse if going from 0=>1
	     pulse = ~button_state;
	  end
	else
	  // Have not reached wait count yet, so increment counter.
	  count_next = count_reg + 1;
     end // always_comb

   assign button_out = button_state;

endmodule // debounce
