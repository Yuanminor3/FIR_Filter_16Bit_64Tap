###################################################################### 
## Timing setup for logic synthesis
## The unit for time is ns as defined in the IBM delay-power library
## The unit for wireload is pF as defined in the IBM delay-power library
## MS 2015
###################################################################### 

# Setting variables 
set clk_period_1 100000
set clk_period_2 1562
set clk_uncertainty 0
set clk_transition 0.010
set typical_input_delay 0.05
set typical_output_delay 0.05
set typical_wire_load 0.005

#Create real clock if clock port is found
if {[sizeof_collection [get_ports clk1]] > 0} {
  set clk_name_1 "clk1"
  set clk_port_1 "clk1"
  create_clock -name $clk_name_1 -period $clk_period_1 [get_ports $clk_port_1] 
  set_drive 0 [get_ports $clk_name_1] 
}

#Create real clock if clock port is found
if {[sizeof_collection [get_ports clk2]] > 0} {
  set clk_name_2 "clk2"
  set clk_port_2 "clk2"
  create_clock -name $clk_name_2 -period $clk_period_2 [get_ports $clk_port_2] 
  set_drive 0 [get_ports $clk_name_2] 
}


#Set clock uncertainty
set_clock_uncertainty $clk_uncertainty [get_clocks $clk_name_1]
set_clock_transition $clk_transition [get_clocks $clk_name_1]
set_clock_uncertainty $clk_uncertainty [get_clocks $clk_name_2]
set_clock_transition $clk_transition [get_clocks $clk_name_2]

# Set input and output delays
set_driving_cell -lib_cell INVX1TS [all_inputs]
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name_1 
remove_input_delay -clock $clk_name_1 [find port $clk_port_1]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_name_1
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name_2 
remove_input_delay -clock $clk_name_2 [find port $clk_port_2]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_name_2

# Set loading of outputs 
set_load 0.005 [all_outputs] 
