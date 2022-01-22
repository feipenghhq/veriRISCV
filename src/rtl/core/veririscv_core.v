///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: veririscv_core
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// veririscv core top level
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module veririscv_core (
    input   clk,
    input   rst,
    `ifdef COCOTB_SIM
    input   rstn,
    `endif
    // AHBLite Interface to Instruction RAM
    output                  ibus_hwrite,
    output [2:0]            ibus_hsize,
    output [2:0]            ibus_hburst,
    output [3:0]            ibus_hport,
    output [1:0]            ibus_htrans,
    output                  ibus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]  ibus_haddr,
    output [`DATA_RANGE]    ibus_hwdata,
    input                   ibus_hready,
    input                   ibus_hresp,
    input  [`DATA_RANGE]    ibus_hrdata,

    // AHBLite Interface to memory/data bus
    output                          dbus_hwrite,
    output reg [2:0]                dbus_hsize,
    output [2:0]                    dbus_hburst,
    output [3:0]                    dbus_hport,
    output [1:0]                    dbus_htrans,
    output                          dbus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]  dbus_haddr,
    output reg [`DATA_RANGE]        dbus_hwdata,
    input                           dbus_hready,
    input                           dbus_hresp,
    input  [`DATA_RANGE]            dbus_hrdata
);

    /////////////////////////////////
    // Signal Declaration
    /////////////////////////////////

    /*AUTOREG*/

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire                mem_rd;                 // From lsu of lsu.v
    // End of automatics

    // IF stage
    wire [`DATA_RANGE]    if2id_instruction;
    wire [`PC_RANGE]      if2id_pc;
    wire [`PC_RANGE]      pc_out;

    // ID stage
    wire [`CORE_ALU_OP_RANGE] id2ex_alu_op;
    wire                id2ex_ill_instr;
    wire [`DATA_RANGE]  id2ex_reg_rs1_data;
    wire [`DATA_RANGE]  id2ex_reg_rs2_data;
    wire [`RF_RANGE]    id2ex_reg_waddr;
    wire                id2ex_reg_wen;
    wire [`IMM_RANGE]   id2ex_imm_value;
    wire                id2ex_rs1_forward_from_mem;
    wire                id2ex_rs1_forward_from_wb;
    wire                id2ex_rs2_forward_from_mem;
    wire                id2ex_rs2_forward_from_wb;
    wire                id2ex_sel_imm;
    wire [`CORE_MEM_RD_OP_RENGE] id2ex_mem_rd_op;
    wire [`CORE_MEM_WR_OP_RENGE] id2ex_mem_wr_op;

    // EX stage
    wire [`DATA_RANGE]  ex2mem_alu_out;
    wire                ex2mem_ill_instr;
    wire [`RF_RANGE]    ex2mem_reg_waddr;
    wire                ex2mem_reg_wen;
    wire                ex2mem_mem_rd;

    // MEM stage
    wire [`DATA_RANGE]  mem2wb_reg_wdata;
    wire                mem2wb_ill_instr;
    wire [`RF_RANGE]    mem2wb_reg_waddr;
    wire                mem2wb_reg_wen;

    // WB stage
    wire [`RF_RANGE]    wb_reg_waddr;
    wire [`DATA_RANGE]  wb_reg_wdata;
    wire                wb_reg_wen;

    // LSU
    wire [`DATA_RANGE]  lsu_addr;
    wire [`DATA_RANGE]  lsu_rdata;
    wire [`DATA_RANGE]  lsu_wdata;

    /////////////////////////////////

    /////////////////////////////////
    // IF stage
    /////////////////////////////////
    IF
    IF (/*AUTOINST*/
        // Outputs
        .ibus_hwrite                    (ibus_hwrite),
        .ibus_hsize                     (ibus_hsize[2:0]),
        .ibus_hburst                    (ibus_hburst[2:0]),
        .ibus_hport                     (ibus_hport[3:0]),
        .ibus_htrans                    (ibus_htrans[1:0]),
        .ibus_hmastlock                 (ibus_hmastlock),
        .ibus_haddr                     (ibus_haddr[`INSTR_RAM_ADDR_RANGE]),
        .ibus_hwdata                    (ibus_hwdata[`DATA_RANGE]),
        .if2id_pc                       (if2id_pc[`PC_RANGE]),
        .if2id_instruction              (if2id_instruction[`DATA_RANGE]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .ibus_hready                    (ibus_hready),
        .ibus_hresp                     (ibus_hresp),
        .ibus_hrdata                    (ibus_hrdata[`DATA_RANGE]));

    /////////////////////////////////
    // ID stage
    /////////////////////////////////

    /* ID AUTO_TEMPLATE (
        .reg_\(.*\)     (wb_reg_\1),
        ); */
    ID
    ID (/*AUTOINST*/
        // Outputs
        .id2ex_reg_wen                  (id2ex_reg_wen),
        .id2ex_reg_waddr                (id2ex_reg_waddr[`RF_RANGE]),
        .id2ex_reg_rs1_data             (id2ex_reg_rs1_data[`DATA_RANGE]),
        .id2ex_reg_rs2_data             (id2ex_reg_rs2_data[`DATA_RANGE]),
        .id2ex_imm_value                (id2ex_imm_value[`IMM_RANGE]),
        .id2ex_alu_op                   (id2ex_alu_op[`CORE_ALU_OP_RANGE]),
        .id2ex_mem_rd_op                (id2ex_mem_rd_op[`CORE_MEM_RD_OP_RENGE]),
        .id2ex_mem_wr_op                (id2ex_mem_wr_op[`CORE_MEM_WR_OP_RENGE]),
        .id2ex_sel_imm                  (id2ex_sel_imm),
        .id2ex_rs1_forward_from_mem     (id2ex_rs1_forward_from_mem),
        .id2ex_rs1_forward_from_wb      (id2ex_rs1_forward_from_wb),
        .id2ex_rs2_forward_from_mem     (id2ex_rs2_forward_from_mem),
        .id2ex_rs2_forward_from_wb      (id2ex_rs2_forward_from_wb),
        .id2ex_ill_instr                (id2ex_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .if2id_pc                       (if2id_pc[`PC_RANGE]),
        .if2id_instruction              (if2id_instruction[`DATA_RANGE]),
        .ex2mem_reg_waddr               (ex2mem_reg_waddr[`RF_RANGE]),
        .ex2mem_reg_wen                 (ex2mem_reg_wen),
        .reg_wen                        (wb_reg_wen),            // Templated
        .reg_waddr                      (wb_reg_waddr),          // Templated
        .reg_wdata                      (wb_reg_wdata));          // Templated

    /////////////////////////////////
    // EX stage
    /////////////////////////////////

    /* EX AUTO_TEMPLATE (
        .lsu_mem_rd     (mem_rd),
        ); */
    EX
    EX (/*AUTOINST*/
        // Outputs
        .lsu_addr                       (lsu_addr[`DATA_RANGE]),
        .lsu_wdata                      (lsu_wdata[`DATA_RANGE]),
        .ex2mem_reg_wen                 (ex2mem_reg_wen),
        .ex2mem_reg_waddr               (ex2mem_reg_waddr[`RF_RANGE]),
        .ex2mem_alu_out                 (ex2mem_alu_out[`DATA_RANGE]),
        .ex2mem_mem_rd                  (ex2mem_mem_rd),
        .ex2mem_ill_instr               (ex2mem_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .id2ex_reg_wen                  (id2ex_reg_wen),
        .id2ex_reg_waddr                (id2ex_reg_waddr[`RF_RANGE]),
        .id2ex_reg_rs1_data             (id2ex_reg_rs1_data[`DATA_RANGE]),
        .id2ex_reg_rs2_data             (id2ex_reg_rs2_data[`DATA_RANGE]),
        .id2ex_imm_value                (id2ex_imm_value[`IMM_RANGE]),
        .id2ex_alu_op                   (id2ex_alu_op[`CORE_ALU_OP_RANGE]),
        .id2ex_mem_rd_op                (id2ex_mem_rd_op[`CORE_MEM_RD_OP_RENGE]),
        .id2ex_mem_wr_op                (id2ex_mem_wr_op[`CORE_MEM_WR_OP_RENGE]),
        .id2ex_sel_imm                  (id2ex_sel_imm),
        .id2ex_rs1_forward_from_mem     (id2ex_rs1_forward_from_mem),
        .id2ex_rs1_forward_from_wb      (id2ex_rs1_forward_from_wb),
        .id2ex_rs2_forward_from_mem     (id2ex_rs2_forward_from_mem),
        .id2ex_rs2_forward_from_wb      (id2ex_rs2_forward_from_wb),
        .id2ex_ill_instr                (id2ex_ill_instr),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]),
        .lsu_mem_rd                     (mem_rd));                // Templated

    /////////////////////////////////
    // MEM stage
    /////////////////////////////////

    MEM
    MEW (/*AUTOINST*/
         // Outputs
         .mem2wb_reg_wen                (mem2wb_reg_wen),
         .mem2wb_reg_waddr              (mem2wb_reg_waddr[`RF_RANGE]),
         .mem2wb_reg_wdata              (mem2wb_reg_wdata[`DATA_RANGE]),
         .mem2wb_ill_instr              (mem2wb_ill_instr),
         // Inputs
         .clk                           (clk),
         .rst                           (rst),
         .ex2mem_reg_wen                (ex2mem_reg_wen),
         .ex2mem_reg_waddr              (ex2mem_reg_waddr[`RF_RANGE]),
         .ex2mem_alu_out                (ex2mem_alu_out[`DATA_RANGE]),
         .ex2mem_mem_rd                 (ex2mem_mem_rd),
         .ex2mem_ill_instr              (ex2mem_ill_instr),
         .lsu_rdata                     (lsu_rdata[`DATA_RANGE]));

    /////////////////////////////////
    // WB stage
    /////////////////////////////////

    WB
    WB (/*AUTOINST*/
        // Outputs
        .wb_reg_wen                     (wb_reg_wen),
        .wb_reg_waddr                   (wb_reg_waddr[`RF_RANGE]),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .mem2wb_reg_wen                 (mem2wb_reg_wen),
        .mem2wb_reg_waddr               (mem2wb_reg_waddr[`RF_RANGE]),
        .mem2wb_reg_wdata               (mem2wb_reg_wdata[`DATA_RANGE]),
        .mem2wb_ill_instr               (mem2wb_ill_instr));


    /////////////////////////////////
    // LSU
    /////////////////////////////////

    /* lsu AUTO_TEMPLATE (
        .mem_rd_op     (id2ex_mem_rd_op),
        .mem_wr_op     (id2ex_mem_wr_op),
        ); */
    lsu
    lsu (/*AUTOINST*/
         // Outputs
         .lsu_rdata                     (lsu_rdata[`DATA_RANGE]),
         .dbus_hwrite                   (dbus_hwrite),
         .dbus_hsize                    (dbus_hsize[2:0]),
         .dbus_hburst                   (dbus_hburst[2:0]),
         .dbus_hport                    (dbus_hport[3:0]),
         .dbus_htrans                   (dbus_htrans[1:0]),
         .dbus_hmastlock                (dbus_hmastlock),
         .dbus_haddr                    (dbus_haddr[`INSTR_RAM_ADDR_RANGE]),
         .dbus_hwdata                   (dbus_hwdata[`DATA_RANGE]),
         .mem_rd                        (mem_rd),
         // Inputs
         .clk                           (clk),
         .mem_rd_op                     (id2ex_mem_rd_op),       // Templated
         .mem_wr_op                     (id2ex_mem_wr_op),       // Templated
         .lsu_addr                      (lsu_addr[`DATA_RANGE]),
         .lsu_wdata                     (lsu_wdata[`DATA_RANGE]),
         .dbus_hready                   (dbus_hready),
         .dbus_hresp                    (dbus_hresp),
         .dbus_hrdata                   (dbus_hrdata[`DATA_RANGE]));

    /////////////////////////////////
    // Simulation Related
    /////////////////////////////////

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("veririscv_core.vcd");
            $dumpvars (0, veririscv_core);
            #1;
        end
    `endif

endmodule

