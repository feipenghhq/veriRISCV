#!/usr/bin/python3
# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/11/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Download the instruction to memory
# ------------------------------------------------------------------------------------------------

import sys
import argparse
import serial
from serial.tools.list_ports import comports

PORT_NAME = {
    "arty": "Digilent USB Device",
    "de2" : "USB-Serial Controller"
}

class UartDownload:

    """ NOTE: Make sure to reset the chip before a new download """

    def __init__(self, port, file, baudrate=115200, logFile='download.log'):
        """
            @param size: instruction rom size in KB
            @param baudrate: uart baudrate
        """
        self.baudrate = baudrate
        self.port = port
        self.file = file
        self.logFile = logFile

    def setupUart(self):
        """ Setup uart port """
        self.serPort = serial.Serial(self.port, self.baudrate)

    def uartWrite(self, data):
        return self.serPort.write(data)

    def startCmd(self):
        cmd = [0x11, 0x11, 0x11, 0x11, 0x50, 0x50, 0x50, 0x50] # send LSB first
        self.uartWrite(cmd)

    def endCmd(self):
        cmd = [0xEE, 0xEE, 0xEE, 0xEE, 0x50, 0x50, 0x50, 0x50]
        self.uartWrite(cmd)

    def downloadFromVerilog(self):
        """
        Read the memory content from the verilog file generated by objdump command.
        and send the data through the uart host
        Verilog file Format:
        @00000000
        73 70 04 30 97 11 00 00 93 81 41 CC 17 01 01 00
        13 01 41 FF 13 05 00 4D 93 05 00 4D 63 78 B5 00
        23 20 05 00 13 05 45 00 E3 6C B5 FE 17 05 00 00
        13 05 C5 35 EF 00 40 3A EF 00 80 08 13 05 00 00
        93 05 00 00 EF 00 C0 00 6F 00 40 30 6F 00 00 00
        @00000050
        13 01 01 FD 23 26 81 02 13 04 01 03 23 2E A4 FC
        23 2C B4 FC 93 07 F0 FF 23 24 F4 FE B7 17 00 80
        """
        print("Start downloading...")
        FH = open(self.file, "r")
        LOG = open(self.logFile, "w")
        lines  = FH.readlines()
        for value in lines:
            if '@' in value:    # this is address line
                addr = int(value.rstrip()[1:], 16)
            else:               # this is data line
                line = value.split()
                data = [line[i:i+4] for i in range(0, len(line), 4)]
                for d in data:
                    word = "".join(reversed(d))
                    LOG.write(f"{hex(addr)}: {hex(int(word, 16))}\n")
                    # send the address and data
                    # send byte by bytes. Need to use [] here
                    self.uartWrite([(addr >> 0) & 0xFF])
                    self.uartWrite([(addr >> 8) & 0xFF])
                    self.uartWrite([(addr >> 16) & 0xFF])
                    self.uartWrite([(addr >> 25) & 0xFF])
                    self.uartWrite([int(d[0], 16)])
                    self.uartWrite([int(d[1], 16)])
                    self.uartWrite([int(d[2], 16)])
                    self.uartWrite([int(d[3], 16)])
                    addr = addr + 4
        FH.close()
        LOG.close()
        print("Download complete...")

    def run(self):
        self.setupUart()
        self.startCmd()
        self.downloadFromVerilog()
        self.endCmd()

def cmdParser():
    parser = argparse.ArgumentParser(description='Upload Instruction ROM through Uart')
    parser.add_argument('-file', '-f', type=str, required=True, nargs='?', help='The Instruction ROM file')
    parser.add_argument('-board', '-b',  type=str, required=True, nargs='?', help='The FPGA board')
    return parser.parse_args()

def getComport(board):
    all_port_info = comports()
    print("All com port info:")
    print("------------------------------------------")
    for p, des, _ in all_port_info:
        print(p, des)
    print("------------------------------------------")
    for p, des, _ in all_port_info:
        if PORT_NAME[board] in des:
            print(f"Found com ports {p} for {board} board")
            return p
    raise ValueError("Did not find com port")


if __name__ == "__main__":
    args = cmdParser()
    f = args.file
    board = args.board
    port = getComport(board)
    uartDownload = UartDownload(port, f)
    uartDownload.run()
