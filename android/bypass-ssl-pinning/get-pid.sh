#!/bin/bash
frida-ps -Uiaj | jq --arg needle "$1" '.[] | select(.identifier == $needle) | .pid'
