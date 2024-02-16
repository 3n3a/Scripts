# bypass ssl sbb.app

## do

### setup

* rooted android (with magisk)
* proxy configured (current ip port 8080)

setup frida-server

```bash
# setup environment
./deps.sh

# download locally
./dl.sh

# uploaded to phone
./ul.sh
```

### start proxy server

locally

```bash
tmux

# then
./proxy.sh
```

### start server

start "frida-server" on device

```bash
tmux -c "./start-frida-server.sh"
```

### start bypass general

```bash
tmux

# then run with app identifier
./bypass-ssl-general.sh ch.sbb.mobile.android.b2c
```

### start bypass okhttp

```bash
tmux

# then run this
./bypass-okhttp.sh ch.sbb.mobile.android.b2c
```
