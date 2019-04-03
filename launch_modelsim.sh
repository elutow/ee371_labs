#!/bin/bash -eux

# To be executed on host, using container

~/core/scripts/containers/debianquartus64_cmd.sh '/vmtmp/ee371_labs' 'LD_LIBRARY_PATH=/home/wineuser/intelFPGA_lite/lib32' '/home/wineuser/intelFPGA_lite/18.1/modelsim_ase/linuxaloem/vsim'
