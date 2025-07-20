`timescale 1ns / 1ps

module piso (
    input  wire       reset_n,       // Active-low reset
    input  wire       send,          // Start transmission
    input  wire       baud_clk,      // Baud rate clock
    input  wire       parity_bit,    // Parity bit
    input  wire [7:0] data_in,       // 8-bit parallel input

    output reg        data_tx,       // Serial output
    output reg        active_flag,   // HIGH when sending
    output reg        done_flag      // HIGH when done
);

    // Internal signals
    reg  [3:0]   stop_count;
    reg  [10:0]  frame_r;
    reg  [10:0]  frame_man;
    reg          state;  // FSM state
    wire         count_full;

    // FSM States
    localparam IDLE   = 1'b0;
    localparam ACTIVE = 1'b1;

    // Frame preparation
    always @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            frame_r <= {11{1'b1}};
        else if (state == IDLE)
            frame_r <= {1'b1, parity_bit, data_in, 1'b0}; // STOP + PARITY + DATA + START
    end

    // FSM
    always @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else begin
            case (state)
                IDLE: begin
                    if (send)
                        state <= ACTIVE;
                end
                ACTIVE: begin
                    if (count_full)
                        state <= IDLE;
                end
            endcase
        end
    end

    // Counter
    always @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n || state == IDLE || count_full)
            stop_count <= 4'd0;
        else
            stop_count <= stop_count + 1;
    end

    assign count_full = (stop_count == 4'd11);

    // Shift Register
    always @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            frame_man <= {11{1'b1}};
        else if (state == IDLE)
            frame_man <= frame_r;
        else if (state == ACTIVE)
            frame_man <= frame_man >> 1;
    end

    // Output Logic
    always @(*) begin
        if (reset_n && state == ACTIVE && stop_count != 0) begin
            data_tx     = frame_man[0];
            active_flag = 1'b1;
            done_flag   = 1'b0;
        end else begin
            data_tx     = 1'b1;
            active_flag = 1'b0;
            done_flag   = (state == IDLE && send == 0) ? 1'b1 : 1'b0;
        end
    end

endmodule
