#!/bin/bash

echo "UPLOADING TO PHONE"
adb push frida-server /data/loca/tmp
adb shell

