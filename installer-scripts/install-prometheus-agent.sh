#!/bin/bash
#
# INSTALL PROMETHEUS
#
# Command:
# curl -fsSL -o- https://raw.githubusercontent.com/3n3a/Scripts/master/installer-scripts/install-prometheus-agent.sh | sudo bash
set -x

arch=$(uname -m)
use_arch="amd64"
if [ "$arch" == "armv7l" ]; then
  use_arch="armv6l"
elif [ "$arch" == "aarch64" ]; then
  use_arch="arm64"
fi

prometheus_exporter_version="1.7.0"
prometheus_exporter_file="node_exporter-$prometheus_exporter_version.linux-$use_arch.tar.gz"
prometheus_exporter_folder="node_exporter-$prometheus_exporter_version.linux-$use_arch"
prometheus_exporter_url="https://github.com/prometheus/node_exporter/releases/download/v$prometheus_exporter_version/$prometheus_exporter_file"
dir="/tmp/install-prometheus"

mkdir -p $dir
cd $dir

echo "Getting node_exporter file..."
wget $prometheus_exporter_url
tar -xf $prometheus_exporter_file

echo "Installing node_exporter binary..." 
sudo mv $prometheus_exporter_folder/node_exporter /usr/local/bin

echo "Cleaning up temporary folder..."
cd ~
rm -rf $dir

echo "Creating node_exporter user..."
sudo useradd -rs /bin/false node_exporter

echo "Creating node_exporter Service Config..."
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo "Activating node_exporter Service..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
