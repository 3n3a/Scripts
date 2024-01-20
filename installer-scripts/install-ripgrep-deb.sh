#!/bin/bash
#
# install latest ripgrep
# 
# for debian based systems
#

user="BurntSushi"
repo="ripgrep"
version=$(curl -fsSL https://api.github.com/repos/$user/$repo/releases/latest | jq -r '.tag_name')

if [ -n "$version" ]; then
	echo "installing version $version of github.com/$user/$repo."
	url="https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep_$version-1_amd64.deb"
	curl -fsSL -o /tmp/install.deb "$url"
	sudo dpkg -i /tmp/install.deb
	rm -f /tmp/install.deb
else
	echo "no version found for github.com/$user/$repo."
fi
