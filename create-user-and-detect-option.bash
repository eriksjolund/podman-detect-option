#!/bin/bash

set -o errexit
set -o nounset

script=$1
helperscript=$2
user=$3

# seconds to wait before checking the ownership of created files
seconds=$4

# remove unneeded arguments from $@
shift
shift
shift
shift

useradd "$user"

systemd-run -M "${user}@" \
  --user \
  --collect \
  --pipe \
  --quiet \
  --wait \
  -- \
 bash "$script" "$helperscript" "$seconds" "$@"
