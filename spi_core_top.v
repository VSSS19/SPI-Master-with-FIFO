module spi_core_top (
    input  wire        clk,
    input  wire        reset_n,

    input  wire        spi_en,
    input  wire        cpol,
    input  wire        cpha,
    input  wire        data_width,
    input  wire [7:0]  baud_div,

    input  wire [15:0] tx_data,
    input  wire        tx_empty,
    output wire        tx_rd_en,

    input  wire        miso,
    output wire [15:0] rx_data,
    output wire        rx_wr_en,

    output wire        sclk,
    output wire        mosi,
    output wire        ss_n,
    output wire        busy,
    output wire        transfer_done,

    // Interrupt enables
    input  wire        tx_int_en,
    input  wire        rx_int_en,
    input  wire        tc_int_en,

    // RX FIFO status (simulated)
    input  wire        rx_full,

    // Interrupt output
    output wire        irq
);

    //---------------- SPI CORE ----------------
    spi_core u_spi_core (
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

    //---------------- INTERRUPT ----------------
    spi_interrupt u_spi_interrupt (
        .clk(clk),
        .reset_n(reset_n),
        .tx_empty(tx_empty),
        .rx_full(rx_full),
        .transfer_done(transfer_done),
        .tx_int_en(tx_int_en),
        .rx_int_en(rx_int_en),
        .tc_int_en(tc_int_en),
        .irq(irq)
    );

endmodule

