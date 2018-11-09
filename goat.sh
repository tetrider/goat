#!/bin/bash
# GO Advanced Testing
goat(){ 
# Generate key
key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
# Main list of commands
commands_line=$(cat <<EOF
for fakeiter in fakecycle; do
    echo '***';
    cat /etc/redhat-release 2>/dev/null || cat /etc/os-release | grep -Po '(?<=PRETTY_NAME=\").*(?=\")' 2>/dev/null || echo 'Unknown OS';
    uptime; 
    echo;
    df -h | grep -E '(8.%)|(9.%)|100%'; 
    free -m;
    echo '***';
    cd /usr/local/mgr5 || break;
    sbin/mgrctl mgr 1>/dev/null || break;
    sbin/mgrctl mgr | cut -f2 -d= | while read i; do 
        echo "bin/coRE \\\$i -i" | sed 's/RE/re/' | sh;
    done;
    echo;
    sbin/ihttpd || break;
    echo;
    echo 'ps -f -C coRE' | sed 's/RE/re/' | sh;
    echo;
    sbin/mgrctl mgr | cut -f2 -d= | sed '/\(mini\|node\)$/d' | while read mgr; do 
        sbin/mgrctl -m \\\$mgr session.newkey key=$key; 
        sbin/ihttpd | cut -f3 -d: | sed '/80/d' | sort | uniq | while read port; do
            echo https://$1:\\\$port/\\\$mgr?func=auth\&key=$key; 
        done;
    done;
done;
alias less="less -R";
EOF
) 
# Copy command and authkey to clipboard 
# echo "?func=auth&key=$key" | xsel -ib 2>/dev/null || echo "Failed copy key to clipboard. Please install xsel"

# Open default CP in browser
# xdg-open "https://$1:1500?func=auth&key=$key"

# Go. If error try without commands
# echo $commands_line
ssh sup@ssh -t "go $@ -t \"$commands_line bash -l\"" || ssh sup@ssh -t "go $@"; 
# ssh $@ -t "$commands_line bash -l" 
}
