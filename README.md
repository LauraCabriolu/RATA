# Final_project
Final project Cyberphysical and IOT Security 
# How to run
Run `iverilog -o RATA_A_tb RATA_A.v RATA_A_tb.v` to compile verilog file and testbench. <br/><br/>
To run testbench: `vvp RATA_A_tb`. <br/><br/>
Install [NuSMV 2.7.0](https://nusmv.fbk.eu/) and then run `nusmv -int RATA_A.smv`, then `go` and lastly `check_property` to verify the LTL specifications.
