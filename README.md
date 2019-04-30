# ECE/CSE 371 Labs

## Files

* `Makefile` - to run Quartus and ModelSim commands assuming they're in `PATH`
* `generate_testbench.py` - Generates testbench files for a specific entity (i.e. Verilog module). Pass in `-h` for usage info
* `launch_modelsim.sh` and `launch_quartus_shell.sh` - Scripts for launching those utilities in @elutow's weird container setup.

Please make sure that all text files are encoded in UTF-8 with UNIX line endings (because git doesn't like it when line endings change).

## Branches

* `master` is a base branch to be forked into branches for specific labs
* `lab*_task*` (or `lab*` for an entire lab) contains the code for a specific lab and task. They can be forked off each other.

## Developing

* To start a new lab, fork `master` into a new `lab*_task*` branch.
* To start a new task, you can either fork `master` or a previous `lab*_task*` branch
* Bug fixes between tasks should be cherry-picked between branches, so it is recommended to form small and specific commits
* Cherry pick useful changes into `master`, but this should be discussed first
