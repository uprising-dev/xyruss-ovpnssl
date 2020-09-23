#!/usr/bin/bash
## Your OpenHTTP Puncher port
OHP_PORT='8888'
## Your OpenVPN Server config file
OVPNCONF='/etc/openvpn/server.conf'

source /etc/os-release
if [[ "${ID}" != "fedora" ]]; then
 printf "%s\n" "this script is for fedora only"
 exit 1
fi

if [[ ! "$(command -v dnf)" ]]; then
 printf "%s\n" "DNF Package manager not found"
 exit 1
fi

if [[ ! "$(command -v screen)" ]]; then
 dnf install screen -y
fi

function printSquidConf(){
 printf "%s\n" "http_access allow all\nhttp_port 127.0.0.1:25100\nacl bon src 0.0.0.0/0.0.0.0\nno_cache deny bon\ndns_nameservers 1.1.1.1 1.0.0.1\nforwarded_for off\nrequest_header_access Allow allow all\nrequest_header_access Authorization allow all\nrequest_header_access WWW-Authenticate allow all\nrequest_header_access Proxy-Authorization allow all\nrequest_header_access Proxy-Authenticate allow all\nrequest_header_access Cache-Control allow all\nrequest_header_access Content-Encoding allow all\nrequest_header_access Content-Length allow all\nrequest_header_access Content-Type allow all\nrequest_header_access Date allow all\nrequest_header_access Expires allow all\nrequest_header_access Host allow all\nrequest_header_access If-Modified-Since allow all\nrequest_header_access Last-Modified allow all\nrequest_header_access Location allow all\nrequest_header_access Pragma allow all\nrequest_header_access Accept allow all\nrequest_header_access Accept-Charset allow all\nrequest_header_access Accept-Encoding allow all\nrequest_header_access Accept-Language allow all\nrequest_header_access Content-Language allow all\nrequest_header_access Mime-Version allow all\nrequest_header_access Retry-After allow all\nrequest_header_access Title allow all\nrequest_header_access Connection allow all\nrequest_header_access Proxy-Connection allow all\nrequest_header_access User-Agent allow all\nrequest_header_access Cookie allow all\nrequest_header_access All deny all" > /etc/squid/squid.conf
}

if [[ "$(command -v squid)" ]]; then
 printSquidConf
 service squid restart &>/dev/null
 else
 printSquidConf
 dnf install squid -y
 service squid restart &>/dev/null
fi

if [[ ! "$(command -v unzip)" ]]; then
 dnf install zip -y
fi

rm -f /usr/local/sbin/ohpserver
curl -4skL "https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip" -o /tmp/ohp.zip
unzip -qq /tmp/ohp.zip -d /usr/local/sbin/
chmod +x /usr/local/sbin/ohpserver
rm -rf /tmp/ohp.zip

OpenVPN_Port="$(cat < ${OVPNCONF} | grep -Eo '(P|p)ort\s([0-9]{1,5})' | awk '{print $2}' | head -n1)"

screen -S vmodz -X quit &>/dev/null

printf "%b\n" "@reboot\troot\tscreen -S vmodzvpn -dm bash -c \"/usr/local/sbin/ohpserver -port ${OHP_PORT} -proxy 127.0.0.1:25100 -tunnel 127.0.0.1:${OpenVPN_Port}\"" > /etc/cron.d/vmodz

screen -S vmodzvpn -dm bash -c "/usr/local/sbin/ohpserver -port ${OHP_PORT} -proxy 127.0.0.1:25100 -tunnel 127.0.0.1:${OpenVPN_Port}"

systemctl restart crond

printf "%b\n" " Install complete:\n  OpenHTTP-Puncher: ${OHP_PORT}\n  OpenVPN Port: ${OpenVPN_Port}\n"
