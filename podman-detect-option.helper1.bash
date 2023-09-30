#!/bin/bash

set -o errexit
set -o nounset

helperscript2=$1
seconds=$2

# remove unneeded argument from $@
shift
shift
extra=$$

podman run --name "test${extra}" --detach "$@"

sleep "$seconds"

upperdir=$(podman container inspect "test${extra}" -f '{{ .GraphDriver.Data.UpperDir }}')

cd "$upperdir"
podman unshare bash "$helperscript2"
