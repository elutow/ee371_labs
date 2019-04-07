#!/usr/bin/make -f

output_files: DE1_SoC.qpf
	# Do full compile sequence
	quartus_sh --flow compile DE1_SoC.qpf

clean:
	rm -rf output_files db incremental_db work

compile: clean output_files

recompile: DE1_SoC.qpf
	quartus_sh --flow recompile DE1_SoC.qpf

analysis: DE1_SoC.qpf
	# Run Analysis & Synthesis
	quartus_map DE1_SoC.qpf

checkusb:
	# Print out helpful diagnostics for seeing if USB is present
	jtagconfig
	quartus_pgm -l
	quartus_pgm -c 'DE-SoC' -a

program: output_files
	quartus_pgm -c 'DE-SoC' ProgramTheDE1_SoC.cdf

qhelp:
	quartus_sh --qhelp
