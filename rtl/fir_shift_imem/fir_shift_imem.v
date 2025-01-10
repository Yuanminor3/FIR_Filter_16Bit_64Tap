module fir_shift_imem (
	input wire clk, 	// clk2 = 640khz
	input wire reset,
	input wire [15:0] data_in,
	input wire [5:0] read_addr,	// read address
	output reg [15:0] data_out	// read data
);
	reg [15:0] imem[0:63];
	reg [5:0] clk_counter;
	integer i;

	always @(posedge clk or negedge reset) begin
		if (!reset) begin
			for (i = 0; i < 64; i = i + 1) begin
				imem[i] <= 16'b0;
			end
			clk_counter <= 0;

		end else begin
			if (clk_counter == 0) begin
				for (i = 63; i > 0; i = i - 1) begin
					imem[i] <= imem[i-1];
				end
				imem[0] <= data_in;
				clk_counter <= clk_counter + 1;
			end else begin
				clk_counter <= clk_counter + 1;
				if (clk_counter == 63) begin
					clk_counter <= 0;
				end
			end
		end
	end

	always @(*) begin
		data_out = imem[read_addr];
	end
endmodule