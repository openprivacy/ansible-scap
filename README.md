# ansible-scap
ansible roles for easy [SCAP](http://scap.nist.gov/) scanning

## Overview
This repository provides a demo of easy SCAP scanning using a Free and Open Source tool chain. SCAP (Security Content Automation Protocol) is a government and enterprise endorsed standard for trustworthy checking of both software configuration and known vulnerabilities.

This demo uses Ansible and Vagrant to create a dashboard server with [GovReady](https://github.com/GovReady/govready) and the [SCAP Security Guide](https://github.com/OpenSCAP/scap-security-guide) installed that runs the [OpenSCAP](https://github.com/OpenSCAP/openscap) scanner against a "remote" server.

Several ansible "roles" (openscap, scap-security-guide, harden, govready) are employed that may be adapted with minor or no modifications for use on local or remote servers.

## Demo Requirements
- [ansible](http://www.ansible.com/)
- [vagrant](https://www.vagrantup.com/)
- [virtualbox](https://www.virtualbox.org/) (default provider)
- Internet access

## Operation
Key:
- *Host* - the machine which is hosting your Vagrant virtual machines (VMs)
- *Dashboard* - the VM that will be running scans on a remote server (IP=192.168.56.101)
- *Server* - the VM that will be scanned and hardened (IP=192.168.56.102)

Run the commands below on the indicated machine. When prompted for a password for the "vagrant" user, enter "vagrant". In practice, SSH keys should be generated on the 'dashboard' and installed on the 'servers' negating the need for password authentication.

### Host: Provision two vagrant machines: dashboard and server
- `vagrant up`

This creates the two VMs and, in addition, an "inventory" file that may be needed in a step below. On most GNU/Linux boxes, this inventory file can be viewed with this command:

- `cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory`

#### Host: Networking fails until... have you turned it off and on again?
Try:
- `ping 192.168.56.101`

If that fails, then do:
- `vagrant halt`
- `vagrant up`

For some reason, this seems to fix the networking. _Magic._

### Dashboard: Run the first scan of 'server'
_Note: The myfisma/GovReadyfile was set up during provisioning._
- `vagrant ssh dashboard`
- `cd myfisma`
- `govready scan`

### Host: Copy your (Host) SSH public key identities to the 'server'
_Note: Your port values may be different - check the vagrant-created inventory file_
- `ssh-copy-id vagrant@localhost -p 2200`
This enables the following 'ansible-playbook' command to run...

### Host: Update audit rules and issue.txt ('harden' role)
_By default this will be part of provision.yml but is separated out here for demo purposes._
- `ansible-playbook -i inventory -l server harden.yml`

### Dashboard: Execute standard remediations suggested by the SSG
- `# govready scan` # optional to view effect of 'harden'
- `govready fix`

### Dashboard: Run a final scan (and compare)
- `govready scan`
- `# govready compare` # not currently working with remote scans

## Results
### Stock CentOS 7 - results from first scan:
_[Full HTML Scan Report](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-1-results.html)_
- This profile identifies 4 high severity selected controls. OpenSCAP says 2 passing, 1 failing, and 1 notchecked.
- This profile identifies 12 medium severity selected controls. OpenSCAP says 5 passing, 6 failing, and 1 notchecked.
- This profile identifies 44 low severity selected controls. OpenSCAP says 7 passing, 35 failing, and 2 notchecked.

### After 'harden' - results from second scan:
_[Full HTML Scan Report](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-2-results.html)_
- This profile identifies 4 high severity selected controls. OpenSCAP says 2 passing, 1 failing, and 1 notchecked.
- This profile identifies 12 medium severity selected controls. OpenSCAP says 5 passing, 6 failing, and 1 notchecked.
- This profile identifies 44 low severity selected controls. OpenSCAP says 33 passing, 9 failing, and 2 notchecked.

### After `govready fix` - results from third scan:
_[Full HTML Scan Report](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-3-results.html)_
- This profile identifies 4 high severity selected controls. OpenSCAP says 2 passing, 1 failing, and 1 notchecked.
- This profile identifies 12 medium severity selected controls. OpenSCAP says 11 passing, 0 failing, and 1 notchecked.
- This profile identifies 44 low severity selected controls. OpenSCAP says 39 passing, 3 failing, and 2 notchecked.

#### Notes on the four fails in the final report:
- Two fails (CCE-26967-0 & CCE-26971-2) are due to `/var/log/` and `/var/log/audit/` not being located on a separate partition.
- One fail (CCE-26957-1) is because the Red Hat GPG Key Installed (a holdover from RHEL).
- One fail (CCE-RHEL7-CCE-TBD) results from recent changes to the audit rules regarding the use of privileged commands.

## Glossary:
- CCE - [Common Configuration Enumeration](https://nvd.nist.gov/cce/index.cfm)
- SCAP - [Security Content Automation Protocol](http://scap.nist.gov/)
- SSG - [SCAP Security Guide](https://fedorahosted.org/scap-security-guide/)

#### Afterword

Now that I understand SCAP and vulnerability scanning in general, I expect that every server I deploy to the InterWebs will have OpenSCAP installed and running for my piece of mind. All that remains is the creation of new content that will provide configuration and vulnerability testing of the sundry applications and operating systems that I will be using.

This project is licensed under the GPL v3.

Work on this project has been supported by [CivicActions, Inc.](https://www.civicactions.com/)
