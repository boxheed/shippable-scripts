#!/bin/env bash

DEVELOP_BRANCH="develop"

# Loop through all subfolders
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    echo "###########################################"
    echo "Processing $dir"
    echo "###########################################"
    git remote -v

    # Determine branch name
    if git rev-parse --quiet --verify origin/main > /dev/null; then
        MAIN_BRANCH="main"
    elif git rev-parse --quiet --verify origin/master > /dev/null; then
        MAIN_BRANCH="master"
    else
        echo "Error: Unable to determine the main branch. Exiting."
        exit 1
    fi

    # Fetch changes from remote repo and determine difference
    git fetch origin
    git pull
    DEVELOP_AHEAD_COUNT=$(git rev-list --count origin/${DEVELOP_BRANCH} ^origin/${MAIN_BRANCH})
    if [ "$DEVELOP_AHEAD_COUNT" -gt 0 ]; then
        # Check if all the commits on the develop branch are by 'dependabot'
        echo "The develop branch is ahead of main branch. Opening PR"
        PR_OUTPUT=$(gh pr create --base ${MAIN_BRANCH} --head ${DEVELOP_BRANCH} --title "Auto-generated PR" --body "This pull request is automatically generated." 2>&1)
        PR_URL=$(echo "$PR_OUTPUT" | grep -oP 'https://github\.com/.+')

        if [ -n "$PR_URL" ]; then
            echo "Merging Pull Request: $PR_URL"
            gh pr checks ${PR_URL} --watch
            # Merge the pull request
            gh pr merge --merge "${PR_URL}"
        else
            echo "Error: Unable to extract the pull request URL from the output."
            exit 1
        fi
    else
        echo "No action needed. The develop branch is not ahead of the main branch."
    fi
    
    # Change back to the parent directory
    cd ..

done



