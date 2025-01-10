`timescale 1ns/1ps
module fifo_testbench;

	reg clk1;  // 10khz (FIFO write clk)
	reg clk2;  // 640khz (FIFO read clk)
	reg rstn;  // Reset (active-low)
	reg valid_in; // FIFO input valid signal
	reg [15:0] din; // input data

	wire fifo_empty;
	wire fifo_full;
	wire [15:0] fifo_out_data;

	// FIFO instantiation
	fir_fifo uut (
		.clk1(clk1),
		.clk2(clk2),
		.rstn(rstn),
		.valid_in(valid_in),
		.din(din),
		.fifo_empty(fifo_empty),
		.fifo_full(fifo_full),
		.fifo_out(fifo_out_data)
	);


	integer i, j, k, t, file, scan;
   	reg [15:0] temp_data;


	// IMEM interface signals
	reg imem_cen;
	reg imem_wen;
	reg [5:0] imem_addr;
	reg [15:0] imem_d;
	wire [15:0] imem_out;

	

	//IMEM instantiation
	fir_imem imem_inst (
		.clk(clk2),
		.CEN(imem_cen),
		.WEN(imem_wen),
		.A(imem_addr),
		.D(imem_d),
		.Q(imem_out)
	);


	// *********CLK***********
	// clock generation
	initial clk1 = 0;
	always #50000 clk1 = ~clk1; // clk1(10Khz) -> 100000ns

	initial clk2 = 0;
	always #781 clk2 = ~clk2;  // clk2(640Khz) -> 1562.5ns

	// Reset and data input 
	initial begin
		rstn = 0;
		valid_in = 0;
		din = 0;

		#100000;
		rstn = 1;   //release reset

		// *********FIFO***********
		// Write data to FIFO from Matlab input data
		$display("Start to write x_in to FIFO from Matlab .txt file...");
        	file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/input_data.txt", "r");
        	if (file == 0) begin
            		$display("Error: Could not open file.");
            		$finish;
        	end
	
		i = 0;
		valid_in = 1;
		while (!$feof(file)) begin
			@(posedge clk1);
			if (!fifo_full) begin
				scan = $fscanf(file, "%d\n", temp_data);
				if (scan != 1) begin
              				$display("Error: Failed to read data at line %d", i);
              				$finish;
				end
				din = $signed(temp_data);
				i = i + 1;
          		end
		end
		$fclose(file);
		@(posedge clk1);
		valid_in = 0;
	end

	// *********IMEM***********
	always @(negedge rstn) begin
		// IMEM initialization (imem[A] -> 0)
		for (j = 0; j < 64; j = j + 1) begin
			imem_addr <= j;
			imem_d <= 0;
			@(posedge clk2);
		end
		imem_cen <= 1;
		imem_wen <= 1;
		imem_addr <= 0;
		imem_d <= 0;
	end

	
	initial begin
		#254606  // skip first "0" in FIFO_out (163 cycles @ clk2)
		imem_cen = 0;
	
		for (t = 0; t < 100; t = t + 1) begin
		imem_addr = t % 64;
		imem_d = fifo_out_data;
		imem_wen = 0;

		#2000 imem_wen = 1;
		#99968; // after 64 cycles @ clk2 / 1 cycle @ clk1

		end
		imem_wen = 1;
		imem_cen <= 1;
	
	#11000000; // run similation for 11ms
	$finish;
	end

endmodule	















