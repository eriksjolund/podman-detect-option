#!/bin/bash

set -o errexit
set -o nounset

helperscript2=$1
seconds=$2

# remove unneeded argument from $@
shift
shift
extra=$$

ctr=$(podman create "$@")

podman start "$ctr"

sleep "$seconds"

upperdir=$(podman container inspect "$ctr" -f '{{ .GraphDriver.Data.UpperDir }}')

cd "$upperdir"
podman unshare bash "$helperscript2"
