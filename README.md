# ansible-scap
ansible roles for SCAP scanning

## Overview

This test directory creates a dashboard server with [GovReady](https://github.com/GovReady/govready) and the [SCAP Security Guide](https://github.com/OpenSCAP/scap-security-guide) installed that run the [OpenSCAP](https://github.com/OpenSCAP/openscap) scanner against a "remote" server.

## System Requirements

- ansible
- vagrant
- virtualbox (default provider)

## Operation

``` bash
# Provision two vagrant machines: dashboard and server
vagrant up
...
```

