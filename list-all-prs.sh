#!/bin/env bash

# Loop through all subfolders
gh repo list --json nameWithOwner -q '.[].nameWithOwner' | while IFS= read -r name; do
    # Change directory to the subfolder
    gh pr list -R $name
done
