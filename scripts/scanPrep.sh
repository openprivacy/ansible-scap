#!/usr/bin/env bash

echo "Ensure success with /etc/modules-load.d/virtualbox.conf containing:"
echo "    vboxpci"
echo "    vboxnetflt"
echo "    vboxnetadp"
echo "    vboxreload"
echo "The private net may work better if you have a VirtualBox GUI running."

# cleanup
# vagrant destroy
# vagrant halt
rm -f roles/admin-access/files/dashboard.pub

echo "Provisioning dashboard (admin-access, openscap, harden, govready)..."
vagrant up dashboard

echo ""
echo "Provisioning server (admin-access, openscap, harden, dashboard-access)..."
mv roles/govready/files/id_rsa.pub roles/dashboard-access/files/dashboard.pub
vagrant up server
rm -f roles/dashboard-access/files/dashboard.pub

echo ""
echo "Murphy: Networking fails until the servers are halted and restarted..."
vagrant halt
vagrant up dashboard
vagrant up server

echo ""
echo "To run your first scan, do:"
echo "    vagrant ssh dashboard"
echo "    cd myfisma"
echo "    govready scan"
echo ""
echo "Then run (still on dashboard):"
echo "    govready fix"
echo "    govready scan"
echo ""
echo "Finally, update audit rules and issue.txt:"
echo "    harden"         # server; is this an ansible command?
echo "    govready scan"  # from dashboard
