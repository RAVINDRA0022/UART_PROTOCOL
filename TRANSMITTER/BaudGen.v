`timescale 1ns / 1ps

module BaudGen (
    input  wire       clk,
    input  wire       rst,        // Active-low reset
    input  wire [1:0] baud_rate,  // Baud rate selector
    output reg        baud_clk    // Generated baud clock
);

    
    localparam BAUD24  = 2'b00,
               BAUD48  = 2'b01,
               BAUD96  = 2'b10,
               BAUD128 = 2'b11;

    wire [13:0] final_value;

    assign final_value = (baud_rate == BAUD24)  ? 14'd10416 :  // 2400 baud
                         (baud_rate == BAUD48)  ? 14'd5208  :  // 4800 baud
                         (baud_rate == BAUD96)  ? 14'd2604  :  // 9600 baud
                         (baud_rate == BAUD128) ? 14'd1952  :  // 12800 baud
                                                  14'd0;

    reg [13:0] clk_ticks;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            clk_ticks <= 14'd0;
            baud_clk  <= 1'b0;
        end else begin
            if (clk_ticks >= final_value) begin
                clk_ticks <= 14'd0;
                baud_clk  <= ~baud_clk;
            end else begin
                clk_ticks <= clk_ticks + 14'd1;
            end
        end
    end

endmodule
