///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: decoder
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// decoder
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"
`include "decoder.vh"

module decoder (

    input [`DATA_RANGE]     instruction,

    // register interface
    output reg              reg_wen,
    output [`RF_RANGE]      reg_waddr,
    output [`RF_RANGE]      reg_rs1_addr,
    output [`RF_RANGE]      reg_rs2_addr,

    // datapath control signal
    output reg [`CORE_ALU_OP_RANGE] alu_op,

    // exception
    output reg ill_instr         // Illegal instruction
);

    /////////////////////////////////
    // Signal Declaration
    /////////////////////////////////

    wire [`DEC_OPCODE_RANGE] opcode;
    wire [`DEC_FUNC7_RANGE] func7;
    wire [`DEC_FUNC3_RANGE] func3;

    /////////////////////////////////

    /////////////////////////////////
    // Extract instruction field
    /////////////////////////////////
    assign reg_waddr = instruction[`DEC_RD_FIELD];
    assign reg_rs1_addr = instruction[`DEC_RS1_FIELD];
    assign reg_rs2_addr = instruction[`DEC_RS2_FIELD];

    assign opcode = instruction[`DEC_OPCODE_FIELD];
    assign func7 = instruction[`DEC_FUNC7_FIELD];
    assign func3 = instruction[`DEC_FUNC3_FIELD];

    /////////////////////////////////
    // Decode logic
    /////////////////////////////////

    always @(*) begin
        // Default value
        ill_instr = 1'b0;
        alu_op = `CORE_ALU_ADD;
        reg_wen = 1'b0;

        // LEVEL 1 - opcode
        case(opcode) // {
            `DEC_TYPE_LOGIC: begin  // { Logic Type instruction
                reg_wen = 1'b1;
                // To simplifiy the decode logic, here we use the same encoding with the instruction func3 field
                // For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the forth bit to distinguesh them.
                // Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to 1
                alu_op[2:0] = func3;
                alu_op[3] = func7[5];
            end

        default: ill_instr = 1'b1;
        endcase // }
    end

endmodule