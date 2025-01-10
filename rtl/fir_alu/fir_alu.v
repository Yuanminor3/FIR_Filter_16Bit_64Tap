
module fir_alu (
    input clk,                     // 640kHz clock signal (FIR core frequency)
    input reset,                   // Reset signal
    input signed [15:0] x_in,      // Current input sample (16-bit signed fixed-point)
    input signed [15:0] cmem_coef, // Coefficients from CMEM (16-bit signed fixed-point)
    output reg [15:0] y_float      // Floating-point output (16-bit)

);

    // Internal variables
    reg signed [37:0] acc_sum;          // Accumulator for MAC operation
    reg signed [37:0] fx_value;
    reg [6:0] tap_index;

    // Define constants for the floating-point format
    localparam SIGN_BIT_POSITION = 15;
    localparam EXPONENT_BITS = 5;
    localparam MANTISSA_BITS = 10;
    localparam EXPONENT_BIAS = 15;
    reg sign_bit;
    reg [4:0] exponent;
    reg [9:0] mantissa;
    reg [37:0] abs_value;
    reg [37:0] shifted_value;
    integer j;
    reg found; // Flag to indicate if MSB has been found

    // Process input data and update delay line
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // Reset all values
            acc_sum <= 0;
            tap_index <= 0;
            fx_value <= 0;
	 
        end else begin 
	    if (tap_index == 63) begin
		fx_value <= acc_sum + (x_in * cmem_coef);
		tap_index <= 0;
		acc_sum <= 0;
	    end else begin
		acc_sum <= acc_sum + (x_in * cmem_coef);
		tap_index <= tap_index + 1;
	
	    end
        end
    end

    // FX-to-FP conversion
    always @(*) begin

        begin
            // Special case: zero
            if (fx_value == 0) begin
                y_float = 16'b0;
            end else begin
                // Determine sign bit
                sign_bit = fx_value[37];
                abs_value = fx_value[37] ? -fx_value : fx_value; // Get absolute value

                // Find the position of the most significant bit (MSB)
                exponent = 0;
                found = 0; // Initialize flag to 0 (MSB not found yet)
		
                for (j = 37; j >= 0; j = j - 1) begin
                    if (!found && abs_value[j] == 1'b1) begin
                        exponent = j; // Update log2_shift with the position of the MSB
                        found = 1;      // Set the flag to indicate MSB has been found
                    end
                end
		
                // Normalize the mantissa (shift to make MSB at position 10)
                shifted_value = abs_value << (38 - exponent);
                mantissa = shifted_value[37:28]; // Extract top 10 bits of normalized value
		

                // Adjust exponent with bias
                exponent = exponent - 20 + 15;

                // Combine sign, exponent, and mantissa
                y_float = {sign_bit, exponent[4:0], mantissa[9:0]};
            end
        end
    end

endmodule
















