#!/bin/env bash

set -e

# Loop through all subfolders
for dir in */; do


    # Change directory to the subfolder
    cd "$dir"
    echo "##################"
    echo "processing $dir "
    echo "##################"
    
    if [ -d "gradle" ]; then

        ./gradlew tasks | grep "osvLockAndScan"
        if [ $? -eq 0 ]; then
            echo "Scanning $dir"
            set -e
            ./gradlew osvInstall osvLockAndScan
        else
            echo "Skipping $dir, no osvLockAndScan task."
            ./gradlew taks | grep osv
        fi
        ./gradlew clean
    fi
    
    # Change back to the parent directory
    cd ..
done
