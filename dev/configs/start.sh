#!/bin/bash
#
# start devcontainer
#

sudo devpod provider add docker
sudo devpod provider use docker
sudo devpod context set-options -o EXIT_AFTER_TIMEOUT=false
sudo devpod up "/home/$USER/repos" --id default --devcontainer-path "./Scripts/dev/configs/devcontainer.json"
