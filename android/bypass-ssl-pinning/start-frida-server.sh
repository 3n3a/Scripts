#!/bin/bash
# start frida on android

adb shell "su -c 'cd /data/local/tmp/ && ./frida-server'"
