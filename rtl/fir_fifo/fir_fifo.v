module fir_fifo (
	input wire clk1,  // 10khz (FIFO write clk)
	input wire clk2,  // 640khz (FIFO read clk)
	input wire rstn,  // Reset (active-low)
	input wire valid_in, // Valid signal for input data
	input wire [15:0] din, // input data

	output wire fifo_empty,
	output wire fifo_full,
	output [15:0] fifo_out

);
	// FIFO memory (depth = 4)
	reg [15:0] fifo_mem [0:3];
	reg [2:0] wr_ptr, rd_ptr;    
	reg [2:0] wr_ptr_gray, rd_ptr_gray;
	reg [2:0] wr_ptr_gray_sync, rd_ptr_gray_sync, wr_ptr_gray_sync1, rd_ptr_gray_sync1;

	//FIFO Write (clk1 = 10K hz)
	always @(posedge clk1 or negedge rstn) begin
    	if (!rstn) begin
        	wr_ptr <= 0;
        	wr_ptr_gray <= 0;
    	end
    	else if (valid_in && !fifo_full) begin
        	fifo_mem[wr_ptr[1:0]] <= din;
        	wr_ptr <= (wr_ptr + 1) & 3;
        	wr_ptr_gray <= (((wr_ptr + 1) & 3) >> 1)^((wr_ptr + 1) & 3); // convert to gray code
    	end   	 
	end

	//FIFO Read (clk2 = 640K hz)
	reg [15:0] fifo_out_data;
	always @(posedge clk2 or negedge rstn) begin
    	if (!rstn) begin
        	rd_ptr <= 0;
        	rd_ptr_gray <= 0;
    	end
    	else if (!fifo_empty) begin
        	fifo_out_data <= fifo_mem[rd_ptr[1:0]];
        	rd_ptr <= (rd_ptr + 1) & 3;
        	rd_ptr_gray <= (((rd_ptr + 1) & 3) >> 1)^((rd_ptr + 1) & 3); // convert to gray code
    	end   	 
	end

	// Synchronize write pointer to clk2 read domain (to know FIFO "empty" or not)
	always @(posedge clk2 or negedge rstn) begin
    	if (!rstn) begin
        	wr_ptr_gray_sync <= 0;
		wr_ptr_gray_sync1 <= 0;
    	end
    	else begin
        	wr_ptr_gray_sync <= wr_ptr_gray;
		wr_ptr_gray_sync1 <= wr_ptr_gray_sync;
    	end   	 
	end

	// Synchronize read pointer to clk1 write domain (to know FIFO "full" or not)
	always @(posedge clk1 or negedge rstn) begin
    	if (!rstn) begin
        	rd_ptr_gray_sync <= 0;
		rd_ptr_gray_sync1 <= 0;
    	end
    	else begin
        	rd_ptr_gray_sync <= rd_ptr_gray;
		rd_ptr_gray_sync1 <= rd_ptr_gray_sync;
    	end   	 
	end

	//FIFO "empty"/"full" status
	assign fifo_empty = (wr_ptr_gray_sync1 == rd_ptr_gray);
	assign fifo_full = (wr_ptr_gray[2:1] != rd_ptr_gray_sync1[2:1])&&(wr_ptr_gray[0] == rd_ptr_gray_sync1[0]) ;	
	// Output data
	assign fifo_out = fifo_out_data;

endmodule










