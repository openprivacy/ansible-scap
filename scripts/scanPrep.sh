#!/usr/bin/env bash

echo "Ensure success with /etc/modules-load.d/virtualbox.conf containing:"
echo "    vboxpci"
echo "    vboxnetflt"
echo "    vboxnetadp"
echo "    vboxreload"
echo ""
echo "Clean up..."
vagrant destroy
rm -f roles/admin-access/files/dashboard.pub

echo ""
echo "Provisioning dashboard (admin-access, openscap, harden, govready)..."
vagrant up dashboard

echo ""
echo "Provisioning server (admin-access, openscap, harden, dashboard-access)..."
mv roles/govready/files/id_rsa.pub roles/dashboard-access/files/dashboard.pub
vagrant up server
rm -f roles/dashboard-access/files/dashboard.pub

echo ""
echo "Networking fails until... have you turned it off and on again?"
vagrant halt
vagrant up

echo ""
echo "To run your first scan, do:"
echo "    vagrant ssh dashboard"
echo "    cd myfisma"
echo "    govready scan"
echo "    govready fix"

echo ""
echo "On the host, do some plumbing..."
echo "    ssh-copy-id vagrant@localhost -p 2200"

echo ""
echo "Update audit rules and issue.txt:"
echo "    ansible-playbook -i vagrant -l server harden.yml"

echo "Run a final scan from the dashboard"
echo "    govready scan"
#         govready compare
