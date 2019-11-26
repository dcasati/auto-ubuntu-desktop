#!/bin/bash
# Set hostname
read -p "Hostname: " pcHost
echo "Changing the hostname to $pcHost"
sed -i "s/ubuntu/$pcHost/g" /etc/hostname
sed -i "s/ubuntu/$pcHost/g" /etc/hosts
