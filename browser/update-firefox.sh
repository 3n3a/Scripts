#!/bin/bash
#
# Update Custom Firefox Install/Update
#
# AUTHOR:
#   3n3a
#

FF_DOWNLOAD_BASE="https://download.mozilla.org"
FF_DOWNLOAD_PRODUCT="firefox-latest-ssl"
FF_DOWNLOAD_OS="linux64"
FF_DOWNLOAD_LANG="en-US"
FF_LATEST_URL="$FF_DOWNLOAD_BASE/?product=$FF_DOWNLOAD_PRODUCT&os=$FF_DOWNLOAD_OS&lang=$FF_DOWNLOAD_LANG"

FF_INSTALL_PATH="/opt/firefox"
FF_BACKUP_PATH="/opt/firefox-backups"
TEMP_DIR="/tmp/ff-updater"

echo "SETTING UP FIREFOX UPDATER"
mkdir -p $TEMP_DIR

echo "INITIALIZING INSTALL DIRECTORY"
sudo mkdir -p $FF_INSTALL_PATH

echo "DOWNLOADING FIREFOX..."
curl -fsSL -o "$TEMP_DIR/firefox.tar.bz2" $FF_LATEST_URL

echo "UNPACKING FIREFOX..."
(cd $TEMP_DIR && tar xvf firefox.tar.bz2)

echo "SMOKETEST NEW VERSION..."
bash -c "$TEMP_DIR/firefox/firefox --version"

echo "UPDATE VERSION..."

echo "BACKING UP CURRENT VERSION"
CUSTOM_FF_BACKUP="$FF_BACKUP_PATH/firefox_old_$(date -I)"
sudo mkdir -p $CUSTOM_FF_BACKUP

# move the old version to backup
sudo mv $FF_INSTALL_PATH "$FF_BACKUP_PATH/firefox_old_$(date -I)"

echo "UPGRADING TO NEW VERSION"
# copy over the new version
sudo mv "$TEMP_DIR/firefox" $FF_INSTALL_PATH

echo "CLEANUP FIREFOX UPDATER"
rm -rf $TEMP_DIR
