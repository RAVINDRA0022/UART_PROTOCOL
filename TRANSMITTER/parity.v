`timescale 1ns / 1ps


module parity( input wire rst , 
                input wire  [7:0]data , 
                input wire [1:0]parity_type , 
                output reg parity_bit );

          parameter ODD = 2'b01 ;
          parameter EVEN = 2'b10 ;
                      
                always @(*) begin
                 parity_bit = !rst ? 1'b1 :
                (parity_type == ODD)  ? (^data? 1'b0 : 1'b1) :
               (parity_type == EVEN) ? (^data ? 1'b1 : 1'b0) :
                                       1'b1; // Default case
end      
endmodule
