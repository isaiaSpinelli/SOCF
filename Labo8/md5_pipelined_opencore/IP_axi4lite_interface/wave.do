onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi4lite_slave_tb/S_AXI_ACLK
add wave -noupdate /axi4lite_slave_tb/S_AXI_ARESET
add wave -noupdate /axi4lite_slave_tb/S_AXI_AWADDR
add wave -noupdate /axi4lite_slave_tb/S_AXI_AWVALID
add wave -noupdate /axi4lite_slave_tb/S_AXI_AWREADY
add wave -noupdate /axi4lite_slave_tb/S_AXI_WDATA
add wave -noupdate /axi4lite_slave_tb/S_AXI_WSTRB
add wave -noupdate /axi4lite_slave_tb/S_AXI_WVALID
add wave -noupdate /axi4lite_slave_tb/S_AXI_WREADY
add wave -noupdate /axi4lite_slave_tb/S_AXI_BVALID
add wave -noupdate /axi4lite_slave_tb/S_AXI_RREADY
add wave -noupdate /axi4lite_slave_tb/S_AXI_BRESP
add wave -noupdate /axi4lite_slave_tb/S_AXI_ARADDR
add wave -noupdate /axi4lite_slave_tb/S_AXI_ARVALID
add wave -noupdate /axi4lite_slave_tb/S_AXI_ARREADY
add wave -noupdate /axi4lite_slave_tb/S_AXI_RDATA
add wave -noupdate /axi4lite_slave_tb/S_AXI_RVALID
add wave -noupdate /axi4lite_slave_tb/S_AXI_RREADY
add wave -noupdate /axi4lite_slave_tb/S_AXI_RRESP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1 us}
