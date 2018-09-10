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

## upgradeRelay

## led

## restartAllMaestro

## restartMaestro

## getAllUpgrade

## getUpgrade

## killAllUpgrade

## killUpgrade
