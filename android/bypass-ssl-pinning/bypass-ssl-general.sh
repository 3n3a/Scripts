#!/bin/bash

app="$1"
objection --gadget "$1" explore -s "android sslpinning disable"
