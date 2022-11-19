#!/bin/bash
#
# Am I connected?
#
# NEEDS:
#    curl

CONN=$(curl -s http://www.msftconnecttest.com/connecttest.txt)

if [ "$CONN" = "Microsoft Connect Test" ]; then
  echo "You are connected to the Internet"
  exit 0
else
  echo "Your are offline"
  exit 1
fi
