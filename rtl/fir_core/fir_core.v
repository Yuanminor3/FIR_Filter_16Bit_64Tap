// Top level of FIR (FSM)

module fir_core(
	input clk1,	// clk1 = 10khz
	input clk2,	// clk2 = 640khz
	input rstn,	// reset (low-active)
	input [15:0] din, // input data -> 16bits
	input valid_in,
	input [5:0] caddr,// address of coefficient -> 64 depth
	input [15:0] cin, // pre-loaded coefficients -> 16 bits
	input cload,
	output reg [15:0] dout, // output data -> 16 bits
	output reg valid_out,
	output wire fifo_empty,
	output wire fifo_full // FIFO state
);

	// signal definition
	wire [15:0] fifo_out_data;	// fifo output
	wire [15:0] Q;			// coefficients out (CMEM)
	wire [15:0] data_out;		// inputs out (IMEM)
	wire [15:0] y_float;		// ALU output (FP16)
	reg  [5:0]  mac_counter;	// MAC counter
	reg imem_valid;
	reg first_non_empty; 		// Purpose for enbale imem_valid
	reg alu_valid;
	reg done;			// Flag to invalid output
	reg [6:0] count_inputs; 	// Expected 100 FP outputs

	// states definition
	reg[1:0] state, next_state;
	// gray code
	localparam IDLE		= 3'b000,	// After reset and waiting valid_in/coefficients are preloaded
		   LOAD_COEF	= 3'b001,	// Start pre-loading coefficients by cin and addr
		   PROCESS	= 3'b011,	// Read data from FIFO into imem and start doing convolution by clk2 = 640khz
		   DONE		= 3'b010;	// Done FIR

	// IDLE = 0, LOAD_COEF = 1, PROCESS = 3, DONE = 2
	always @(*) begin
		case (state)
			IDLE: begin
				if (cload) begin
					next_state = LOAD_COEF; 	// if cload = 1 -> start pre-loading coeffcients
				end else begin
					next_state = IDLE;		// Otherwise still waiting...
				end
			end
			LOAD_COEF: begin
				if (cload) begin
					next_state = LOAD_COEF;		// When cload = 1, continue loading c...
				end else begin
					next_state = PROCESS;		// When cload = 0 -> start FIR
				end
			end					
			PROCESS: begin
				if (count_inputs == 100 && mac_counter == 62) begin
					next_state = DONE;
				end else begin
					next_state = PROCESS;			// exit until FIR finishing...
				end
			end
			DONE: begin
				next_state = DONE;
			end

			default: next_state = IDLE;
		endcase

	end

	// Control Logic & FSM Logic
	// clk2
	always @(posedge clk2 or negedge rstn) begin
		if (!rstn) begin
			imem_valid <= 0;
			mac_counter <= 0;
			done 	  <= 1;
			valid_out <= 0;
			alu_valid <= 0;
			count_inputs <= 0;
			done <= 0;
			//clk2_counter <= 0;
			first_non_empty <= 0;
			// states
			state <= IDLE;
		end else begin
			// done signal pull down
			done <= 0;
			// update clk2 counter
			//clk2_counter <= clk2_counter + 1;
			// states update
			state <= next_state;
			if (next_state == PROCESS) begin
				alu_valid <= 1;
			end
	
			// current states process
			case (state)
				LOAD_COEF: begin
					if ((!first_non_empty) && (!fifo_empty)) begin
						imem_valid <= 1;
						first_non_empty <= 1;
					end
				end
				PROCESS: begin
					if (mac_counter < 63) begin
						mac_counter <= mac_counter + 1;
						
					end else begin
						mac_counter <= 0;
						count_inputs <= count_inputs + 1;
					end
					if (mac_counter == 62) begin
						valid_out <= 1;
					end
				end
				DONE: begin
					alu_valid <= 0; 	// ALU done
					imem_valid <= 0;	// IMEM done
					done <= 1;
					valid_out <= 0;
					first_non_empty <= 0;
				end
			endcase
		end
			
	end

	// OUTPUT (dout)
	always @(*) begin
		if (done) begin
			dout = 0;
		end else begin
			dout = y_float;	
		end
	end

	// FIFO (10kHz write -> 640kHz read -------- 100 FX inputs)
	fir_fifo u_fifo (
		.clk1(clk1),
		.clk2(clk2),
		.rstn(rstn),
		.valid_in(valid_in),
		.din(din),
		.fifo_empty(fifo_empty),
		.fifo_full(fifo_full),
		.fifo_out(fifo_out_data)
	);

	// CMEM (pre-loaded 64 coefficients by using CMEM created by Memory Compilier)
	fir_cmem u_cmem (
       		.Q(Q),
       		.clk(clk2),
       		.CEN(1'b0),
       		.WEN(~cload),
       		.A(caddr),
       		.D(cin)
   	);

	// imem_reg (FIFO -> 64 history FX inputs)
	fir_shift_imem u_imem (
		.clk(clk2),
		.reset(imem_valid),
		.data_in(fifo_out_data),
		.read_addr(mac_counter),
		.data_out(data_out)
	);

	// ALU (64 taps convolution + FX to FP)
	fir_alu u_alu (
       		.clk(clk2),
       		.reset(alu_valid),
       		.x_in(data_out),
		.cmem_coef(Q),
       		.y_float(y_float)
   	);

endmodule
