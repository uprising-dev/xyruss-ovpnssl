#!/bin/sh

cat <<EOT >> /etc/stunnel/stunnel.conf

[openvpn]
accept = 445
connect = 127.0.0.1:110
cert = /etc/stunnel/stunnel.pem
EOT

cd
rm -f ovpnssl.sh
echo "----------------------------------"
echo "   Stunnel Updated Successfully   "
echo "      VPS will reboot now ...     "
echo "----------------------------------"
reboot
