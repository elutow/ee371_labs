# ECE/CSE 371 Labs

## Files

* `Makefile` - to run Quartus and ModelSim commands assuming they're in `PATH`
	* Common commands are: `make analysis`, `make compile`, `make program`
* `generate_testbench.py` - Generates testbench files for a specific entity (i.e. Verilog module). Pass in `-h` for usage info
* `launch_modelsim.sh` and `launch_quartus_shell.sh` - Scripts for launching those utilities in @elutow's weird container setup.
* Top level module for programming onto board should be `DE1_SoC` in file `DE1_SoC.sv`.

Please make sure that all text files are encoded in UTF-8 with UNIX line endings (because git doesn't like it when line endings change).

## Branches

* `master` is a base branch to be forked into branches for specific labs
* `lab*_task*` (or `lab*` for an entire lab) contains the code for a specific lab and task. They can be forked off each other.

## Developing

* To start a new lab, fork `master` into a new `lab*_task*` branch.
* To start a new task, you can either fork `master` or a previous `lab*_task*` branch
* Bug fixes between tasks should be cherry-picked between branches, so it is recommended to form small and specific commits
* Cherry pick useful changes into `master`, but this should be discussed first

## Running Testbenches

1. Create testbench module and generate ModelSim testbench scripts via `generate_testbench.py`
2. Open ModelSim (e.g. via `launch_modelsim.sh`)
3. In the ModelSim Transcript window at the bottom, type `do ENTITY_testbench.do` where `ENTITY` is the module name to run the testbench on.

## Compiling and Programming

1. Write Verilog and other code files
2. Include the necessary files by editing `DE1_SoC.qsf` or launching Quartus Prime via `quartus DE1_SoC.qpf`
	* Set `TOP_LEVEL_ENTITY` global assignment to the top-level module name (usually `DE1_SoC`)
	* To add SystemVerilog files, add: `set_global_assignment -name SYSTEMVERILOG_FILE filename.sv`
	* To add Verilog files, add `set_global_assignment -name VERILOG_FILE filename.v`
3. `make analysis` to check errors via Quartus. Repeat until errors are fixed.
	* Can also run testbenches via ModelSim to check errors faster
4. `make compile`
5. Plug in DE1 board. Then: `make program`

## Using SignalTap

1. Enable SignalTap: `make enable_signaltap`
	* This will open up the Quartus project, where you will need to launch SignalTap manually and add the signals.
2. To launch SignalTap in the future: `make signaltap`
