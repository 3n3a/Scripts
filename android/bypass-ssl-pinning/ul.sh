#!/bin/bash

echo "UPLOADING TO PHONE"
adb push ./temp/frida-server /data/local/tmp/frida-server
adb shell

