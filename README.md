# ansible-scap
Ansible roles to demonstrate [SCAP](http://scap.nist.gov/) (Security Controls Automation Protocol) scanning

## Overview
This repository provides a demo of easy SCAP scanning using a Free and Open Source tool chain. SCAP (Security Content Automation Protocol) is a government and enterprise endorsed standard for trustworthy checking of both software configuration and known vulnerabilities.

This demo uses Ansible and Vagrant to create a dashboard (security control center) with [GovReady](https://github.com/GovReady/govready) and the [SCAP Security Guide](https://github.com/OpenSCAP/scap-security-guide) installed that runs the [OpenSCAP](https://github.com/OpenSCAP/openscap) scanner against a "remote" server. The server is "hardened" using default SCAP remediation scripts and the installation of a compliant `audit.rules` file. Drupal can then be installed.

Several ansible "roles" (openscap, scap-security-guide, harden, govready) are employed that may be adapted with minor or no modifications for use on local or remote servers.

Several ansible roles were pulled from ansible-galaxy for the default Drupal installation using:
```
ansible-galaxy install --roles-path=roles geerlingguy.drupal
```

Some files from these roles have been modified to work with CentOS 7.1
- geerlingguy.mysql/vars/RedHat.yml
- geerlingguy.drupal/tasks/drupal.yml
- geerlingguy.drupal/tasks/web.yml
- geerlingguy.drupal/templates/drupal-vhost.conf.j2

## Demo Requirements
- [ansible](http://www.ansible.com/)
- [vagrant](https://www.vagrantup.com/)
- [virtualbox](https://www.virtualbox.org/) (default provider)
- Internet access

## Operation
### Clone this repository
- `git clone https://github.com/openprivacy/ansible-scap.git`
- `cd ansible-scap`

_Note: the "inventory" symlink will be broken until `vagrant up` is run in the first step below._

### Run the commands below on the indicated machine
Key:
- *Host* - the machine which is hosting your Vagrant virtual machines (VMs)
- *Dashboard* - the VM that will be running scans on a remote server (IP=192.168.56.101)
- *Server* - the VM that will be scanned and hardened (IP=192.168.56.102)

When prompted for a password for the "vagrant" user, enter "vagrant". In practice, SSH keys should be generated on the 'dashboard' and installed on the 'servers' negating the need for password authentication.

### Host: Provision two vagrant machines: dashboard and server
- `vagrant up`

This creates the two VMs and, in addition, an "vagrant_ansible_inventory" file that will be used in a step below. On most GNU/Linux boxes, this inventory file can be viewed with this command:

- `cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory`

To simplify access, this repository has a symlink "inventory" that points to the above file.

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
- `govready fix`
- `govready scan`

### After `govready fix` - results from third scan:
_[Full HTML Scan Report](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-3-results.html)_
- This profile identifies 4 high severity selected controls. OpenSCAP says 2 passing, 1 failing, and 1 notchecked.
- This profile identifies 12 medium severity selected controls. OpenSCAP says 11 passing, 0 failing, and 1 notchecked.
- This profile identifies 44 low severity selected controls. OpenSCAP says 40 passing, 2 failing, and 2 notchecked.

#### Notes on the three fails in the final report:
- Two fails (CCE-26967-0 & CCE-26971-2) are due to `/var/log/` and `/var/log/audit/` not being located on a separate partition.
- One fail (CCE-26957-1) is because the Red Hat GPG Key Installed (a holdover from RHEL).

### Host: Copy your (Host) SSH public key identities to the 'server'
_Note: Your port values may be different - check the vagrant-created inventory file_
- `ssh-copy-id vagrant@localhost -p 2200`

This enables the following 'ansible-playbook' command to run...

### Host: Install Drupal (and dependencies git, apache, php, mysql, composer, drush)
- `ansible-playbook -i inventory -u vagrant -l server drupal.yml`

### Host: Ensure that security modules are present, enabled and configured.
- `ansible-playbook -i inventory -u vagrant -l server drupal-security.yml`


## Glossary:
- CCE - [Common Configuration Enumeration](https://nvd.nist.gov/cce/index.cfm)
- SCAP - [Security Content Automation Protocol](http://scap.nist.gov/)
- SSG - [SCAP Security Guide](https://fedorahosted.org/scap-security-guide/)

#### Afterword

Standing on the shoulders of giants, I thank the OpenSCAP, SSG and GovReady developers as well as the entire F/OSS stack they run on (and which I use daily).

Now that I understand SCAP and vulnerability scanning in general, I expect that every server I deploy to the InterWebs will have OpenSCAP installed and running for my piece of mind. All that remains is the creation of new content that will provide configuration and vulnerability testing of the sundry applications and operating systems that I will be using.

This project is licensed under the GPL v3.

Work on this project has been supported by [CivicActions, Inc.](https://www.civicactions.com/)
