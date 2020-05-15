vlib work

vmap work work



vcom -reportprogress 300 -work work ../src/axi4lite_slave.vhd


vcom -reportprogress 300 -work work ../tb/axi4lite_slave_tb.vhd

vsim -voptargs="+acc" work.axi4lite_slave_tb

do wave.do
