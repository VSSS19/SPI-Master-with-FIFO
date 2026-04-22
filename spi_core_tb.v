`timescale 1ns/1ps

module spi_core_tb;

    reg clk;
    reg reset_n;

    reg spi_en;
    reg cpol;
    reg cpha;
    reg data_width;
    reg [7:0] baud_div;

    reg  [15:0] tx_data;
    reg         tx_empty;
    wire        tx_rd_en;

    wire [15:0] rx_data;
    wire        rx_wr_en;

    wire sclk;
    wire mosi;
    wire ss_n;
    wire busy;
    wire transfer_done;

    wire miso;   // MUST be wire for assign

    //--------------------------------------------------
    // 200 MHz Clock (DO NOT CHANGE)
    //--------------------------------------------------
    initial clk = 0;
    always #2.5 clk = ~clk;   // 200 MHz

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------
    spi_core dut (
        .clk(clk),
        .reset_n(reset_n),
        .spi_en(spi_en),
        .cpol(cpol),
        .cpha(cpha),
        .data_width(data_width),
        .baud_div(baud_div),
        .tx_data(tx_data),
        .tx_empty(tx_empty),
        .tx_rd_en(tx_rd_en),
        .miso(miso),
        .rx_data(rx_data),
        .rx_wr_en(rx_wr_en),
        .sclk(sclk),
        .mosi(mosi),
        .ss_n(ss_n),
        .busy(busy),
        .transfer_done(transfer_done)
    );

    //--------------------------------------------------
    // Loopback (safe for all modes)
    //--------------------------------------------------
    assign miso = mosi;

    //--------------------------------------------------
    // Task: Send One SPI Word
    //--------------------------------------------------
    task send_word;
        input [15:0] data;
        begin
            @(posedge clk);
            tx_data  = data;
            tx_empty = 0;
            spi_en   = 1;

            // Wait until DUT reads data
            wait(tx_rd_en);
            @(posedge clk);
            tx_empty = 1;

            // Wait for transfer completion
            wait(transfer_done);

            @(posedge clk);
            spi_en = 0;

            $display("Time=%0t | TX=%h | RX=%h",
                     $time, data, rx_data);
        end
    endtask

    //--------------------------------------------------
    // Testcases
    //--------------------------------------------------
    initial begin

        // Default
        reset_n   = 0;
        spi_en    = 0;
        tx_empty  = 1;
        cpol      = 0;
        cpha      = 0;
        data_width = 1;   // 16-bit
        baud_div  = 4;

        #50;
        reset_n = 1;
        #50;

        $display("\n===== TEST 1 : Mode 0 =====");
        cpol = 0; cpha = 0;
        send_word(16'hA5A5);

        #200;

        $display("\n===== TEST 2 : Mode 1 =====");
        cpol = 0; cpha = 1;
        send_word(16'h1234);

        #200;

        $display("\n===== TEST 3 : Mode 2 =====");
        cpol = 1; cpha = 0;
        send_word(16'hF0F0);

        #200;

        $display("\n===== TEST 4 : Mode 3 =====");
        cpol = 1; cpha = 1;
        send_word(16'h55AA);

        #500;

        $display("\nAll tests completed.");
        $finish;
    end

endmodule

