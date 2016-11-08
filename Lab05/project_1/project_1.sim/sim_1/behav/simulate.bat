@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim mx_rcvr_testbench_behav -key {Behavioral:sim_1:Functional:mx_rcvr_testbench} -tclbatch mx_rcvr_testbench.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
