# Gateway keeper
Control and upgrade all gateways in local network

## Prerequest
Always run in super user mode


## Install
```
git clone https://github.com/WigWagCo/wwrelay-utils.git
cd wwrelay-utils
git checkout development
cd Gateway-keeper
npm install
```

## Run
Start server it will open a repl prompt to excute command on it. you can start it with two way
- When there is on buil file in your repo

```
sudo ./index.sh [Build_version_number]
```
- When you alraedy have a build file in repo

```
sudo ./index.sh
```

Send relayClient script to all of the gateways in local netwrok using other terminal  

```
GK> uploadClientToGW
```

## Command
### getAllRelays
It will return all the connected gateways to the server

``` 
GK> getAllRelays                                                                                                                                                                                            
{                                                                                                                                                                                                           
    "relayID": "WDRP000001",                                                                                                                                                                                
    "cloudURL": "https://india.wigwag.io",                                                                                                                                                                  
    "build": "102.0.380",                                                                                                                                                                                   
    "IP": "10.10.140.26"                                                                                                                                                                                    
}                                                                                                                                                                                                           
{                                                                                                                                                                                                           
    "relayID": "WDRL000038",                                                                                                                                                                                
    "cloudURL": "https://devcloud.wigwag.io",
    "build": "102.0.377",
    "IP": "10.10.140.238"
}
{
    "relayID": "WDRL00000V",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.377",
    "IP": "10.10.140.64"
}
{
    "relayID": "WWRL000002",
    "cloudURL": "https://gateways-wigwag-int.mbedcloudintegration.net",
    "build": "102.0.380",
    "IP": "10.10.140.28"
}
{
    "relayID": "WDRL00000N",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.378",
    "IP": "10.10.140.79"
}
```

### getRelay
It will return a particular relayInfo

```
GK> getRelay WDRL00000N
{
    "relayID": "WDRL00000N",
    "cloudURL": "https://dev.wigwag.io",
    "build": "102.0.378",
    "IP": "10.10.140.79"
}
GK> getRelay WWRL000001
{
    "relayID": "WWRL000001",
    "cloudURL": "https://gateways-wigwag-int.mbedcloudintegration.net",
    "build": "102.0.380",
    "IP": "10.10.140.27"
}

```

### upgradeAllRelays 
It will start to upgrade all the relays in local netwrok 

```
GK> upgradeAllRelays [version number] [cloudbasename]
starting upgrade for WDRL00000M
starting upgrade for WDRP000001
starting upgrade for WDRL00000K
starting upgrade for WDRL000038
starting upgrade for WDRP000001
starting upgrade for WDRL00003C
starting upgrade for WDRL00000V

```


### upgradeRelay
Start a relay upgrade 

```
GK> upgradeRelay [version number] WDRL00000M
starting upgrade for WDRL00000M

```

### led

```
GK> led WDRL00000M
OK
Look at the relay

```


### restartAllMaestro

```
GK> restartAllMaestro
OK
Look at the relay

```

### restartMaestro

```
GK> restartMaestro WDRL00000M
OK
Look at the relay

```

### upgradeAllRelaysWithUrl
Check the upgrade status of all the relays

```
GK> upgradeAllRelaysWithUrl
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

## upgradeRelayWithUrl
Check a particular relays upgrade status 

```
GK> upgradeRelayWithUrl WDRP000001
send upgrade status for WDRP000001...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  6  259M    6 17.4M    0     0   246k      0  0:17:57  0:01:12  0:16:45  283k
 =============================================================

  ```

### killAllUpgrade
Stop downloading upgrade to all relays

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


### killUpgrade
Stop upgrading a relays

```
GK> killUpgrade WDRL00000M
upgrade process killed.
f.tar.gz removed.

```

### upgradeGateway
Copy a build from your system to gateway and upgrade

```
GK> upgradeGateway [all/relayID] [all/cloudbasename] [build_version]
      [RESULT OF expect-ssh-copy.sh]
```

### downloadBuild 

``` 
GK> downloadBuild 102.0.313
[sudo] password for bhoopesh: 
[ Downloading Build                                        ......... 99% 15.7M 1s ]
Downloading finished
```
for downloading arm build

``` 
GK> downloadBuild 102.0.380 arm
[ Downloading Build                                        ......... 99% 15.7M 1s ]
Downloading finished
```
### clearBuild
```
GK> clearBuild
Build folder is clean.
```

## Help Command
Add `-h` , `--h`, `--help` or '-help' after command for help

### Example

```
GK> getAllRelays -h
getAllRelays 
         Usage: 
                 getAllRelays 
                 Example: getAllRelays 
         Description: 
                 it returns a object with relayID, cloudURL, build_version and IP
```