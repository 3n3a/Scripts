#!/bin/bash
# start frida on android

adb shell "su -c 'killall frida-server && cd /data/local/tmp/ && ./frida-server'"
