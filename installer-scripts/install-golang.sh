#install go

arch=$(uname -m)
go_arch="amd64"

if [ arch -eq "armv7l" ]; then
  go_arch="armv6l"
fi

mkdir -p /tmp/go-install
cd /tmp/go-install
curl -fsSL --output go.tar.gz "https://go.dev/dl/$(curl "https://go.dev/VERSION?m=text").linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local/ -xzf go.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile
source /etc/profile
cd ~
rm -rf /tmp/go-install