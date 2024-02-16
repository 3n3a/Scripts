#!/bin/bash

set -x

arch=$(uname -m)
go_arch="amd64"
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)

if [ "$arch" == "armv7l" ]; then
  go_arch="armv6l"
elif [ "$arch" == "aarch64" ]; then
  go_arch="arm64"
fi

mkdir -p /tmp/go-install
cd /tmp/go-install
curl -fsSL --output go.tar.gz "https://go.dev/dl/${go_version}.linux-${go_arch}.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local/ -xzf go.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile
source /etc/profile
cd ~
rm -rf /tmp/go-install
