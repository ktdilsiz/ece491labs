//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College
// Engineer: Chris Nadovich <nadovicc@lafayette.edu>
// Project Name: ECE491
// Description: Testbench check() package
//
//   Import this package into your testbench with the line

//     import check_p::*;
//
//    Use these tasks in your testbench to inspect values 
//    and check them against what you expect. 
//
//       check("message", inspected, expected);      // Silent if inspected==expected
//       check_ok("message", inspected, expected);   // Prints OK if inspected==expected
//
//    Use these to bracket several check() tests
//    to summarize the results of that group

//       check_group_begin("message");
//       check_group_end();
//
//    Put this at the end of your testbench to print an overall summary
//
//       check_summary();       // Continues without stopping
//       check_summary_stop();  // Stops execution.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Ported to SystemVerilog by John Nestor
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

package check_p1;
   int error_count = 0;
   int last_error_count = 0;
   int test_count = 0;
   int last_test_count = 0;
   string  saved_message = "";
	
   task check_init;
	 error_count=0;
	 test_count=0;
	 last_error_count=0;
	 last_test_count=0;
	 saved_message = "";
   endtask
   
   // silent on pass
   task check(
	      input string message,
	      input integer inspected,
	      input integer expected
	      );
	 test_count=test_count+1;
	 if (inspected  !== expected) begin 
	    $display ("FAIL(%0s) Failed test %0d at time %0d.", message, test_count, $time); 
	    $display ("  Expected value 0x%0x, Inspected Value 0x%0x", expected, inspected); 
	    error_count = error_count + 1;
	 end 
   endtask

   // prints OK on pass
   task check_ok(input string message,
		 input integer inspected,
		 input integer expected
		 );
	 test_count=test_count+1;
	 if (inspected  !== expected) begin 
	    $display ("FAIL(%0s) Failed test %0d at time %0d.", message, test_count, $time); 
	    $display ("  Expected value 0x%0x, Inspected Value 0x%0x", expected, inspected); 
	    error_count = error_count + 1;
	 end
     else
       $display("OK: %0s", message);			
   endtask
	
   // use the following two tasks to bracket several tests to display a pass fail
   // summary of that section.
   
   task check_group_begin(string message);
	 last_error_count=error_count;
	 last_test_count=test_count;
	 saved_message=message;
	 $display ("START: %0s at time %0d.", message, $time); 
   endtask
   
   task check_group_end;
	 if(last_error_count==error_count)
	   $display ("OK: %0s (%0d tests passed)", saved_message, test_count-last_test_count); 
	 else
	   $display ("FAIL: %0s. (%0d/%0d falures)", saved_message,
		     error_count-last_error_count, test_count-last_test_count); 
   endtask
   
   task check_summary;
	 $display("\nTesbench Complete.");
	 if (error_count > 0) 
	   $display ("ATTENTION: %0d Error(s) in %0d tests", error_count, test_count); 
	 else
	   $display("No errors in %0d tests. :)", test_count);		
   endtask

   task check_summary_stop;
	 check_summary();
	 $stop;
   endtask
   
endpackage