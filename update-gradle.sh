#!/bin/env bash

set -e

gradle_version=$1
# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d "gradle" ]; then
        git pull
        gradle wrapper --gradle-version $gradle_version --distribution-type bin
        ./gradlew build
        git add -A
        git commit -m "Upgrade gradle to $gradle_version"
        git push
    fi
    
    # Change back to the parent directory
    cd ..
done
