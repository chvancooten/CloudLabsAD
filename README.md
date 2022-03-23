# Cloud Labs AD

_By [@chvancooten](https://twitter.com/chvancooten), Ansible role for Elastic Security deployment by [@nodauf](https://twitter.com/nodauf)_

Provisioning scripts for an Active Directory lab environment. Designed to be deployed to Azure using the Azure cloud shell.

## Setup

The lab is provisioned automatically using Terraform and Ansible. First, Terraform deploys all the infrastructure and prepares the machines for provisioning. It then kicks off a role-based Ansible playbook from the Debian attacker machine to provision the Windows-based machines.

**In the default setup, the lab takes approximately 15-20 minutes to provision, and costs about €1 per day to run on Azure.**

### Deployment

- Clone the repo to your Azure cloud shell. It conveniently has all you need (Terraform and an authenticated Azure provider). Alternatively, install and configure Terraform and the Azure provider yourself. Ansible is installed automatically as part of the provisioning process.
- Copy `terraform.tfvars.example` to `terraform.tfvars` in the `Terraform` directory, and configure the variables appropriately.
- In the same directory, run `terraform init`.
- When you're ready to deploy, run `terraform apply` (or `terraform apply --auto-approve` to skip the approval check).

Once deployment and provisioning have finished, the output variables (public IP / DNS name, administrative passwords, machine names, etc.) will be displayed. You are now ready to connect to the labs!

### Post-Deployment Configuration

- If you want to use ADCS, you have to RDP to the DC and follow the post-deployment configuration steps to activate ADCS and the ADCS web enrolment endpoint. Make sure to enable the 'Certification Authority', 'Certification Authority Web Enrollment', and 'Certificate Enrollment Web Service' role services (you can leave the default settings otherwise).

### Removal

- When you're done with the labs, run `terraform destroy` to tear down the environment.

## Labs

![Lab overview](assets/labs.png)

The labs consist of a selection of machines:

- Windows Server 2016 DC
    - Active Directory Certificate Services (ADCS) installed
- Windows Server 2019
    - Internet Information Services (IIS) web server with simple vulnerable app
- Windows 10 client
- Debian box with Elastic Endpoint Security
    - Elastic Agent is deployed to all Windows machines via Fleet
- Debian attacker box

One public IP is exposed for the whole lab. The IP ranges defined in the `ip-whitelist` are allowed to access the following ports on this IP address, which are bound to the following services using a load balancer:

- Port 22   -> Attacker machine SSH
- Port 80   -> Windows Server 2019 IIS web server with vulnerable page
- Port 3389 -> Windows 10 Client RDP

Another public IP is used for outbound Internet connectivity for all lab machines.

## Wishlist

At a later point I might add the following:
- Advanced logging configs on Windows
- Exchange Server + Microsoft Office on Win10 machine
