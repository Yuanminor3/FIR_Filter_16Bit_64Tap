`timescale 1ns / 1ps

module fir_core_tb;

    // Parameters
    localparam CLK1_PERIOD = 100000; // 10 kHz
    localparam CLK2_PERIOD = 1562;   // 640 kHz

    // Inputs
    reg clk1;
    reg clk2;
    reg rstn;
    reg valid_in;
    reg cload;
    reg [15:0] din;
    reg [5:0] caddr;
    reg [15:0] cin;

    // Outputs
    wire [15:0] dout;
    wire valid_out;
    wire fifo_empty;
    wire fifo_full;

    // Instantiate the DUT
    fir_core uut (
        .clk1(clk1),
        .clk2(clk2),
        .rstn(rstn),
        .din(din),
        .valid_in(valid_in),
        .caddr(caddr),
        .cin(cin),
        .cload(cload),
        .dout(dout),
        .valid_out(valid_out),
	.fifo_empty(fifo_empty),
	.fifo_full(fifo_full)
    );

    integer i, j, k, i_file, c_file, i_scan, c_scan;
    reg [15:0] temp_cdata, temp_idata, temp_odata;
    integer output_file, o_status, error_count;

    // --------------------Clock generation-----------------------
    initial begin
        clk1 = 0;
        forever #(CLK1_PERIOD / 2) clk1 = ~clk1;
    end

    initial begin
        clk2 = 0;
        forever #(CLK2_PERIOD / 2) clk2 = ~clk2;
    end
    // -----------------------------------------------------------

    // CMEM: ----------------pre_load coefficients ---------------
    initial begin
	# 48438;
	cload = 1;
	for (i = 0; i < 64; i = i + 1) begin
	   #1562;	// wait for one clk2 cycle  
           c_scan = $fscanf(c_file, "%d\n", temp_cdata);
           if (c_scan != 1) begin
               $display("Error: Failed to read coefficients at line %d", i);
               $finish;
           end

           // Write to CMEM
           caddr = i;              
           cin = $signed(temp_cdata);   
       end
       $fclose(c_file);
	#5486;
	cload = 0;
	#1522;
        caddr = 0;
	#1562;
	forever begin
		if (caddr == 63) begin
			caddr = 0;
		end else begin
			caddr = caddr + 1;
		end
		#1562;
	end
	

     end
    //------------------------------------------------------------

    //IMEM: ----------------FIFO----------------------------------
    initial begin
	j = 0;
	#149900;
	valid_in = 1;
	while (!$feof(i_file)) begin
		if (!fifo_full) begin
			i_scan = $fscanf(i_file, "%d\n", temp_idata);
			if (i_scan != 1) begin
              			$display("Error: Failed to read inputs at line %d", j);
              			$finish;
			end
			din = $signed(temp_idata);
			j = j + 1;
			
		end
		#100000;
	end
	$fclose(i_file);
	valid_in = 0;
	#100000;
		
     end
    //------------------------------------------------------------


    // ----------------------Reset or File open-------------------------
    initial begin
        // Initialize inputs
        rstn = 0;
        valid_in = 0;
        cload = 0;
        din = 0;
        caddr = 0;
        cin = 0;
	error_count = 0;

       // Load coefficients from file into coeff_mem
       $display("Loading coefficients from file...");
       c_file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/filter_coeff.txt", "r");
       if (c_file == 0) begin
           $display("Error: Could not open c_file.");
           $finish;
       end

       i_file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/input_data.txt", "r");
       if (i_file == 0) begin
           $display("Error: Could not open i_file!");
           $finish;
       end

       $dumpfile("./fir_core.vcd");
       $dumpvars(0,fir_core_tb.uut);

        // Reset sequence		
        #49199 rstn = 1;

	# 10300000;

	$dumpall;
        $dumpflush;

	$finish;
    end
    //------------------------------------------------------------

    //---------------Monitor outputs / Compare results------------
	
    // Monitor outputs (compare FP outputs) 
    initial begin

       output_file = $fopen("/homes/user/stud/fall24/yj2848/EE4823FIR/matlab/fir_alu/output_FP.txt", "r");
       if (output_file == 0) begin
           $display("Error: Could not open output_file.");
           $finish;
       end


	#260000
	$display("\n ----------------- Start Comparing... ----------------------\n");
	for (k = 0; k < 100; k = k + 1) begin
		o_status = $fscanf(output_file, "%d\n", temp_odata);
		if (o_status == 0 || o_status == -1) begin
			$display("Error: Reached end of the file or invalid data at iteration %0d", i);
			$fclose(output_file);
		end
		
		if (temp_odata != dout) begin
			$display("Mismatch at line: %0d | at time %0t: Expected %0d, Got %0d", k+1, $time, temp_odata, dout);
			error_count = error_count + 1;
		end else begin
			$display("Correct line: %0d | at time %0t: Expected %0d, Got %0d", k+1, $time, temp_odata, dout);
		end
		#99968;

	end
	if (error_count == 0) begin
		$display("\n ---------No Errors! (after checking floating-point number outputs)----------\n");
	end
	$fclose(output_file);
    end

endmodule

