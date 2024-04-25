#!/bin/env bash


gradle_version=$1
# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d "gradle" ]; then
        
        
        echo "###########################################"
        echo "Processing $dir"
        echo "###########################################"
        ./gradlew -version | grep "Gradle $gradle_version"
        if [ $? -eq 0 ]; then
            echo "Skipping $dir, Gradle already upt to date."
        else
            set -e
            git remote -v
            git pull
            ./gradlew wrapper --gradle-version $gradle_version --distribution-type bin
            ./gradlew build
            git add -A
            git commit -m "Upgrade gradle to $gradle_version"
            git push
            set +e
        fi
        ./gradlew -version
    fi
    
    # Change back to the parent directory
    cd ..
done
