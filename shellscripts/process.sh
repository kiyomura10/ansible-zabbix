#!/bin/bash
set -eu

process_count=$(pgrep -a nginx | wc -l)
echo "nginx process": $process_count

if [[ $process_count = 0 ]]; then
    echo "not running nginx"
    sudo systemctl start nginx
    echo "nginx is running"
else 
    echo "nginx is running"
fi
