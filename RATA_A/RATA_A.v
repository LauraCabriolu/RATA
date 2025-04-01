module RATA_A (
    input clk,               // Clock signal
    input start_signal,
    input wire [31:0] PC,    //Program Counter
    input wire Mod_Mem_AR,   // Signal for modification in AR
    input wire Mod_Mem_LMT,  // Signal for modification in LMT
    output reg reset,        // To reset the system 
    output reg setLMT        // To control the value of LMT reserved memory        
);


parameter NotMOD = 2'b00, MOD = 2'b01, RESET = 2'b10; //States
reg [1:0] current_state;   


always @(*) begin

    //Initializing the system
    if (start_signal) begin 
        current_state = NotMOD; 
        setLMT = 0;
        reset = 0;
    end

    //Whenever the is a modification attempt in LMT, reset must be set to 1
    if(Mod_Mem_LMT)
        reset = 1;
    else
        reset = 0;  

    //If AR is being modified setLMT must be set to 1
    if(Mod_Mem_AR)
        setLMT = 1;
    else   
        setLMT = 0;

    //State transition logic
    if (Mod_Mem_LMT) //Whatever the state is, if a modification attempt occurs in LMT the system must be reset
        current_state = RESET;
    else if(current_state == MOD && !Mod_Mem_AR && !Mod_Mem_LMT) //If there is no modification
        current_state = NotMOD;
    //If the AR memory is getting modified and the current state is NotMod then the sysyem must switch to the MOD state
    else if(current_state == NotMOD && Mod_Mem_AR && !Mod_Mem_LMT) 
        current_state = MOD;
    else if(current_state == RESET && !Mod_Mem_LMT && PC == 32'b0) //Exits the reset state after resetting the system
        current_state = MOD;
    
end

endmodule
