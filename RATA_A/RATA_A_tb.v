`timescale 1ns / 1ps  // Defining the time scale

module RATA_A_tb;

    // Inputs
    reg clk;                // Clock signal 
    reg start_signal;       // To initialize the system before the tests
    reg Mod_Mem_AR;         // Signal for modification in AR
    reg Mod_Mem_LMT;        // Signal for modification in LMT
    reg [31:0] PC;          // Program Counter

    // Outputs
    wire setLMT;            // To control the value of LMT reserved memory (Must be 1 whenever state is MOD)
    wire reset;             // To reset the system (Must be 1 whenever state is RESET)
 
     

    // RATA_A instance
    RATA_A uut (
        .clk(clk),
        .start_signal(start_signal),
        .Mod_Mem_AR(Mod_Mem_AR),
        .Mod_Mem_LMT(Mod_Mem_LMT),
        .setLMT(setLMT),
        .reset(reset),
        .PC(PC)
    );

    // Generating the clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock with 10 time units period (5 ns for semi period)
    end


    // Monitoring state transitions
    initial begin
        $monitor("Time: %0t | State: %b | Mod_Mem_AR: %b | Mod_Mem_LMT: %b | setLMT: %b | reset: %b | pc: %0h",
                 $time, uut.current_state, Mod_Mem_AR, Mod_Mem_LMT, setLMT, reset, PC);
    end

    // Testbench
    initial begin
        // Test 1: Modification in AR (expected: NOT MOD -> MOD -> NOT MOD)
        $display("Test 1: Modification in AR");
        //Initialization 
        start_signal = 1;
        Mod_Mem_AR = 0;
        Mod_Mem_LMT = 0;
        PC = 32'h1003;     // PC starting value
        #10;               // wait 10ns
        start_signal = 0;
        #10;

        //Start test
        Mod_Mem_AR = 1;    // Simulating a modification in AR
        #10;
        Mod_Mem_AR = 0;
        #10;

    
        // Test 2: LMT modification attempt (expected: NOT MOD -> RESET -> MOD)
        $display("Test 2: LMT modification attempt + going back to MOD");
        //Initialization 
        start_signal = 1;
        Mod_Mem_AR = 0;
        Mod_Mem_LMT = 0;
        PC = 32'h1002;
        #10; 
        start_signal = 0;
        #10;

        //Start test
        Mod_Mem_LMT = 1;   // Simulating a modification attempt in LMT
        #10;
        Mod_Mem_LMT = 0;
        #10;
        PC = 32'h0500;
        #10;
        PC = 32'h0000;     //Setting PC to 0 to go back to MOD 
        #10;

        // Test 3: LMT modification attempt (MOD -> RESET)
        $display("Test 3: LMT modification attempt ");
        //Initialization 
        start_signal = 1; 
        Mod_Mem_AR = 0;
        Mod_Mem_LMT = 0;
        PC = 32'h1001;
        #10;
        start_signal = 0;
        #10;

        //Start test
        Mod_Mem_LMT = 1;   // Simulating a modification attempt in LMT
        #10;
        Mod_Mem_LMT = 0;
        #10;
        

        $finish; //Stopping the simulation          
    end

endmodule