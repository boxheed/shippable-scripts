#!/bin/env bash

# Find the latest release tag
latest_release=$(git tag -l "release-*" | sort -V -r | head -n 1)

# Extract the version number from the tag
version=$(echo "$latest_release" | sed 's/release-//')


# Create the new tag name
new_tag="v$version"

# Check if the new tag already exists
if git tag -l | grep "$new_tag" &> /dev/null; then
  echo "Tag $new_tag already exists"
else
  # Create the new tag if it doesn't exist
  commit=$(git rev-list --max-count=1 "$latest_release")
  git tag "$new_tag" "$commit"
  echo "Created new tag: $new_tag"
fi
