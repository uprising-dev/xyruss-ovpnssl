#!/bin/sh

cat test <<-END
[openvpn]
accept = 445
connect = 127.0.0.1:110
cert = /etc/stunnel/stunnel.pem

END
