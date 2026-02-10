# RTL Design: Synchronous and Asynchronous FIFO

## Overview
This project implements both Synchronous and Asynchronous FIFO architectures in Verilog HDL.

The design focuses on reliable data transfer and proper clock domain crossing (CDC) handling.

## Features

### Synchronous FIFO
- Single clock domain
- Write and Read pointer logic
- Full and Empty flag generation

### Asynchronous FIFO
- Dual clock domain architecture
- Binary to Gray and Gray to Binary conversion
- Two flip-flop synchronizers for CDC
- Full and Empty flag logic

## Verification
- Functional verification using Verilog testbenches
- Waveform analysis performed using simulation tools

## Tools Used
- Xilinx Vivado (RTL simulation and synthesis)


## Author
Jayanth Reddy

