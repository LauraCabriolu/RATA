`timescale 1ns / 1ps

module RATA_B (
    input wire Mod_Mem_LMT, // Signal for modification in LMT
    input wire Mod_Mem_AR, // Signal for modification in AR
    input wire [1:0] PC, // Program Counter
    output reg UP_LMT, // To control the value of LMT reserved memory
    output reg reset, // To reset the system 
    output reg [2:0] current_state
);

// States
parameter NotMOD = 3'b000, 
          MOD =   3'b001, 
          RESET = 3'b010, 
          ATTEST = 3'b011, 
          UPDATE = 3'b100;

// PC Conditions
parameter CR_auth = 2'b10; //The first instruction that is executed after successful authentication
parameter CR_max  = 2'b11; //When PC is equal to CR_max it means that attest is completed

initial begin  //Initializing the system
    current_state = NotMOD;
    UP_LMT = 0;
    reset = 0;
end


always @(*) begin

    //Whenever the is a modification attempt in LMT, reset must be set to 1
    if(Mod_Mem_LMT)
        reset = 1;
    else 
        reset = 0;


    //If the FSM is switching to UPDATE, PC will be CR_auth in the next state, except when there is a modification in LMT or AR
    if (!Mod_Mem_AR) begin
        if (PC == CR_auth && (current_state == MOD || current_state == ATTEST || current_state == UPDATE) && !Mod_Mem_LMT)
            UP_LMT = 1;
        else
            UP_LMT = 0;
    end
    // Whenever there is an AR memory modification attempt while not being in RESET state and "PC" is CR_auth, the system switches to UPDATE state
    else if(Mod_Mem_AR && PC == CR_auth && !reset) 
        UP_LMT = 1;
    else 
        UP_LMT = 0;


    case (current_state)
        RESET: begin
            reset = 1;
            if (PC == 2'b00 && !Mod_Mem_LMT) begin // The system is able to exit reset state only if PC is 0 and Mod_Mem_LMT is false
                current_state = MOD; 
                reset = 0;
            end
            else begin
                current_state = RESET;
            end
        end
        
        MOD: begin
            if (Mod_Mem_LMT) begin  //Whenever there is a modification attempt of the LMT memory, the system gets into reset state
                current_state = RESET;
            end
            else if (PC == CR_auth) begin // Switching to update state when PC is equal to CR_auth
                current_state = UPDATE;
            end 
            else begin
                current_state = MOD;
            end
        end
        
        UPDATE: begin
            if (Mod_Mem_LMT) begin  //Whenever there is a modification attempt of the LMT memory, the system gets into reset state
                current_state = RESET;
            end
            else if(Mod_Mem_AR && PC != CR_auth) begin  // Switching to MOD state from UPDATE only if PC is not CR_auth
                current_state = MOD;
            end
            else if (PC != CR_auth) begin  // When AR memory is not being modified and UPDATE is completed, the system switches to ATTEST state
                current_state = ATTEST;
            end
            else begin
                current_state = UPDATE;
            end
        end
        
        ATTEST: begin 
            if (Mod_Mem_LMT) begin  // Whenever there is a modification attempt of the LMT memory, the system gets into reset state
                current_state = RESET;
            end
            else if (Mod_Mem_AR) begin // Switching to MOD state when AR memory gets modified
                current_state = MOD;
            end
            else if (PC == CR_max) begin // Switching to NotMOD from attest when PC reaches CR_max, completing the attest
                current_state = NotMOD;
            end
            else if (PC == CR_auth) begin // Switching to update state when PC is equal to CR_auth
                current_state = UPDATE;
            end
            else begin
                current_state = ATTEST;
            end
        end
        
        NotMOD: begin
            if (Mod_Mem_LMT) begin   // Whenever there is a modification attempt of the LMT memory, the system gets into reset state
                current_state = RESET;
            end
            else if (Mod_Mem_AR) begin // Switching to MOD state when AR memory gets modified
                current_state = MOD;
            end
            else begin
                current_state = NotMOD;
            end
        end
        
    endcase
    
end

endmodule
