
`timescale 1ns / 1ps
`include "./../../rtl/CMEM/CMEM.v"


module CMEM_Testbench;
   // Parameters
   parameter BITS = 16;
   parameter WORD_DEPTH = 64;
   parameter ADDR_WIDTH = 6;


   // Inputs and Outputs
   reg CLK;                        
   reg CEN;                         // Chip Enable
   reg WEN;                         // Write Enable
   reg [ADDR_WIDTH-1:0] A;          // Address
   reg [BITS-1:0] D;                // Inputs
   wire [BITS-1:0] Q;               // Outputs


   // Instantiate the CMEM module
   fir_cmem uut (
       .Q(Q),
       .clk(CLK),
       .CEN(CEN),
       .WEN(WEN),
       .A(A),
       .D(D)
   );


   // Generate 640kHz Clock (1.5625 µs period)
   always #781 CLK = ~CLK; // 781ns * 2 = 1.5625 µs


   integer i, file, scan, r_idx;
   reg [15:0] temp_data;



   always @(posedge CLK) begin
	#3
	$display("At time %t: Address %d, Data Out: %d", $time, A, Q); 

   end


   initial begin
       // Initialize signals
       CLK = 0;
       CEN = 1;
       WEN = 1;
       A = 0;
       D = 0;


       // Load coefficients from file into coeff_mem
       $display("Loading coefficients from file...");
       file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/filter_coeff.txt", "r");
       if (file == 0) begin
           $display("Error: Could not open file.");
           $finish;
       end

       #10 CEN = 0; // Chip Enable
       $display("Writing and Reading data from CMEM...");
      
       for (i = 0; i < WORD_DEPTH; i = i + 1) begin
           scan = $fscanf(file, "%d\n", temp_data);
           if (scan != 1) begin
               $display("Error: Failed to read data at line %d", i);
               $finish;
           end


           // Write to CMEM
           #751 A = i;              
               D = temp_data;
               WEN = 0;           
           #811 WEN = 1;           
       end
       $fclose(file);

      
       #20 $finish;
   end
endmodule






