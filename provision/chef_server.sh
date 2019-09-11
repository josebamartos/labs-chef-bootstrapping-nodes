#!/usr/bin/env bash

channel='stable'    # Chef installation channel: stable | current
os_version='7'      # 6 | 7
username='manager'  # Name of the new user on Chef Server
userdesc='Chef Manager'          # Description of the new user on Chef Server
password='P4ssW0rd..'            # Password of the new user on Chef Server
usermail='chef.user@domain.com'  # E-mail of the new user on Chef Server
orgname='chef-labs'   # Name of the new organization on Chef Server
orgdesc='Chef Labs'   # Description of the new organization on Chef Server

echo -e "\n[BEGIN] Provisioning script"
echo    "  * Upgrading system software"
yum update -y -q -e 0  > /dev/null

echo "  * Installing dependencies"
yum groupinstall -y -q "Development Tools" > /dev/null
yum install -y -q yum-utils kernel-devel > /dev/null

echo "  * Adding official Chef repository"
rpm --quiet --import https://packages.chef.io/chef.asc > /dev/null
cat > chef-${channel}.repo <<EOF
[chef-${channel}]
name=chef-${channel}
baseurl=https://packages.chef.io/repos/yum/${channel}/el/${os_version}/\$basearch/
gpgcheck=1
enabled=1
EOF
yum-config-manager --add-repo chef-stable.repo > /dev/null
rm chef-stable.repo

echo "  * Installing Chef Infra Server"
yum install -y -q chef-server-core > /dev/null
# Firewall rules for Chef Server
# firewall-cmd --permanent --zone public --add-service http
# firewall-cmd --permanent --zone public --add-service https
# firewall-cmd --reload

echo "  * Cleaning packages"
yum autoremove -y -q  > /dev/null
yum clean all -y -q  > /dev/null

echo " * Configuring Chef Infra Server"
chown -R vagrant:vagrant /home/vagrant
if [[ ! -d /home/vagrant/certs ]]; then mkdir /home/vagrant/certs; fi
# Configure Chef Server
chef-server-ctl reconfigure --chef-license accept
chef-server-ctl user-create ${username} ${userdesc} ${usermail} ${password} --filename /home/vagrant/certs/${username}.pem
chef-server-ctl org-create ${orgname} ${orgdesc} --association_user ${username} --filename /home/vagrant/certs/${orgname}.pem
# Install Chef Manage
chef-server-ctl install chef-manage
chef-server-ctl reconfigure
chef-manage-ctl reconfigure --accept-license
# Install Chef Rerporting
chef-server-ctl install opscode-reporting
chef-server-ctl reconfigure
opscode-reporting-ctl reconfigure --accept-license

cat >> /etc/hosts << EOF
# Vagrant environment nodes
10.10.10.10  chef-server
10.10.10.11  chef-node-01
10.10.10.12  chef-node-02
EOF

cat << EOF
  * Chef Infra Server installed succesfully:
      URL:  http://${HOSTNAME}
      User: ${username}
      Pass: ${password}
[END] Provisioning script

EOF