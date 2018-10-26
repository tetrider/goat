#!/bin/bash
# GO Advanced Testing
goat(){ 
# Check port option in command. Use -p ?? (with space) to skip key generation
if [[ ! -z "$(echo $@ | grep '\-p[0-9]')" ]]; then
# Generate key
key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1 || echo "k3krvQG5N3ezgFr8l5TL9h5m")
# List of commands to gen auth key
keygen=$(cat <<EOF
sbin/mgrctl mgr | cut -f2 -d= | while read mgr; do sbin/mgrctl -m \\\$mgr session.newkey key=$key; done;
sbin/mgrctl mgr | cut -f2 -d= | while read mgr; do 
sbin/ihttpd | cut -f3 -d: | sort | uniq | while read port; do
echo 'https://'$1':'\\\$port'/'\\\$mgr'?func=auth&key='$key; 
done;
done;
EOF
)
freeaccess=""
else
# Important. Clear var if standart port    
keygen=""
freeaccess=$(cat <<EOF
sbin/mgrctl mgr | cut -f2 -d= | while read mgr; do 
sbin/ihttpd | cut -f3 -d: | sort | uniq | while read port; do
echo 'https://ssh.ispsystem.net/?submit=go&url=https://'$1':'\\\$port'/'\\\$mgr; 
done;
done;
EOF
)
fi
# Main list of commands
declare commands;
commands=$(cat <<EOF
for var in oneiter; do
echo '****************************';
cat /etc/redhat-release 2>/dev/null || cat /etc/os-release | grep -Po '(?<=PRETTY_NAME=\").*(?=\")' 2>/dev/null || echo 'Unknown OS';
uptime; echo;
df -h; echo;
free -m;
echo '****************************';
cd /usr/local/mgr5 2>/dev/null || { echo 'NO mgr5 directory'; break; };
bin/core -V >/dev/null 2>&1 && printf 'CORE version ' && bin/core -V || { echo 'NO bin/core'; break; };
sbin/mgrctl mgr | cut -f2 -d= | while read i; do bin/core \\\$i -i; done;
echo;
sbin/ihttpd || echo 'ihttpd ERROR';
echo;
ps -f -C core || echo 'NO core process';
echo;
$keygen
$freeaccess
done;
EOF
)
# Copy command and authkey to clipboard 
if [[ ! -z "$keygen" ]]; then
    echo "?func=auth&key=$key" | xsel -ib 2>/dev/null || echo "Failed copy key to clipboard. Please install xsel"
fi
# Go. If error try without commands
ssh sup@ssh -t "go $@ -t \"$commands bash -l\"" || ssh $@ -t "$commands bash -l" || ssh sup@ssh -t "go $@"; 
# ssh $@ -t "$commands bash -l" 
}
