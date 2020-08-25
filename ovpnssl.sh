#!/bin/sh

cat <<EOT >> /etc/stunnel/stunnel.conf

[openvpn]
accept = 445
connect = 127.0.0.1:110
cert = /etc/stunnel/stunnel.pem
EOT

cd
rm -f ovpnssl.sh
echo "VPS will reboot now ..."
restart
