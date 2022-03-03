# Cloud Labs AD

Provisioning scripts for an Active Directory lab environment. Designed to be deployed to Azure using the Azure cloud shell. Very alpha.

## Setup

## Labs

The idea is as follows:

- Windows Server 2016 DC
- Windows Server 2019
    - ADCS enabled
    - IIS with simple vuln application (webshell?)
- Windows 10 Client
    - Defender and logging best practices enabled (sysmon?)
    - Some EDR?
- Debian attacker box

At a later point I might add the following:
- Exchange

## Access

One public IP is exposed for the whole lab. The IP ranges defined in the `ip-whitelist` are allowed to access the following ports on this IP address, which are bound to the following:

- Port 22   -> Debian attacker box SSH
- Port 80   -> Windows Server 2019 IIS web server
- Port 3389 -> Windows 10 Client RDP