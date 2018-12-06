#!/bin/bash
# GO Advanced Testing
goat(){ 
    # Options section
    aliases_forwarding=1

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
        pwgen -s 24 1 | while read key; do
            sbin/mgrctl mgr | cut -f2 -d= | sed '/\(mini\|node\)$/d' | while read mgr; do 
                sbin/mgrctl -m \\\$mgr session.newkey key=\\\$key; 
                sbin/ihttpd | grep -o '[^:]*$' | sort | uniq | while read port; do
                    echo https://$1:\\\$port/\\\$mgr?func=auth\&key=\\\$key; 
                done;
            done;
        done;
    done;
EOF
    ) 

    # Aliases list
    aliases_line=$(cat <<EOF
    . ~/.bashrc; 
    alias less=less\ -R;
EOF
    )

    # Go. If error try without commands
    if [ "$aliases_forwarding" = "1" ]; then
        ssh sup@ssh -t "go $@ -t \"$commands_line bash --rcfile <( echo '$aliases_line' )\"" || ssh sup@ssh -t "go $@"; 
    else
        ssh sup@ssh -t "go $@ -t \"$commands_line bash -l\"" || ssh sup@ssh -t "go $@";
    fi
}
