# Cloud Labs AD

Provisioning scripts for an Active Directory lab environment. Designed to be deployed to Azure using the Azure cloud shell. Very alpha.

## Setup

### Deployment

- Clone the repo to your Azure cloud shell. It conveniently has all you need (Ansible, Terraform, authenticated Azure command line).
- Copy `terraform.tfvars.example` to `terraform.tfvars` in the `Terraform` directory, and configure the variables appropriately
- Add the private key for the specified `public-key` to SSH-agent (``eval `ssh-agent`; ssh-add ~/.ssh/id_rsa``)
- In the same directory, run `terraform init`
- When you're ready to deploy, run `terraform apply` (or `terraform apply --auto-approve` to skip the approval check)

### Removal

- When you're done with the labs, run `terraform destroy` to tear down the environment

## Labs

The idea is as follows:

- Windows Server 2016 DC
    - ADCS enabled
- Windows Server 2019
    - IIS with simple vuln application (webshell?)
- Windows 10 Client
    - Defender and logging best practices enabled (sysmon?)
    - Some EDR?
- Debian attacker box

At a later point I might add the following:
- Exchange + Office on Win10 desktop?

## Access

One public IP is exposed for the whole lab. The IP ranges defined in the `ip-whitelist` are allowed to access the following ports on this IP address, which are bound to the following:

- Port 22   -> Debian attacker box SSH
- Port 80   -> Windows Server 2019 IIS web server
- Port 3389 -> Windows 10 Client RDP