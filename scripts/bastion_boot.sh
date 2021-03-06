#!/bin/bash
#### Bastion Boot - Cloud-Init
set -x


## NAT SETUP for Private Network
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/98-ip-forward.conf
firewall-offline-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o ens3 -j MASQUERADE
firewall-offline-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ens3 -j ACCEPT
/bin/systemctl restart firewalld
sysctl -p /etc/sysctl.d/98-ip-forward.conf

set +x
