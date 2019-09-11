#!/usr/bin/env bash

channel='stable'    # Chef installation channel: stable | current
distro='7'          # 6 | 7

echo -e "\n[BEGIN] Provisioning script"
echo    "  * Upgrading system software"
yum update -y -q -e 0  > /dev/null

echo "  * Cleaning packages"
yum autoremove -y -q  > /dev/null
yum clean all -y -q  > /dev/null

cat >> /etc/hosts << EOF
# Vagrant environment nodes
10.10.10.10  chef-server
10.10.10.11  chef-node-01
10.10.10.12  chef-node-02
EOF

echo -e "[END] Provisioning script\n"
