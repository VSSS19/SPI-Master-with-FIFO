module spi_core (
    input  wire        clk,
    input  wire        reset_n,

    input  wire        spi_en,
    input  wire        cpol,
    input  wire        cpha,
    input  wire        data_width,   // 0 = 8-bit, 1 = 16-bit
    input  wire [7:0]  baud_div,

    input  wire [15:0] tx_data,
    input  wire        tx_empty,
    output reg         tx_rd_en,

    input  wire        miso,
    output reg  [15:0] rx_data,
    output reg         rx_wr_en,

    output reg         sclk,
    output reg         mosi,
    output reg         ss_n,
    output reg         busy,
    output reg         transfer_done
);

    //--------------------------------------------------
    // Internal Registers
    //--------------------------------------------------
    reg [15:0] shift_reg;
    reg [4:0]  bit_cnt;
    wire [4:0] max_bits;

    assign max_bits = (data_width) ? 5'd15 : 5'd7;

    //--------------------------------------------------
    // MISO Synchronizer
    //--------------------------------------------------
    reg miso_d1, miso_sync;

    always @(posedge clk) begin
        miso_d1   <= miso;
        miso_sync <= miso_d1;
    end

    //--------------------------------------------------
    // Clock Divider
    //--------------------------------------------------
    reg [7:0] div_cnt;
    wire clk_tick;

    assign clk_tick = (div_cnt == baud_div);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            div_cnt <= 0;
        else if (busy) begin
            if (clk_tick)
                div_cnt <= 0;
            else
                div_cnt <= div_cnt + 1;
        end
        else
            div_cnt <= 0;
    end

    //--------------------------------------------------
    // Edge Detection
    //--------------------------------------------------
    reg sclk_d;

    always @(posedge clk)
        sclk_d <= sclk;

    wire sclk_rising  = (sclk_d == 0 && sclk == 1);
    wire sclk_falling = (sclk_d == 1 && sclk == 0);

    wire sample_edge =
        (cpol==0 && cpha==0 && sclk_rising ) ||
        (cpol==0 && cpha==1 && sclk_falling) ||
        (cpol==1 && cpha==0 && sclk_falling) ||
        (cpol==1 && cpha==1 && sclk_rising );

    wire shift_edge =
        (cpol==0 && cpha==0 && sclk_falling) ||
        (cpol==0 && cpha==1 && sclk_rising ) ||
        (cpol==1 && cpha==0 && sclk_rising ) ||
        (cpol==1 && cpha==1 && sclk_falling);

    //--------------------------------------------------
    // FSM States
    //--------------------------------------------------
    localparam IDLE     = 2'd0,
               LOAD     = 2'd1,
               TRANSFER = 2'd2,
               DONE     = 2'd3;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE:
                if (spi_en && !tx_empty)
                    next_state = LOAD;

            LOAD:
                next_state = TRANSFER;

            TRANSFER:
                if (bit_cnt == max_bits && sample_edge)
                    next_state = DONE;

            DONE:
                next_state = IDLE;

            default:
                next_state = IDLE;
        endcase
    end

    //--------------------------------------------------
    // SPI Logic
    //--------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            busy <= 0;
            ss_n <= 1;
            sclk <= 0;
            mosi <= 0;
            tx_rd_en <= 0;
            rx_wr_en <= 0;
            transfer_done <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            rx_data <= 0;
        end
        else begin
            tx_rd_en <= 0;
            rx_wr_en <= 0;
            transfer_done <= 0;

            case (state)

                IDLE: begin
                    busy <= 0;
                    ss_n <= 1;
                    sclk <= cpol;
                end

                LOAD: begin
                    busy <= 1;
                    ss_n <= 0;
                    shift_reg <= tx_data;
                    bit_cnt <= 0;
                    tx_rd_en <= 1;
                    sclk <= cpol;

                    if (cpha == 0)
                        mosi <= tx_data[max_bits];
                end

                TRANSFER: begin
                    if (clk_tick)
                        sclk <= ~sclk;

                    if (shift_edge)
                        mosi <= shift_reg[max_bits];

                    if (sample_edge) begin
                        shift_reg <= {shift_reg[14:0], miso_sync};
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                DONE: begin
                    ss_n <= 1;
                    busy <= 0;
                    rx_data <= shift_reg;
                    rx_wr_en <= 1;
                    transfer_done <= 1;
                end

            endcase
        end
    end

endmodule

