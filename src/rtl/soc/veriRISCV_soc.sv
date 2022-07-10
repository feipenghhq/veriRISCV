// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/28/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// A simple SoC for the cpu design
// ------------------------------------------------------------------------------------------------

`include "core.svh"
`include "veriRISCV_soc.svh"

module veriRISCV_soc (
    input           clk,
    input           rst
);

    avalon_req_t    ibus_avalon_req;
    avalon_resp_t   ibus_avalon_resp;

    avalon_req_t    dbus_avalon_req;
    avalon_resp_t   dbus_avalon_resp;

    logic           software_interrupt;
    logic           timer_interrupt;
    logic           external_interrupt;
    logic           debug_interrupt;

    // debug bus
    logic           debug_avn_read;
    logic           debug_avn_write;
    logic [31:0]    debug_avn_address;
    logic [3:0]     debug_avn_byte_enable;
    logic [31:0]    debug_avn_writedata;
    logic  [31:0]   debug_avn_readdata;
    logic           debug_avn_waitrequest;

    // instruction bus
    logic           ibus_avn_read;
    logic           ibus_avn_write;
    logic [31:0]    ibus_avn_address;
    logic [3:0]     ibus_avn_byte_enable;
    logic [31:0]    ibus_avn_writedata;
    logic  [31:0]   ibus_avn_readdata;
    logic           ibus_avn_waitrequest;

    // data bus
    logic           dbus_avn_read;
    logic           dbus_avn_write;
    logic [31:0]    dbus_avn_address;
    logic [3:0]     dbus_avn_byte_enable;
    logic [31:0]    dbus_avn_writedata;
    logic  [31:0]   dbus_avn_readdata;
    logic           dbus_avn_waitrequest;

    // main memory (sram) port
    logic           ram_avn_read;
    logic           ram_avn_write;
    logic  [31:0]   ram_avn_address;
    logic  [3:0]    ram_avn_byte_enable;
    logic  [31:0]   ram_avn_writedata;
    logic [31:0]    ram_avn_readdata;
    logic           ram_avn_waitrequest;

    // AON domain
    logic           aon_avn_read;
    logic           aon_avn_write;
    logic  [31:0]   aon_avn_address;
    logic  [3:0]    aon_avn_byte_enable;
    logic  [31:0]   aon_avn_writedata;
    logic [31:0]    aon_avn_readdata;
    logic           aon_avn_waitrequest;

    // GPIO0
    logic           gpio0_avn_read;
    logic           gpio0_avn_write;
    logic  [31:0]   gpio0_avn_address;
    logic  [3:0]    gpio0_avn_byte_enable;
    logic  [31:0]   gpio0_avn_writedata;
    logic [31:0]    gpio0_avn_readdata;
    logic           gpio0_avn_waitrequest;

    // GPIO1
    logic           gpio1_avn_read;
    logic           gpio1_avn_write;
    logic  [31:0]   gpio1_avn_address;
    logic  [3:0]    gpio1_avn_byte_enable;
    logic  [31:0]   gpio1_avn_writedata;
    logic [31:0]    gpio1_avn_readdata;
    logic           gpio1_avn_waitrequest;

    // UART
    logic           uart0_avn_read;
    logic           uart0_avn_write;
    logic  [31:0]   uart0_avn_address;
    logic  [3:0]    uart0_avn_byte_enable;
    logic  [31:0]   uart0_avn_writedata;
    logic [31:0]    uart0_avn_readdata;
    logic           uart0_avn_waitrequest;


    // -------------------------------
    // veriRISCV Core
    // --------------------------------
    veriRISCV_core u_veriRISCV_core(
        .clk,
        .rst,
        .ibus_avalon_req,
        .ibus_avalon_resp,
        .dbus_avalon_req,
        .dbus_avalon_resp,
        .software_interrupt,
        .timer_interrupt,
        .external_interrupt,
        .debug_interrupt
    );


    // ----------------------------------------
    //  avalon bus
    // ----------------------------------------

    veriRISCV_avalon_bus u_veriRISCV_avalon_bus (.*);

    // ----------------------------------------
    //  SoC Component
    // ----------------------------------------

    // debug bus
    assign debug_avn_read = 0;
    assign debug_avn_write = 0;
    assign debug_avn_address = 0;
    assign debug_avn_byte_enable = 0;
    assign debug_avn_writedata = 0;


    // instruction bus
    assign ibus_avn_read = ibus_avalon_req.read;
    assign ibus_avn_write = ibus_avalon_req.write;
    assign ibus_avn_address = ibus_avalon_req.address;
    assign ibus_avn_byte_enable = ibus_avalon_req.byte_enable;
    assign ibus_avn_writedata = ibus_avalon_req.writedata;
    assign ibus_avalon_resp.readdata = ibus_avn_readdata;
    assign ibus_avalon_resp.waitrequest = ibus_avn_waitrequest;

    // data bus
    assign dbus_avn_read = dbus_avalon_req.read;
    assign dbus_avn_write = dbus_avalon_req.write;
    assign dbus_avn_address = dbus_avalon_req.address;
    assign dbus_avn_byte_enable = dbus_avalon_req.byte_enable;
    assign dbus_avn_writedata = dbus_avalon_req.writedata;
    assign dbus_avalon_resp.readdata = dbus_avn_readdata;
    assign dbus_avalon_resp.waitrequest = dbus_avn_waitrequest;

    // AON domain
    assign aon_avn_readdata = 0;
    assign aon_avn_waitrequest = 0;

    // GPIO0
    assign gpio0_avn_readdata = 0;
    assign gpio0_avn_waitrequest = 0;

    // GPIO1
    assign gpio1_avn_readdata = 0;
    assign gpio1_avn_waitrequest = 0;

    // UART
    assign uart0_avn_readdata = 0;
    assign uart0_avn_waitrequest = 0;

    // SRAM
    // use FPGA internal ram for now. will switch to sram later.
    localparam MAIN_MEMORY_AW = 20;
    avalon_ram_1rw
    #(
        .AW       (MAIN_MEMORY_AW-2),
        .DW       (32)
    )
    u_memory(
        .clk         (clk),
        .read        (ram_avn_read),
        .write       (ram_avn_write),
        .address     (ram_avn_address[MAIN_MEMORY_AW-1:2]),
        .byte_enable (ram_avn_byte_enable),
        .writedata   (ram_avn_writedata),
        .readdata    (ram_avn_readdata),
        .waitrequest (ram_avn_waitrequest)
    );



endmodule
