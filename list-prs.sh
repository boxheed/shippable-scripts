#!/bin/env bash

# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d ".git" ]; then
        gh pr list
    fi
    
    # Change back to the parent directory
    cd ..
done
