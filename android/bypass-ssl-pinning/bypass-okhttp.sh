#!/bin/bash

identifier="$1"
frida -U -l ./ssl-error.js -p $(bash ./get-pid.sh $identifier) 
