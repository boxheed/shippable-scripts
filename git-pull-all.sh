#!/bin/env bash

# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d ".git" ]; then
        git pull
    fi
    
    # Change back to the parent directory
    cd ..
done
