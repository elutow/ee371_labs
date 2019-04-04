#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Generates the testbench files for ModelSim"""

import argparse
import re
import string
from pathlib import Path

TESTBENCH_DO_FILE = """# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
$testbench_tmpl{includes}

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work $testbench_tmpl{entity}_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do $testbench_tmpl{entity}_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
"""

TESTBENCH_DO_VLOG = 'vlog "{path!s}"'

WAVE_DO_FILE = """onerror {resume}
quietly WaveActivateNextPane {} 0
$testbench_tmpl{signals}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {223 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {0 ps}
"""

WAVE_DO_SIGNAL = "add wave -noupdate /{entity}_testbench/{signal}"

class _StringTemplate(string.Template):
    """
    Custom string substitution class

    Inspired by
    http://stackoverflow.com/questions/12768107/string-substitutions-using-templates-in-python
    """

    pattern = r"""
    {delim}(?:
      (?P<escaped>{delim}) |
      _(?P<named>{id})      |
      {{(?P<braced>{id})}}   |
      (?P<invalid>{delim}((?!_)|(?!{{)))
    )
    """.format(
        delim=re.escape("$testbench_tmpl"), id=string.Template.idpattern)

def generate_wave_do(entity, signals, output_path):
    """Generates *_wave.do file for entity"""
    signal_entries = tuple(
        map(
            (lambda x: WAVE_DO_SIGNAL.format(entity=entity, signal=x)),
            signals))
    content = _StringTemplate(WAVE_DO_FILE).substitute(dict(
        signals='\n'.join(signal_entries),
    ))
    output_path.write_text(content)

def generate_testbench_do(entity, files, output_path):
    """Generates *_testbench.do file for entity"""
    file_entries = tuple(
            map(
                (lambda x: TESTBENCH_DO_VLOG.format(path=x)),
                files))
    content = _StringTemplate(TESTBENCH_DO_FILE).substitute(dict(
        includes='\n'.join(file_entries),
        entity=entity,
    ))
    output_path.write_text(content)

def main():
    """CLI Entrypoint"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        '-e', '--entity', required=True, help='Entity name')
    parser.add_argument(
        '-s', '--signals', required=True, nargs='+',
        help='Signal names to add to wave.do relative to testbench module')
    parser.add_argument(
        '-f', '--files', nargs='+', required=True, type=Path,
        help='(System)Verilog files to include in testbench.do to make testbench run')
    args = parser.parse_args()

    generate_wave_do(args.entity, args.signals, output_path=Path(f'{args.entity}_wave.do'))
    generate_testbench_do(args.entity, args.files, output_path=Path(f'{args.entity}_testbench.do'))

if __name__ == '__main__':
    main()
