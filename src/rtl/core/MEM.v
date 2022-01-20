///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: MEM
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// MEM (Memory stage)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module MEM (
    input   clk,
    input   rst,
    // input from EX/MEM stage pipe
    input                       ex_reg_wen,
    input [`RF_RANGE]           ex_reg_waddr,
    input [`DATA_RANGE]         ex_alu_out,
    input                       ex_ill_instr,
    // pipeline stage
    output reg                  mem_reg_wen,
    output reg [`RF_RANGE]      mem_reg_waddr,
    output reg [`DATA_RANGE]    mem_alu_out,
    output reg                  mem_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            mem_reg_wen <= 1'b0;
            mem_ill_instr <= 1'b0;
        end
        else begin
            mem_reg_wen <= ex_reg_wen;
            mem_ill_instr <= ex_ill_instr;
        end
    end

    always @(posedge clk) begin
        mem_alu_out <= ex_alu_out;
        mem_reg_waddr <= ex_reg_waddr;
    end

    //////////////////////////////
    // Module instantiation
    //////////////////////////////


endmodule