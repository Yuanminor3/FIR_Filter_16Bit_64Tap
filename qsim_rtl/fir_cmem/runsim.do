##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../../rtl/CMEM/CMEM.v 
vlog +acc -incr ../../rtl/fir_cmem/fir_cmem.v 
vlog +acc -incr CMEM_tb.v 

# Run Simulator 
vsim +acc -t ps -lib work CMEM_Testbench 
do waveformat.do   
run -all
