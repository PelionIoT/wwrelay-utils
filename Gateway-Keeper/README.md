# Gateway keeper
control and upgrade all gateways in local network

# Prerequisite
install expect and arp-scan using

# Install
```
git clone wwrelay Repo
cd  Gateway-keeper
```
```
npm install
```

# Run
start server it will open a repl prompt to excute command on it

```
node index.js
```

now send relayClient script to all of the gateways in local netwrok using other terminal  

```
sudo ./start.sh username userIP password build
```

# Command
## getAllRelays
it will return all the connected gateways to the server

``` 
GK> getAllRelays
{
    "relayID": "WDRL00000M",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.116"
}
{
    "relayID": "WDRL00000K",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.118"
}
{
    "relayID": "WDRP000001",
    "cloudURL": "https://india.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.119"
}
{
    "relayID": "WDRL000038",
    "cloudURL": "https://devcloud.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.113"
}
{
    "relayID": "WDRL00000V",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.117"
}
{
    "relayID": "WDRL00003C",
    "cloudURL": "https://demo.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.115"
}
{
    "relayID": "WDRP000001",
    "cloudURL": "https://demo.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.112"
}

```

## getRelay
it will return a particular relayInfo

```
GK> getRelay WDRL00000V
{
    "relayID": "WDRL00000V",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.365",
    "IP": "192.168.0.117"
}
```

## upgradeAllRelays 
it will start to upgrade all the relays in local netwrok 

```
GK> upgradeAllRelays
starting upgrade for WDRL00000M
starting upgrade for WDRP000001
starting upgrade for WDRL00000K
starting upgrade for WDRL000038
starting upgrade for WDRP000001
starting upgrade for WDRL00003C
starting upgrade for WDRL00000V

```


## upgradeRelay
start a relay upgrade 

```
GK> upgradeRelay WDRL00000M
starting upgrade for WDRL00000M

```

## led

```
GK> led WDRL00000M
OK
Look at the relay

```


## restartAllMaestro

```
GK> restartAllMaestro
OK
Look at the relay

```

## restartMaestro

```
GK> restartMaestro WDRL00000M
OK
Look at the relay

```

## getAllUpgrade
check the upgrade status of all the relays

```
GK> getAllUpgrade
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  1  259M    1 3439k    0     0  64306      0  1:10:24  0:00:54  1:09:30 88650
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0  259M    0 1743k    0     0  32586      0  2:18:57  0:00:54  2:18:03 42513
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0  259M    0 2575k    0     0  48345      0  1:33:39  0:00:54  1:32:45 32781
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0  259M    0 2191k    0     0  40872      0  1:50:46  0:00:54  1:49:52 35758
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0  259M    0 1935k    0     0  36293      0  2:04:45  0:00:54  2:03:51 35016
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  1  259M    1 3135k    0     0  59054      0  1:16:40  0:00:54  1:15:46 62944
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0  259M    0 2335k    0     0  43484      0  1:44:07  0:00:55  1:43:12 57375

```

## getUpgrade
check a particular relays upgrade status 

```GK> getUpgrade WDRL00000M
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  1  259M    1 3439k    0     0  64306      0  1:10:24  0:00:54  1:09:30 88650
  ```

## killAllUpgrade
stop downloading upgrade to all relays

```
GK> killAllUpgrade
upgrade process killed.
upgrade process killed.
upgrade process killed.
upgrade process killed.
upgrade process killed.
upgrade process killed.
upgrade process killed.
f.tar.gz removed.
f.tar.gz removed.
f.tar.gz removed.
f.tar.gz removed.
f.tar.gz removed.
f.tar.gz removed.
f.tar.gz removed.

```


## killUpgrade
stop upgrading a relays

```
GK> killUpgrade WDRL00000M
upgrade process killed.
f.tar.gz removed.

```
