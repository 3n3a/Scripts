#!/bin/bash
#
# Am I connected?
#
# NEEDS:
#    python3
#    curl

connected=$(python3 -c "import sys; print('$(curl -s http://www.msftconnecttest.com/connecttest.txt)' == 'Microsoft Connect Test')")

if [[ "$connected" -eq "True" ]]; then
  echo "You are connected to the Internet"
  exit 0
else
  echo "Your are offline"
  exit 1
fi
