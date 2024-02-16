#!/bin/bash

# debian
echo "INSTALLLING DEBIAN..."
sudo apt install -y fastboot adb python3

# create venv
# python3 -m venv venv

# python
echo "INSTALLING PYTHON..."
source venv/bin/activate
pip install frida-tools
pip install -U objection
