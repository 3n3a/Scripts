#!/bin/bash

set -x

arch=$(uname -m)
go_arch="amd64"

if [[ "$arch" -eq "armv7l" ]]; then
  go_arch="armv6l"
elif [[ "$arch" -eq "aarch64" ]]; then
  go_arch="arm64"
fi

mkdir -p /tmp/go-install
cd /tmp/go-install
curl -fsSL --output go.tar.gz "https://go.dev/dl/$(curl "https://go.dev/VERSION?m=text" | head -n 1).linux-${go_arch}.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local/ -xzf go.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile
source /etc/profile
cd ~
rm -rf /tmp/go-install