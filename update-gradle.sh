#!/bin/env bash


gradle_version="latest"
# Loop through all subfolders
   
if [ -d "gradle" ]; then
    
    
    echo "###########################################"
    echo "Processing $dir"
    echo "###########################################"
    ./gradlew -version | grep "Gradle $gradle_version"
    if [ $? -eq 0 ]; then
        echo "Skipping $dir, Gradle already upto date."
    else
        echo "Upgrading Gradle to $gradle_version."
        set -e
        git remote -v
        git pull
        ./gradlew wrapper --gradle-version $gradle_version --distribution-type bin
        ./gradlew build
        git add -A
        git commit -m "chore(ci): upgrade gradle to $gradle_version"
        git push
        set +e
    fi
    ./gradlew -version
fi
    

