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
            echo "Applying spotless"
            set -e
            git remote -v
            git pull
            ./gradlew clean
            ./gradlew spotlessApply
            ./gradlew clean build
            git add -A
            git commit -m "fix: applying spotless formating"
            git push
            set +e
        else
            echo "Skipping $dir, no spotless plugin."
        fi
    fi
    
    # Change back to the parent directory
    cd ..
done
