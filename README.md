# ansible-scap
ansible roles for easy [SCAP](http://scap.nist.gov/) scanning

## Overview

This demo directory uses Vagrant to create a dashboard server with [GovReady](https://github.com/GovReady/govready) and the [SCAP Security Guide](https://github.com/OpenSCAP/scap-security-guide) installed that runs the [OpenSCAP](https://github.com/OpenSCAP/openscap) scanner against a "remote" server.

Several ansible "roles" (openscap, scap-security-guide, harden, govready) are used that may be adapted with minor or no modifications to be used on local or remote servers.

## System Requirements
- [ansible](http://www.ansible.com/)
- [vagrant](https://www.vagrantup.com/)
- [virtualbox](https://www.virtualbox.org/) (default provider)

## Operation
_See also: scripts/scanPrep.sh_

### Provision two vagrant machines: dashboard and server
- `vagrant up`

#### Networking fails (on Arch host) until... have you turned it off and on again?
- `vagrant halt`
- `vagrant up`

### Run the first scan of 'server' from the 'dashboard'
_Note: The myfisma/GovReadyfile was set up during provisioning._
- `vagrant ssh dashboard`
- `cd myfisma`
- `govready scan`

### Update audit rules and issue.txt ('harden' role) from the host
_Note: Your port values may be different - check the inventory file, too._
- `ssh-copy-id vagrant@localhost -p 2200`
- `ansible-playbook -i inventory -l server harden.yml`

### Execute standard remediations suggested by the SCAP Security Content
- `govready fix`

### Run a final scan from the dashboard
- `govready scan`
- `govready compare`

## Results
### Stock CentOS 7 - results from first scan:
_[Full HTML](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-1-results.html)_
- This profile identifies 4 high severity selected controls. OpenSCAP says 2 passing, 1 failing, and 1 notchecked.
- This profile identifies 12 medium severity selected controls. OpenSCAP says 5 passing, 6 failing, and 1 notchecked.
- This profile identifies 44 low severity selected controls. OpenSCAP says 7 passing, 35 failing, and 2 notchecked.

### After 'harden' - results from second scan:
_[Full HTML](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-2-results.html)_
- This profile identifies 4 high severity selected controls. OpenSCAP says 2 passing, 1 failing, and 1 notchecked.
- This profile identifies 12 medium severity selected controls. OpenSCAP says 5 passing, 6 failing, and 1 notchecked.
- This profile identifies 44 low severity selected controls. OpenSCAP says 33 passing, 9 failing, and 2 notchecked.

### After `govready fix` - results from third scan:
_[Full HTML](http://htmlpreview.github.io/?https://github.com/openprivacy/ansible-scap/blob/master/example-results/scan-3-results.html)_
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