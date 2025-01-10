##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

#Setup
 vlib work 
 vmap work work

#Include Netlist and Testbench
 vlog +acc -incr /courses/ee6321/share/ibm13rflpvt/verilog/ibm13rflpvt.v
vlog +acc -incr ../../rtl/IMEM/IMEM.v 
vlog +acc -incr ../../rtl/fir_imem/fir_imem.v
vlog +acc -incr ../../dc/fir_fifo/fir_fifo.nl.v
vlog +acc -incr fir_fifo_tb.v 

#Run Simulator 
#SDF from DC is annotated for the timing check 
vsim -voptargs=+acc -t ps -lib work -sdftyp uut=../../dc/fir_fifo/fir_fifo.syn.sdf fifo_testbench 
 do waveformat.do   
 run -all
