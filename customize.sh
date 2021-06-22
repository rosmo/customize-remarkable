#!/bin/bash

echo -n 'Enter reMarkable password: '
read -s password
echo ''

host="$1"

dossh() {
  sshpass -p $password ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -l root $host "$@" 
}

doscp() {
  sshpass -p $password scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $1 root@$host:$2 
}



dossh "mkdir -p /opt/rm-vnc-server/ && wget -O/opt/rm-vnc-server/rM-vnc-server-standalone https://github.com/bordaigorl/rmview/raw/vnc/bin/rM2-vnc-server-standalone && chmod +x /opt/rm-vnc-server/rM-vnc-server-standalone"
doscp libcrypto.so.1.0.2 /usr/lib
doscp vnc.service /etc/systemd/system
dossh "systemctl daemon-reload && systemctl start vnc"
dossh "wget -O - http://raw.githubusercontent.com/Evidlo/remarkable_printer/master/install.sh | sh"
