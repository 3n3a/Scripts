# script to unpack language pack of LibreOffice into macOS-installation
#
# by 3n3a

out_path="/Applications/LibreOffice.app"
in_path="/Volumes/LibreOffice de Language Pack/LibreOffice Language Pack.app/Contents/Resources/tarball.tar.bz2"

echo "Starting the Installation Process of LanguagePackLibreOffice DE"
tar -C $out_path -xjf "$in_path"
touch "$out_path/Contents/Resources/extensions"

echo "Finished Installation of Lang Pack"

echo ""

echo "Making Sure that LibreOffice.app is executable\Please enter 
password if needed."

sudo xattr -r -d com.apple.quarantine /Applications/LibreOffice.app
