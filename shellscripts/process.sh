#!/bin/bash

process_count=$(ps aux | grep '[n]ginx' | wc -l)
echo "nginx process": $process_count

if [[ $process_count -eq 0 ]]; then
    echo "not running nginx"
    sudo systemctl start nginx
    process_count=$(ps aux | grep '[n]ginx' | wc -l)
    if [[ $process_count -gt 0 ]]; then
        echo "nginx is running"
    fi
else 
    echo "nginx is running"
fi
