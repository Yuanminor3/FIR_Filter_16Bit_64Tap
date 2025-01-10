`timescale 1ns / 1ps


module testbench;


   // Signals for FIR ALU
   reg clk;
   reg reset;
   reg signed [15:0] x_in;
   wire [15:0] y_float; // Output after FX2FP conversion


   // Instantiate the FIR ALU module
   fir_alu uut (
       .clk(clk),
       .reset(reset),
       .x_in(x_in),
       .y_float(y_float)
   );


   // Clock generation: 640kHz (781.25ns period)
   initial begin
       clk = 0;
       forever #781 clk = ~clk; // 640kHz clock, half-period = 781.25ns
   end


   // Declare variables
   integer x_file, scan_status, i;
   //reg [15:0] b_unsigned [0:63]; // Unsigned filter coefficients
   reg [15:0] x_unsigned [0:99]; // Unsigned input data
   //reg signed [15:0] coef [0:63]; // Signed filter coefficients
   reg signed [15:0] x_data [0:99]; // Signed input data



   // Test sequence
   initial begin
       reset = 0;
       #100;               // Hold reset for 100ns
       //b_file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/filter_coeff.txt", "r");
       x_file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/input_data.txt", "r");
       if (x_file == 0) begin
           $display("Error: Could not open file!");
           $finish;
       end

       $dumpfile("./fir_alu.vcd");
       $dumpvars(0,testbench.uut);

	/*
       // Read filter coefficients (unsigned) and convert to signed
       for (j = 0; j < 64; j = j + 1) begin
           scan_status = $fscanf(b_file, "%d\n", b_unsigned[j]);
           coef[j] = $signed(b_unsigned[j]); // Convert to signed
           uut.b[j] = coef[j];               // Pre-load into DUT
       end
       $fclose(b_file);*/


       // Read input samples (unsigned) and convert to signed
       for (i = 0; i < 100; i = i + 1) begin
           scan_status = $fscanf(x_file, "%d\n", x_unsigned[i]);
           x_data[i] = $signed(x_unsigned[i]); // Convert to signed
       end
       $fclose(x_file);

       reset = 1;

       // Apply input samples at 10kHz rate
       for (i = 0; i < 100; i = i + 1) begin
           x_in = x_data[i];
           repeat(65) @(posedge clk); // Wait for 64 clock cycles
       end

       // No new input after this point
       x_in = 16'sd0; // Assign 0 to x_in for remaining convolution
       repeat(65) @(posedge clk);
       // End simulation
       #1563;

       $dumpall;
       $dumpflush;

       $finish;
   end


endmodule
