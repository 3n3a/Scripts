@echo off

cd c:\tools\libimobiledevice
echo Name of the Device:
idevicename.exe
echo

echo Mounting Developer Image:
ideviceimagemounter.exe diskimages\14.3\DeveloperDiskImage.dmg diskimages\14.3\DeveloperDiskImage.dmg.signature
echo

echo Testing by taking a screenshot
idevicescreenshot test_screenshot.png
explorer test_screenshot.png

@echo on