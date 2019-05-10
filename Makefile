#!/usr/bin/make -f

output_files: part1.qpf
	# Do full compile sequence
	quartus_sh --flow compile part1.qpf

clean:
	rm -rf output_files db incremental_db work

compile: clean output_files

recompile: part1.qpf
	quartus_sh --flow recompile part1.qpf

analysis: part1.qpf
	# Run Analysis & Synthesis
	quartus_map part1.qpf

checkusb:
	# Print out helpful diagnostics for seeing if USB is present
	jtagconfig
	quartus_pgm -l
	quartus_pgm -c 'DE-SoC' -a

program: output_files
	quartus_pgm -c 'DE-SoC' ProgramTheDE1_SoC.cdf

enable_signaltap: DE1_SoC.stp
	# Needs DE1_SoC.stp file created manually
	quartus_stp DE1_SoC --signaltap --stp_file=DE1_SoC.stp --logic_analyzer_interface --enable

signaltap: output_files DE1_SoC.stp
	# Needs DE1_SoC.stp file created manually
	quartus_stpw DE1_SoC.stp

qhelp:
	quartus_sh --qhelp
