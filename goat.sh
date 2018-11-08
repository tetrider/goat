#!/bin/bash
# GO Advanced Testing
goat(){ 
# Generate key
key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
# Main list of commands
commands_line=$(cat <<EOF
for var in oneiter; do
    echo '****************************';
    cat /etc/redhat-release 2>/dev/null || cat /etc/os-release | grep -Po '(?<=PRETTY_NAME=\").*(?=\")' 2>/dev/null || echo 'Unknown OS';
    uptime; echo;
    df -h; echo;
    free -m;
    echo '****************************';
    cd /usr/local/mgr5 2>/dev/null || { echo 'NO mgr5 directory'; break; };
    echo 'bin/CORE 1>/dev/null' | tr '[:upper:]' '[:lower:]' | sh;
    sbin/mgrctl mgr | cut -f2 -d= | while read i; do 
        echo "bin/CORE \\\$i -i" | tr '[:upper:]' '[:lower:]' | sh;
    done;
    echo;
    sbin/ihttpd || echo 'ihttpd ERROR';
    echo;
    echo 'ps -f -C coRE' | sed 's/RE/re/' | sh;
    echo;
    sbin/mgrctl mgr | cut -f2 -d= | sed '/\(mini\|node\)$/d' | while read mgr; do 
        sbin/mgrctl -m \\\$mgr session.newkey key=$key; 
        sbin/ihttpd | cut -f3 -d: | sed '/80/d' | sort | uniq | while read port; do
            echo 'https://'$1':'\\\$port'/'\\\$mgr'?func=auth&key='$key; 
        done;
    done;
done;
EOF
) 
# Copy command and authkey to clipboard 
# echo "?func=auth&key=$key" | xsel -ib 2>/dev/null || echo "Failed copy key to clipboard. Please install xsel"

# Go. If error try without commands
echo $commands_line
ssh sup@ssh -t "go $@ -t \"$commands_line bash -l\"" || ssh sup@ssh -t "go $@"; 
# ssh $@ -t "$commands bash -l" 
}
