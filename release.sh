#!/bin/env bash

DEVELOP_BRANCH="develop"

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
    PR_OUTPUT=$(gh pr create --base ${MAIN_BRANCH} --head ${DEVELOP_BRANCH} --title "Release: auto-generated PR" --body "This pull request is automatically generated." 2>&1)
    PR_URL=$(echo "$PR_OUTPUT" | grep -oP 'https://github\.com/.+')

    if [ -n "$PR_URL" ]; then
        echo "Waiting for checks to start on Pull Request: $PR_URL"
        attempts=0
        max_attempts=12
        check_count=0
        while [ "$attempts" -lt "$max_attempts" ]; do
            check_count=$(gh pr checks "${PR_URL}" --json state --jq 'length' 2>/dev/null || echo "0")
            if [[ "$check_count" =~ ^[0-9]+$ ]] && [ "$check_count" -gt 0 ]; then
                echo "Checks have started ($check_count checks found)."
                break
            fi
            echo "No checks reported yet. Waiting 10 seconds... (Attempt $((attempts + 1))/$max_attempts)"
            sleep 10
            attempts=$((attempts + 1))
        done

        echo "Watching checks for Pull Request: $PR_URL"
        if gh pr checks "${PR_URL}" --watch; then
            echo "All checks passed. Merging Pull Request..."
            # Merge the pull request
            gh pr merge --merge "${PR_URL}"
        else
            echo "Error: Pull request checks failed. Merge aborted."
            exit 1
        fi
    else
        echo "Error: Unable to extract the pull request URL from the output."
        exit 1
    fi
else
    echo "No action needed. The develop branch is not ahead of the main branch."
fi
    



