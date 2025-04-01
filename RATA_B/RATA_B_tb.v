`timescale 1ns / 1ps // Defining the time scale

module RATA_B_tb;

    //Inputs
    reg Mod_Mem_LMT; // Signal for modification in LMT
    reg Mod_Mem_AR; // Signal for modification in AR
    reg [1:0] PC;
    
    //Outputs
    wire UP_LMT;
    wire reset;

    wire [2:0] current_state;
    
    // RATA_B instance
    RATA_B uut (
        .Mod_Mem_LMT(Mod_Mem_LMT),
        .Mod_Mem_AR(Mod_Mem_AR),
        .PC(PC),
        .UP_LMT(UP_LMT),
        .current_state(current_state),
        .reset(reset)
    );

    // Monitor state transitions
    initial begin
        $monitor("Time: %0t | State: %b | Mod_Mem_AR: %b | Mod_Mem_LMT: %b | UP_LMT: %b | Reset: %b | PC: %0h ", $time, current_state, Mod_Mem_AR, Mod_Mem_LMT, UP_LMT, reset, PC);
    end
    
    // Testbench
    initial begin
        
        // Test 1: Modification in LMT (expected: NOT MOD -> RESET -> MOD)
        $display("Test 1: LMT Modification attempt from NotMOD + going back to MOD");
        //Initialization 
        Mod_Mem_LMT = 0;
        Mod_Mem_AR = 0;
        PC = 2'b00; // PC starting value
        #10;        // wait 10ns

        //Start test
        Mod_Mem_LMT = 1;  // Simulating a modification in LMT
        PC = 2'b01;
        #10;
        Mod_Mem_LMT = 0;
        #10;
        PC = 2'b00; //Setting PC to 0 to go back to MOD 
        #10;

        //Test 2: Simulating successful authentication during Attest computation (expected: MOD -> UPDATE)
        $display("Test 2: Simulating successful authentication during Attest computation");
        PC = 2'b01;
        #10;
        PC = 2'b10; //PC is equal to CR_auth
        #10;

        //Test 3: After executing the CR_auth instruction (expected: UPDATE -> ATTEST)
        $display("Test 3: After executing the CR_auth instruction ");
        $monitor("Time: %0t | State: %b | Mod_Mem_AR: %b | Mod_Mem_LMT: %b | UP_LMT: %b | Reset: %b | PC: %0h ", $time, current_state, Mod_Mem_AR, Mod_Mem_LMT, UP_LMT, reset, PC);
        #10;
        PC = 2'b00; //Pc is unequal to CR_auth
        #10;

        //Test 4: Simulating completed attest (expected: ATTEST -> NOTMOD)
        $display("Test 4: Simulating completed attest");
        PC = 2'b01; 
        #10;
        PC = 2'b11; // PC is equal to CR_max
        #10;

        //Test 5: Simulating a modification of AR (expected: NOTMOD -> MOD)
        $display("Test 5: Simulating a modification in AR");
        $monitor("Time: %0t | State: %b | Mod_Mem_AR: %b | Mod_Mem_LMT: %b | UP_LMT: %b | Reset: %b | PC: %0h ", $time, current_state, Mod_Mem_AR, Mod_Mem_LMT, UP_LMT, reset, PC);
        #10;
        Mod_Mem_AR = 1; //Simulating a modification in AR
        #10;
        Mod_Mem_AR = 0;
        //Test 6: Simulating a modification of AR (expected: MOD -> RESET)
        $display("Test 6: Simulating a modification in LMT from MOD + stays in RESET");
        $monitor("Time: %0t | State: %b | Mod_Mem_AR: %b | Mod_Mem_LMT: %b | UP_LMT: %b | Reset: %b | PC: %0h ", $time, current_state, Mod_Mem_AR, Mod_Mem_LMT, UP_LMT, reset, PC);
        #10;
        Mod_Mem_LMT = 1; //Simulating a modification in LMT
        #10;
        Mod_Mem_LMT = 0;
        #10;
        
        $finish; //Stopping the simulation
    end
    
    
    
endmodule