##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../../rtl/fir_shift_imem/fir_shift_imem.v 
vlog +acc -incr fir_shift_imem_tb.v 

# Run Simulator 
vsim +acc -t ps -lib work fir_shift_imem_tb 
do waveformat.do   
run -all
