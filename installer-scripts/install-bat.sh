#!/bin/sh

# Install Bat (cat(1)) on Linux
# by 3n3a
#
# [2022/09/15]: Init Script

version="v0.22.1"
url="https://github.com/sharkdp/bat/releases/download/$version/bat-$version-x86_64-unknown-linux-gnu.tar.gz"

# Make Temp Dir
cd /tmp
mkdir -p installBat
cd installBat

# Download and Extract file
wget $url
tar xvf bat-*
cd "bat-$version-x86_64-unknown-linux-gnu"

# Install Binary
sudo mv bat /usr/local/bin

echo "Installed Bat Version $version"

# Cleanup
rm -rf /tmp/installBat
