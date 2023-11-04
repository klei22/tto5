   
`timescale 1ns / 1ps
`default_nettype none

module tt_um_tinycore #(parameter MAX_COUNT = 24'd10_000_000)(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output reg  [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output reg  [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path
    input  wire       ena,      // Enable signal
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (active low)
);

    // Define some opcodes for our custom ISA
    localparam [2:0]
        OP_ADD = 3'b000,
        OP_SUB = 3'b001,
        OP_LDI = 3'b010, // Load Immediate
        OP_JMP = 3'b011, // Unconditional Jump
        OP_BEQ = 3'b100, // Branch if Equal
        OP_STR = 3'b101; // Store to output

    // Disable bidirectional IO by setting the output enable to zero
    assign uio_oe = 8'b00000000;

    // Instruction memory: opcode (3 bits) + operand (5 bits)
    reg [7:0] instruction_memory[0:15]; // 16 instructions max for simplicity

    // Initialize instruction memory with some predefined instructions
    initial begin
        instruction_memory[0] = {OP_LDI, 5'b00001}; // Load 1 into ACC
        instruction_memory[1] = {OP_ADD, 5'b00010}; // Add 2 to ACC
        instruction_memory[2] = {OP_SUB, 5'b00001}; // Subtract 1 from ACC
        instruction_memory[3] = {OP_BEQ, 5'b00010}; // Branch to instruction 2 if ACC is zero
        instruction_memory[4] = {OP_STR, 5'b00000}; // Store ACC to output
        instruction_memory[5] = {OP_JMP, 5'b00000}; // Jump to instruction 0
    end

    reg [7:0] acc; // Accumulator for arithmetic operations
    reg [3:0] pc;  // Program Counter
    reg [7:0] instruction_register; // Instruction Register

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the processor state
            pc <= 0;
            acc <= 0;
            uo_out <= 0;
            uio_out <= 0;
        end else if (ena) begin
            // Fetch instruction
            instruction_register <= instruction_memory[pc];

            // Decode instruction
            case (instruction_register[7:5])
                OP_ADD: begin
                    acc <= acc + instruction_register[4:0];
                end
                OP_SUB: begin
                    acc <= acc - instruction_register[4:0];
                end
                OP_LDI: begin
                    acc <= instruction_register[4:0];
                end
                OP_JMP: begin
                    pc <= instruction_register[4:0];
                end
                OP_BEQ: begin
                    if (acc == 0) pc <= instruction_register[4:0];
                    else pc <= pc + 1;
                end
                OP_STR: begin
                    uo_out <= acc;
                    pc <= pc + 1;
                end
                default: begin
                    pc <= pc + 1; // Move to next instruction
                end
            endcase
        end
    end

endmodule
