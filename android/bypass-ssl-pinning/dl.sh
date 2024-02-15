#!/bin/bash

version="16.1.11"

echo "GETTING FRIDA-SERVER"
wget "https://github.com/frida/frida/releases/download/$version/frida-server-$version-android-arm64.xz"
xz -d "frida-server-$version-android-arm64.xz"
ls | grep frida
mv frida-server-$version-android-arm64 ./temp/frida-server
