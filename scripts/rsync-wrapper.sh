#!/usr/bin/env bash

# This script was taken from here:
# https://git.samba.org/?p=rsync.git;a=blob_plain;f=support/rsync-no-vanished;hb=HEAD
# The purpose is to prevent an error occurring when rsync returns a non-zero
# exit code when a file 'vanishes', i.e., it was on the initial transfer list,
# but in the mean time was deleted. It's possible for this to happen when
# transferring node logs. They don't provide any argument on rsync to not treat
# the warning as an error and instead this script is recommended. Not sure why.

REAL_RSYNC=/usr/bin/rsync
IGNOREEXIT=24
IGNOREOUT='^(file has vanished: |rsync warning: some files vanished before they could be transferred)'

# If someone installs this as "rsync", make sure we don't affect a server run.
for arg in "${@}"; do
  if [[ "$arg" == "--server" ]]; then
    exec $REAL_RSYNC "${@}"
    exit $? # Not reached
  fi
done

set -o pipefail

echo "Running rsync as: $REAL_RSYNC ${@}"

# This filters stderr without merging it with stdout:
{ $REAL_RSYNC "${@}" 2>&1 1>&3 3>&- | grep -E -v "$IGNOREOUT"; ret=${PIPESTATUS[0]}; } 3>&1 1>&2

if [[ $ret == $IGNOREEXIT ]]; then ret=0; fi
exit $ret
