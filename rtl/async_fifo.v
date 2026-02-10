// -------------------------------------------------
// Asynchronous FIFO
// Author: Jayanth Reddy
// Description: RTL implementation of Async FIFO with CDC handling
// -------------------------------------------------

//======================================
// Asynchronous FIFO (dual clock)
// - Write clock: wr_clk
// - Read  clock: rd_clk
// - Gray-code pointers + 2FF sync
//======================================


module async_fifo #(
    parameter DATA_WIDTH = 8,   // width of one data word
    parameter DEPTH      = 8,   // number of FIFO locations
    parameter ADDR_WIDTH = 3    // log2(DEPTH)
)(
    input  wire                  wr_clk,   // write clock
    input  wire                  rd_clk,   // read clock
    input  wire                  rst,      // async reset

    input  wire                  wr_en,    // write enable
    input  wire                  rd_en,    // read enable

    input  wire [DATA_WIDTH-1:0] data_in,  // data to write
    output reg  [DATA_WIDTH-1:0] data_out, // data read

    output wire                  full,     // FIFO full flag
    output wire                  empty     // FIFO empty flag
);

    // -------------------------------------------------
    // FIFO MEMORY
    // -------------------------------------------------
    // This is the storage (boxes) where data waits
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // -------------------------------------------------
    // BINARY POINTERS (local counters)
    // -------------------------------------------------
    // Extra MSB is used to track wrap-around
    reg [ADDR_WIDTH:0] wr_bin;   // write binary pointer
    reg [ADDR_WIDTH:0] rd_bin;   // read binary pointer

    // -------------------------------------------------
    // GRAY POINTERS (safe for clock crossing)
    // -------------------------------------------------
    reg [ADDR_WIDTH:0] wr_gray;  // write gray pointer
    reg [ADDR_WIDTH:0] rd_gray;  // read gray pointer

    // -------------------------------------------------
    // SYNCHRONIZED GRAY POINTERS
    // -------------------------------------------------
    // Read pointer synced into write clock domain
    reg [ADDR_WIDTH:0] rd_gray_sync1, rd_gray_sync2;

    // Write pointer synced into read clock domain
    reg [ADDR_WIDTH:0] wr_gray_sync1, wr_gray_sync2;

    // -------------------------------------------------
    // WRITE LOGIC (WRITE CLOCK DOMAIN)
    // -------------------------------------------------
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_bin  <= 0;   // reset write pointer
            wr_gray <= 0;
        end else if (wr_en && !full) begin
            // write data into memory at current location
            mem[wr_bin[ADDR_WIDTH-1:0]] <= data_in;

            // increment binary write pointer
            wr_bin <= wr_bin + 1;

            // convert next binary value to Gray
            wr_gray <= ( (wr_bin + 1) >> 1 ) ^ (wr_bin + 1);
        end
    end

    // -------------------------------------------------
    // READ LOGIC (READ CLOCK DOMAIN)
    // -------------------------------------------------
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_bin   <= 0;  // reset read pointer
            rd_gray  <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            // read data from memory at current location
            data_out <= mem[rd_bin[ADDR_WIDTH-1:0]];

            // increment binary read pointer
            rd_bin <= rd_bin + 1;

            // convert next binary value to Gray
            rd_gray <= ( (rd_bin + 1) >> 1 ) ^ (rd_bin + 1);
        end
    end

    // -------------------------------------------------
    // SYNCHRONIZE READ POINTER INTO WRITE CLOCK
    // -------------------------------------------------
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_gray_sync1 <= 0;
            rd_gray_sync2 <= 0;
        end else begin
            rd_gray_sync1 <= rd_gray;        // first sync stage
            rd_gray_sync2 <= rd_gray_sync1;  // second sync stage (stable)
        end
    end

    // -------------------------------------------------
    // SYNCHRONIZE WRITE POINTER INTO READ CLOCK
    // -------------------------------------------------
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_gray_sync1 <= 0;
            wr_gray_sync2 <= 0;
        end else begin
            wr_gray_sync1 <= wr_gray;        // first sync stage
            wr_gray_sync2 <= wr_gray_sync1;  // second sync stage (stable)
        end
    end

    // -------------------------------------------------
    // EMPTY DETECTION (READ CLOCK DOMAIN)
    // -------------------------------------------------
    // FIFO is empty when read pointer equals write pointer
    assign empty = (rd_gray == wr_gray_sync2);

    // -------------------------------------------------
    // FULL DETECTION (WRITE CLOCK DOMAIN)
    // -------------------------------------------------
    // FIFO is full when:
    // - lower bits are same (same location)
    // - MSBs are inverted (write wrapped one more time)
    assign full =
        (wr_gray[ADDR_WIDTH]     != rd_gray_sync2[ADDR_WIDTH]) &&
        (wr_gray[ADDR_WIDTH-1]   != rd_gray_sync2[ADDR_WIDTH-1]) &&
        (wr_gray[ADDR_WIDTH-2:0] == rd_gray_sync2[ADDR_WIDTH-2:0]);

endmodule
