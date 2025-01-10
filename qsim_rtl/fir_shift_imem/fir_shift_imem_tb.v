`timescale 1ns / 1ps
module fir_shift_imem_tb;
	reg clk;	 // clk2 = 640khz
	reg reset;
	reg [15:0] data_in;
	reg [5:0] read_addr;
	wire [15:0] data_out;
	
	fir_shift_imem uut (
		.clk(clk),
		.reset(reset),
		.data_in(data_in),
		.read_addr(read_addr),
		.data_out(data_out)
	);

	integer i;
	
	// clk initialization
	initial clk = 0;
	always #781 clk = ~clk;

	initial begin
	
	reset = 0;
	data_in = 0;
	read_addr = 0;

	// reset
	#100 reset = 1;
	#1462 data_in = 100;
		read_addr = 0;
		$display("Read imem[0]:",data_out);
		
	for (i = 1; i < 100; i = i + 1) begin
		#1562 data_in = 100 + i;
			read_addr = 0;
			$display("Read imem[%d]: %d", i, data_out);
	end

	#100;
	$finish;
	
	
	end

endmodule
