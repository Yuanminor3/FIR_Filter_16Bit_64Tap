##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../../rtl/IMEM/IMEM.v 
vlog +acc -incr ../../rtl/fir_imem/fir_imem.v
vlog +acc -incr ../../rtl/fir_fifo/fir_fifo.v 
vlog +acc -incr fir_fifo_tb.v 

# Run Simulator 
vsim +acc -t ps -lib work fifo_testbench 
do waveformat.do   
run -all
