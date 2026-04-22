module spi_interrupt (
    input  wire clk,
    input  wire reset_n,
    input  wire tx_empty,
    input  wire rx_full,
    input  wire transfer_done,
    input  wire tx_int_en,
    input  wire rx_int_en,
    input  wire tc_int_en,
    output wire irq
);

    assign irq = (tx_empty      & tx_int_en) |
                 (rx_full       & rx_int_en) |
                 (transfer_done & tc_int_en);

endmodule

