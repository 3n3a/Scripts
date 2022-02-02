# Simulate Location of iOS Device

Simulate a GPX Path, extracted using Python, on iOS, with idevicesetlocation from libimobiledevice.

**STILL IN EARLY DEVELOPMENT!!**

## Installation

**Only works on Debian-Like Systems**

You'll have to compile the source code from:

Install the packages needed to run
```bash
sudo apt-get install -yy \
    build-essential \
    checkinstall \
    git \
    autoconf \
    automake \
    libtool-bin \
    libplist-dev \
    libusbmuxd-dev \
    libssl-dev \
    usbmuxd
```

Build the dependencies for libimobiledevice:
```bash
git clone https://github.com/libimobiledevice/libusbmuxd
cd libusbmuxd
./autogen.sh \
    --prefix=/opt/local \
    --enable-debug
make
sudo make install 
```

```bash
git clone https://github.com/libimobiledevice/libplist
cd libplist
./autogen.sh \
    --prefix=/opt/local \
    --enable-debug
make
sudo make install
```

And finally you can build libimobiledevice:
```bash
git clone https://github.com/libimobiledevice/libimobiledevice
./autogen.sh \
    --prefix=/opt/local \
    --enable-debug
make
sudo make install 
```

Installation for Python:
```bash
pip install -r requirements.txt
```

## Usage

```bash
python3 simulate_location --file GPX_FILE
```

Optionally you can add ```--speed FLOAT``` to decrease the time, that the program waits inbetween updating the location.

## Development

### TODO:
- add support for downloading / mounting developer disk images
- verify that device is connected and paired
- option to set static location
- don't use os.system because security

## Troubleshooting

### Can't find shared Library

Try running this as root:
```bash
sudo ldconfig
```