#!/bin/env bash

cwd=`pwd`

# Loop through all subfolders
gh repo list --json nameWithOwner -q '.[].nameWithOwner' | while IFS= read -r name; do
    # Change directory to the subfolder
    cd $cwd

    echo "Processing $name"

    # Define the repository URL (replace with your actual URL)
    repo_url="git@github.com:$name"

    git ls-remote $repo_url | grep develop
    if [ $? -eq 0 ]; then

        # Check if a directory named after the repository already exists
        if [ -d "$(basename $repo_url)" ]; then
            echo "Directory '$(basename $repo_url)' already exists."

            # Check if the 'develop' branch exists locally
            git -C "$(basename $repo_url)" branch --list | grep -q develop
            if [ $? -eq 0 ]; then
                echo "Branch 'develop' already exists locally."
            else
                echo "Branch 'develop' not found locally. Switching to directory..."
                cd "$(basename $repo_url)"

                # Fetch remote branches to ensure we have the latest information
                git fetch origin

                # Check if 'develop' branch exists remotely
                git branch -r | grep -q origin/develop
                if [ $? -eq 0 ]; then
                    echo "Branch 'develop' found on remote. Checking out..."
                    git checkout origin/develop
                    git branch --set-upstream-to=origin/develop develop  # Set develop to track remote
                else
                    echo "Branch 'develop' not found on remote."
                fi
            fi
        else
            echo "Directory '$(basename $repo_url)' not found. Cloning repository..."
            git clone "$repo_url"
            cd "$(basename $repo_url)"
            git checkout develop  # Checkout develop branch if it exists locally after clone
        fi
    fi

    # Now you should be in the desired directory and on the develop branch (if it exists)

    echo "Done!"

    #gh repo clone $name
done
