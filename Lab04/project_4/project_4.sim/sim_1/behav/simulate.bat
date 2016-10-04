@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim NexysTest_behav -key {Behavioral:sim_1:Functional:NexysTest} -tclbatch NexysTest.tcl -view C:/Users/dilsizk/Desktop/ece491/ece491labs/Lab04/project_4/ReceiverTest_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
