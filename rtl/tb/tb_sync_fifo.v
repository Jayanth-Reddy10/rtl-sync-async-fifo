// -------------------------------------------------
// Testbench for Synchronous FIFO
// -------------------------------------------------

`timescale 1ns / 1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    // Instantiate DUT
    sync_fifo  dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        #20 rst = 0;

        // Write 5 values
        repeat (16) begin
            @(posedge clk);
            wr_en = 1;
            din = din + 1;
        end

        @(posedge clk);
        wr_en = 0;

        // Read 5 values
        repeat (5) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        #50 $finish;
    end

endmodule
