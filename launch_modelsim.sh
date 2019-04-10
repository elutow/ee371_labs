#!/bin/bash -eux

# To be executed on host, using container

_current_dir=$(dirname $(readlink -f $0))
_relative_path=$(realpath -e --relative-to=$(readlink -f ~/VMTMP) $_current_dir)

if [[ $_relative_path == ..* ]]; then
	printf 'ERROR: Path is not inside %s: %s\n' "~/VMTMP" "$_relative_path"
	exit 1
fi

~/core/scripts/containers/debianquartus64_cmd.sh "/vmtmp/$_relative_path" 'LD_LIBRARY_PATH=/home/wineuser/intelFPGA_lite/lib32' '/home/wineuser/intelFPGA_lite/18.1/modelsim_ase/linuxaloem/vsim'
