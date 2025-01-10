##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog -suppress 12110 -incr ../../rtl/fir_alu/fir_alu.v 
vlog -suppress 12110 -incr test_fir_alu.v 

# Run Simulator 
vsim -suppress 12110 -t ps -lib work testbench 
do waveformat.do   
run -all
