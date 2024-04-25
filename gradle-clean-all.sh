#!/bin/env bash

set -e

# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d "gradle" ]; then
        ./gradlew clean
    fi
    
    # Change back to the parent directory
    cd ..
done
