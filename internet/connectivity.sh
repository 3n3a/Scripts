#!/bin/bash
#
# Am I connected?
#
# NEEDS:
#    curl

CONN=$(curl -s http://www.msftconnecttest.com/connecttest.txt)
PING=$(ping -c 1 www.msftconnecttest.com | grep time= | sed -E 's/.*time=//gm;t;d')

if [ "$CONN" = "Microsoft Connect Test" ]; then
  echo "You are connected to the Internet"
  echo "PING: $PING"
  exit 0
else
  echo "Your are offline"
  exit 1
fi
