#!/bin/bash

echo "UPLOADING TO PHONE"
adb push ./temp/frida-server /data/local/tmp/frida-server
adb shell "su -c 'chmod +x /data/local/tmp/frida-server'"
