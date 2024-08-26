#!/bin/env bash

# Loop through all subfolders
#for dir in */; do
    # Change directory to the subfolder
#    cd "$dir"
    # Get all 'release-' tags sorted by version
    release_tags=$(git tag --sort=version:refname | grep "^release-")

    # Extract the latest 'release-' tag name
    latest_release_tag=$(echo "$release_tags" | tail -n 1)

    # Check if any 'release-' tags exist
    if [[ -z "$latest_release_tag" ]]; then
        echo "Error: No tags starting with 'release-' found!"
        exit 1
    fi

    # Extract the version number from the latest release tag
    release_version=${latest_release_tag#release-}

    # Construct the new tag name (v + release_version)
    new_tag_name="v${release_version}"

    # Check if the new tag already exists
    if git describe --exact --tags HEAD~0 > /dev/null 2>&1; then
        echo "Error: Tag '$new_tag_name' already exists!"
        exit 1
    fi
    echo "$latest_release_tag"
    # Create the new tag at the commit pointed to by the latest release tag
    revision=$(git rev-parse "$latest_release_tag^{}")
    echo "$revision"
    git tag  "${new_tag_name}" $revision


    echo "Successfully created new tag: ${new_tag_name}"

    # Change back to the parent directory
#    cd ..
#done
