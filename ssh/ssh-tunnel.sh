#!/bin/bash
#
# SSH Tunnel Script
#
# Author: 3n3a
#
# Usage:
#  ./ssh-tunnel.sh <host/user@host/alias> <remote port> <local port>
#

host="$1"
remote_port="$2"
local_port="$3"

# -f => go backtground
# -N => Not Interactive
# -T => pseudo tty (non interactive)
# -L => answer on local side (server => local)
# -R => answer on remote side (local => server)
ssh -fNTL "$local_port:localhost:$remote_port" "$host"

echo "Forwarded Service now Available under http://localhost:$local_port"
