onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fir_core_tb/clk1
add wave -noupdate /fir_core_tb/clk2
add wave -noupdate /fir_core_tb/rstn
add wave -noupdate /fir_core_tb/valid_in
add wave -noupdate -radix unsigned /fir_core_tb/din
add wave -noupdate -radix unsigned /fir_core_tb/cload
add wave -noupdate -radix unsigned /fir_core_tb/caddr
add wave -noupdate -radix unsigned /fir_core_tb/uut.state
add wave -noupdate -radix unsigned /fir_core_tb/uut.mac_counter
add wave -noupdate -radix unsigned /fir_core_tb/uut.fifo_empty
add wave -noupdate -radix unsigned /fir_core_tb/uut.fifo_full
add wave -noupdate -radix unsigned /fir_core_tb/uut.fifo_out_data
add wave -noupdate -radix unsigned /fir_core_tb/valid_out
add wave -noupdate -radix unsigned /fir_core_tb/dout

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
configure wave -valuecolwidth 89
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {10 ns}
