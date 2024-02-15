# bypass ssl pinning android apps

source: [MEDIUM.COM - Easy Way to Bypass SSL Pinning with Objection & Frida [Beginner Friendly]](https://petruknisme.medium.com/easy-way-to-bypass-ssl-pinning-with-objection-frida-beginner-friendly-58118be4094)

## setup

### install deps

for linux see here:

```sh
pip3 install frida-tools objection
# or
pip install frida-tools objection
```

### setup frida-server on android

> IMPORTANT: the installed "frida" package (NOT frida-tools) and the "frida-server" need to have the SAME version.

navigate to: https://github.com/frida/frida/releases

and download the file "frida-server-VERSION_HERE-android-arm.xz"

> TIP: you may need to click "show all assets"

**download extract push to phone**

```sh
version="16.1.11"

echo "GETTING FRIDA-SERVER"
wget "https://github.com/frida/frida/releases/download/$version/frida-server-$version-android-arm64.xz"
xz -d "frida-server-$version-android-arm64.xz"
ls | grep frida
mv frida-server-$version-android-arm64 frida-server

echo "UPLOADING TO PHONE"
adb push frida-server /data/loca/tmp
adb shell
```

then enter the following in the shell

```sh
su
cd /data/local/tmp
chmod +x frida-server
./frida-server &
ps | grep frida # indicates if running
```

now frida-server should be up and running

### setup objection

test if works

```sh
objection --gadget "com.android.settings" device-type
```

it should say `Agent injected and responds ok!`



