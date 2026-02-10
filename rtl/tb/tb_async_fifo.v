// -------------------------------------------------
// Testbench for Asynchronous FIFO
// -------------------------------------------------

`timescale 1ns / 1ps

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 8;
    parameter ADDR_WIDTH = 3;

    reg wr_clk;
    reg rd_clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;

    // Instantiate DUT
    async_fifo #(DATA_WIDTH, DEPTH, ADDR_WIDTH) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Different clock frequencies
    always #5  wr_clk = ~wr_clk;   // 100 MHz
    always #7  rd_clk = ~rd_clk;   // ~71 MHz

    initial begin
        wr_clk = 0;
        rd_clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        #20 rst = 0;

        // ----------------------
        // WRITE 6 VALUES
        // ----------------------
        repeat (8) begin
            @(posedge wr_clk);
            wr_en = 1;
            data_in = data_in + 1;
        end

        @(posedge wr_clk);
        wr_en = 0;

        // Wait few cycles
        #50;

        // ----------------------
        // READ 6 VALUES
        // ----------------------
        repeat (6) begin
            @(posedge rd_clk);
            rd_en = 1;
        end

        @(posedge rd_clk);
        rd_en = 0;

        #100;
        $finish;
    end

endmodule
