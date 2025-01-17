`timescale 1ns / 1ps

module fir_cmem(

   // Inputs and Outputs
   input clk,                        
   input CEN,                         // Chip Enable
   input WEN,                         // Write Enable
   input [5:0] A,          // Address
   input [15:0] D,                // Inputs
   output [15:0] Q              // Outputs
);


   // Instantiate the CMEM module
   CMEM uut (
       .Q(Q),
       .CLK(clk),
       .CEN(CEN),
       .WEN(WEN),
       .A(A),
       .D(D)
   );

endmodule
