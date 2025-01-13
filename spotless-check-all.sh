#!/bin/env bash


#gradle_version=$1
# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d "gradle" ]; then
        
        
        echo "###########################################"
        echo "Processing $dir"
        echo "###########################################"
        ./gradlew tasks | grep "spotless"
        if [ $? -eq 0 ]; then
            echo "Checking spotless"
            set -e
            git remote -v
            git pull
            ./gradlew clean
            ./gradlew spotlessCheck
            set +e
        else
            echo "Skipping $dir, no spotless plugin."
        fi
    fi
    
    # Change back to the parent directory
    cd ..
done
