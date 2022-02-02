@echo off

cd \
mkdir tools
cd tools
mkdir libimobiledevice
cd libimobiledevice
curl https://github.com/libimobiledevice-win32/imobiledevice-net/releases/download/v1.3.14/libimobiledevice.1.2.1-r1116-win-x64.zip -L -o libimobile_win.zip
tar -xf libimobile_win.zip
del libimobile_win.zip

mkdir diskimages
cd diskimages
curl https://github.com/haikieu/xcode-developer-disk-image-all-platforms/raw/master/DiskImages/iPhoneOS.platform/DeviceSupport/14.3.zip -L -o 14.3.zip
tar -xf 14.3.zip
del 14.3.zip

cd \tools

@echo on