#!/bin/bash
#
# Create Firefox User Profile
#
# Generate a "custom" firefox with separated storage for cookies etc...
#
# PARAMETERS:
#   name    -   name of the custom install
# 
# SOURCES:
#   Debian Firefox Installation (non-ESR):    https://wiki.debian.org/Firefox
#
# AUTHOR:
#   3n3a
#

FF_INSTALL="/opt/firefox"
FF_PROFILES="/opt/firefox-profiles"
DESKTOP_FILES="/usr/share/applications"
TEMP_FOLDER="/tmp/ff-create"

FF_NAME="$1"

if [[ -z "$FF_NAME" ]]; then
	echo -e "Use this script as follows: $0 <NAME>\n\nPARAMETERS:\n\tname\t\tName of the custom install (only letters)\n\nINTERNAL VARIABLES:\n\tFirefox Installation\t$FF_INSTALL\n\tFirefox Profiles\t$FF_PROFILES\n\t.Desktop Files\t\t$DESKTOP_FILES\n"
	exit 1
fi

echo "STARTUP FIREFOX CREATE"
mkdir -p $TEMP_FOLDER

CUSTOM_P_PATH="$FF_PROFILES/$FF_NAME"
CUSTOM_P_STARTUP="-new-instance -profile \"$CUSTOM_P_PATH\""
CUSTOM_P_DESKTOP="$DESKTOP_FILES/firefox-stable-$FF_NAME.desktop"
CUSTOM_P_DESK_TEMP="$TEMP_FOLDER/$FF_NAME"

echo "CREATING PROFILE \"$FF_NAME\""
sudo mkdir -p $CUSTOM_P_PATH
sudo chown $USER -R $CUSTOM_P_PATH
bash -c "$FF_INSTALL/firefox -no-remote -CreateProfile \"$FF_NAME $CUSTOM_P_PATH\""


echo "CREATING DESKTOP ICON"
cat <<EOF > $CUSTOM_P_DESK_TEMP
[Desktop Entry]
Name=Firefox Stable [$FF_NAME]
Comment=Web Browser
Exec=$FF_INSTALL/firefox $CUSTOM_P_STARTUP %u
Terminal=false
Type=Application
Icon=$FF_INSTALL/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Actions=Private;

[Desktop Action Private]
Exec=$FF_INSTALL/firefox --private-window %u
Name=Open in private mode
EOF

sudo mv $CUSTOM_P_DESK_TEMP $CUSTOM_P_DESKTOP

echo "CLEANING UP FIREFOX CREATE"
rm -rf $TEMP_FOLDER
