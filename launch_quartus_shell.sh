#!/bin/bash

# To be executed on host, using container

_current_dir=$(dirname $(readlink -f $0))
_relative_path=$(realpath -e --relative-to=$(readlink -f ~/VMTMP) $_current_dir)

if [[ $_relative_path == ..* ]]; then
	printf 'ERROR: Path is not inside %s: %s\n' "~/VMTMP" "$_relative_path"
	exit 1
fi

QUARTUSCMD_START_DIR="/vmtmp/$_relative_path" ~/core/scripts/containers/debianquartus64_quartuscmd.sh bash
