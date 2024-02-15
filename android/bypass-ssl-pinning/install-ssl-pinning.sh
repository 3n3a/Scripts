#!/bin/bash

cd temp
wget https://github.com/httptoolkit/android-ssl-pinning-demo/releases/download/v1.4.0/pinning-demo.apk
adb install pinning-demo.apk
cd ..
