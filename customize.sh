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

echo "Install better wget..."
dossh "mkdir -p /opt/bin && wget -Owget-new http://toltec-dev.org/thirdparty/bin/wget-v1.21.1-1 && mv wget-new /opt/bin/wget && chmod a+x /opt/bin/wget"

echo "Installing printer..."
dossh "/opt/bin/wget -O - http://evidlo.github.io/remarkable_printer/install.sh | sed 's/http:/https:/g' | sh"

echo "Installing goMarkableStream..."
dossh "export GORKVERSION=\$(/opt/bin/wget -q -O - https://api.github.com/repos/owulveryck/goMarkableStream/releases/latest | grep tag_name | awk -F\\\" '{print \$4}') && /opt/bin/wget -q -O - https://github.com/owulveryck/goMarkableStream/releases/download/\$GORKVERSION/goMarkableStream_\${GORKVERSION//v}_linux_arm.tar.gz | tar xzvf - -O goMarkableStream_\${GORKVERSION//v}_linux_arm/goMarkableStream > goMarkableStream && chmod +x goMarkableStream"
doscp goMarkableStream.service /etc/systemd/system
dossh "systemctl enable goMarkableStream.service && systemctl start goMarkableStream.service"