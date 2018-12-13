#!/bin/bash
# GO Advanced Testing
goat(){ 
    # Options section
    aliases_forwarding=1

    # Main list of commands
    commands_line=$(cat <<EOF
    RED='\033[0;31m';
    YELLOW='\033[1;33m';
    GREEN='\033[0;32m';
    GRAY='\033[1;30m';
    NC='\033[0m';
    div=\$(for i in {1..60}; do printf '*'; done);
    for fakeiter in fakecycle; do
        echo -e "\${GRAY}\${div}\${NC}";
        printf "\${GRAY}OS: \${NC}";
        cat /etc/redhat-release 2>/dev/null || cat /etc/os-release | grep -Po '(?<=PRETTY_NAME=\").*(?=\")' 2>/dev/null || echo 'Unknown OS';
        printf "\${GRAY}Uptime: \${NC}";
        uptime -p | sed 's/up //'; 
        printf "\${GRAY}Load average: \${NC}";
        uptime | grep -Po '(?<=load average: ).*';
        if [[ ! -z \$(df -lh | grep -E '(8.%)|(9.%)|100%') ]]; then
            echo -e "\${GRAY}Disk usage:";
            printf "\${GREEN}";
            df -lh | grep -E '(8.%)' | awk '{print \$5, "used on", \$6}'; 
            printf "\${YELLOW}";
            df -lh | grep -E '(9.%)' | awk '{print \$5, "used on", \$6}'; 
            printf "\${RED}";
            df -lh | grep -E '100%' | awk '{print \$5, "used on", \$6}';
            printf "\${NC}";
        fi; 
        freemem=\$(free -mt | grep Total | awk '{print \$4}');
        totalmem=\$(free -mt | grep Total | awk '{print \$2}');
        printf "\${GRAY}Memory free: \${NC}";
        if (( "\$freemem" < "100" )); then
            printf "\${RED}";    
        fi;
        echo -e "\${freemem}/\${totalmem}\${NC}";
        echo -e "\${GRAY}\${div}\${NC}";
        cd /usr/local/mgr5 || break;
        sbin/mgrctl mgr 1>/dev/null || break;
        sbin/mgrctl mgr | cut -f2 -d= | while read i; do 
            echo "bin/coRE \$i -i" | sed 's/RE/re/' | sh;
        done;
        echo;
        sbin/ihttpd || break;
        echo;
        echo 'ps -f -C coRE' | sed 's/RE/re/' | sh;
        echo;
        pwgen -s 24 1 | while read key; do
            sbin/mgrctl mgr | cut -f2 -d= | sed '/\(mini\|node\)$/d' | while read mgr; do 
                sbin/mgrctl -m \$mgr session.newkey key=\$key; 
                sbin/ihttpd | grep -o '[^:]*$' | sed '/80/d' | sort | uniq | while read port; do
                    echo https://$1:\$port/\$mgr?func=auth\&key=\$key; 
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
        ssh sup@ssh -t go $@ -t "$commands_line bash --rcfile <( echo '$aliases_line' )" || ssh sup@ssh -t "go $@"; 
    else
        ssh sup@ssh -t go $@ -t "$commands_line bash -l" || ssh sup@ssh -t "go $@";
    fi
}
