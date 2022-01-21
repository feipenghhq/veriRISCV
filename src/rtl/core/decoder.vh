///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: decoder.vh
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// Define file for decoder.
// - Instruction set related macro to decode the instruction
//
///////////////////////////////////////////////////////////////////////////////////////////////////


`ifndef _DECODER_VH_
`define _DECODER_VH_

// Instruction Field
`define DEC_OPCODE_FIELD    6:0
`define DEC_RD_FIELD        11:7
`define DEC_FUNC3_FIELD     14:12
`define DEC_RS1_FIELD       19:15
`define DEC_RS2_FIELD       24:20
`define DEC_FUNC7_FIELD     31:25

// Instruction Field Range
`define DEC_OPCODE_RANGE    6:0
`define DEC_RD_RANGE        4:0
`define DEC_FUNC3_RANGE     2:0
`define DEC_RS1_RANGE       4:0
`define DEC_RS2_RANGE       4:0
`define DEC_FUNC7_RANGE     6:0


// Instruction Type
`define DEC_TYPE_LOGIC      7'b0110011
`define DEC_TYPE_ILOGIC     7'b0010011

// Logid Instruction Func3
`define DEC_LOGIC_ADD       3'b000
`define DEC_LOGIC_SUB       3'b000
`define DEC_LOGIC_SLL       3'b001
`define DEC_LOGIC_SLT       3'b010
`define DEC_LOGIC_SLTU      3'b011
`define DEC_LOGIC_XOR       3'b100
`define DEC_LOGIC_SRL       3'b101
`define DEC_LOGIC_SRA       3'b101
`define DEC_LOGIC_OR        3'b110
`define DEC_LOGIC_AND       3'b111
`endif