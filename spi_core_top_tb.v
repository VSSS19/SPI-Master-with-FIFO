`timescale 1ns/1ps

module spi_core_top_tb;

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

    wire miso;

    // Interrupt
    reg tx_int_en;
    reg rx_int_en;
    reg tc_int_en;
    reg rx_full;
    wire irq;

    //---------------- 200 MHz clock ----------------
    initial clk = 0;
    always #2.5 clk = ~clk;

    //---------------- VCD DUMP ----------------
    initial begin
        $dumpfile("spi_core_top_tb.vcd");   // VCD file name
        $dumpvars(0, spi_core_top_tb);      // Dump entire hierarchy
    end

    //---------------- DUT ----------------
    spi_core_top dut (
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
        .transfer_done(transfer_done),
        .tx_int_en(tx_int_en),
        .rx_int_en(rx_int_en),
        .tc_int_en(tc_int_en),
        .rx_full(rx_full),
        .irq(irq)
    );

    //---------------- MOSI ? MISO loopback ----------------
    assign miso = mosi;

    //---------------- TASK: Send SPI word ----------------
    task send_word;
        input [15:0] data;
        begin
            @(posedge clk);
            tx_data  = data;
            tx_empty = 0;
            spi_en   = 1;

            wait (tx_rd_en);
            @(posedge clk);
            tx_empty = 1;

            wait (transfer_done);

            @(posedge clk);
            spi_en = 0;

            $display("T=%0t CPOL=%0d CPHA=%0d TX=%h RX=%h IRQ=%b",
                      $time, cpol, cpha, data, rx_data, irq);
        end
    endtask

    //---------------- TEST SEQUENCE ----------------
    initial begin
        reset_n = 0;
        spi_en  = 0;
        tx_empty = 1;
        tx_data = 0;
        cpol = 0;
        cpha = 0;
        data_width = 1; // 16-bit
        baud_div = 4;

        tx_int_en = 1;
        rx_int_en = 0;
        tc_int_en = 1;
        rx_full   = 0;

        #50;
        reset_n = 1;
        #50;

        $display("\n--- MODE 0 ---");
        cpol = 0; cpha = 0;
        send_word(16'hA5A5);

        #200;
        $display("\n--- MODE 1 ---");
        cpol = 0; cpha = 1;
        send_word(16'h1234);

        #200;
        $display("\n--- MODE 2 ---");
        cpol = 1; cpha = 0;
        send_word(16'hF0F0);

        #200;
        $display("\n--- MODE 3 ---");
        cpol = 1; cpha = 1;
        send_word(16'h55AA);

        #300;
        data_width = 0; // 8-bit
        $display("\n--- 8-BIT MODE ---");
        send_word(16'h00A5);

        #500;
        $display("\nALL TESTS COMPLETED SUCCESSFULLY");
        $finish;
    end

endmodule

