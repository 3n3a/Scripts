#!/bin/bash
#
# Get archived repos and transfer for USERS
#

from="$1"
to="$2"
path="/tmp/repos-$from.txt"

if [[ -z "$from" || -z "$to" ]]; then
	echo -e "Please use this command as follows:\n\t./transfer.sh [FROM] [TO]\n"
	exit 1
fi

echo "Transferring from $from to $to"

./get-archived-repos.sh -n "$from" -f "$path"

echo "The following repos will be transferred: "
cat "$path"
echo ""

read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# do transfer
echo "Starting Transfer..."
./bulk-transfer.sh -f "$path" -o "$from" -n "$to" > repo-transfer-$from-$to.log 2>&1
