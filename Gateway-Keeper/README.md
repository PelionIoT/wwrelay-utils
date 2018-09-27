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
./prepare.sh
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
GK> upgradeAllRelays [version number]
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
GK> upgradeRelay [version number] WDRL00000M
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
send upgrade status for WDRL00000M...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 71  259M   71  184M    0     0  77907      0  0:58:07  0:41:24  0:16:42 79550
=============================================================
send upgrade status for WDRL00000K...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 42  259M   42  108M    0     0  45980      0  1:38:28  0:41:24  0:57:04 29124
=============================================================
send upgrade status for WDRL00000V...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 47  259M   47  122M    0     0  51773      0  1:27:27  0:41:25  0:46:03 62647
=============================================================
send upgrade status for WDRP000001...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 38  259M   38 99.6M    0     0  49256      0  1:31:55  0:35:19  0:56:36 76625
=============================================================
send upgrade status for WDRL00003C...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 37  259M   37 98.1M    0     0  41371      0  1:49:26  0:41:25  1:08:01 41559
=============================================================
send upgrade status for WDRP000001...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 49  259M   49  129M    0     0  54446      0  1:23:09  0:41:24  0:41:46 61533
=============================================================
send upgrade status for WDRL000038...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 37  259M   37 96.4M    0     0  40699      0  1:51:15  0:41:24  1:09:50 35547
=============================================================

```

## getUpgrade
check a particular relays upgrade status 

```
GK> getUpgrade WDRP000001
send upgrade status for WDRP000001...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  6  259M    6 17.4M    0     0   246k      0  0:17:57  0:01:12  0:16:45  283k
 =============================================================

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
