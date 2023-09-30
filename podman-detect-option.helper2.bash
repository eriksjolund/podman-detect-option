#!/bin/bash

set -o errexit
set -o nounset

tmpdir=$(mktemp -d)

# non-root uidgids in container
find . -printf '%U:%G\n' | grep -v '^0:0' | sort -u > "$tmpdir/container.uidgids.txt"

# non-root uidgids in volumes
index=0
for i in $(podman volume list --noheading --format "{{range .}}\t{{.Name}}\n{{end -}}"); do
  dir=$(podman volume mount "$i")
  cd "$dir"
  find . -printf '%U:%G\n' | grep -v '^0:0' | sort -u > "$tmpdir/volume${index}.uidgids.txt"
  index=$((index+1))
done

# if there is only one unique uidgid, print it as a --userns=keep-id:uid=$uid,gid=$gid
num_uidgids=$(cat "$tmpdir"/* | sort -u | wc -l)

if [ $num_uidgids -eq 1 ]; then
  argument_ending=$(cat "$tmpdir"/* | sort -u | sed s/:/,gid=/)
  echo "--userns=keep-id:uid=$argument_ending"
fi
