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

    if [ -d ".github" ]; then
        git pull

        # Determine branch name
        if git rev-parse --quiet --verify origin/main > /dev/null; then
            MAIN_BRANCH="main"
        elif git rev-parse --quiet --verify origin/master > /dev/null; then
            MAIN_BRANCH="master"
        else
            echo "$dir - Error: Unable to determine the main branch. Exiting."
            exit 1
        fi

        # Fetch changes from remote repo and determine difference
        git fetch origin
        DEVELOP_AHEAD_COUNT=$(git rev-list --no-merges --count origin/${DEVELOP_BRANCH} ^origin/${MAIN_BRANCH})
        if [ "$DEVELOP_AHEAD_COUNT" -gt 0 ]; then
            # Check if all the commits on the develop branch are by 'dependabot'
            if git log --pretty=%an --no-merges origin/${MAIN_BRANCH}..origin/${DEVELOP_BRANCH} | grep -qv '^dependabot.*'; then
                echo "$dir - The develop branch is ahead of the main branch, but not all commits are by 'dependabot'. Skipping."
#                exit 1
            else
                echo "$dir - The develop branch is ahead of main branch and all commits are by dependabot. Opening PR"
                PR_OUTPUT=$(gh pr create --base ${MAIN_BRANCH} --head ${DEVELOP_BRANCH} --title "Auto-generated dependabot PR" --body "This pull request is automatically generated." 2>&1)
                PR_URL=$(echo "$PR_OUTPUT" | grep -oP 'https://github\.com/.+')

                if [ -n "$PR_URL" ]; then
                    echo "$dir - Waiting for checks to start on Pull Request: $PR_URL"
                    attempts=0
                    max_attempts=12
                    check_count=0
                    while [ "$attempts" -lt "$max_attempts" ]; do
                        check_count=$(gh pr checks "${PR_URL}" --json state --jq 'length' 2>/dev/null || echo "0")
                        if [[ "$check_count" =~ ^[0-9]+$ ]] && [ "$check_count" -gt 0 ]; then
                            echo "$dir - Checks have started ($check_count checks found)."
                            break
                        fi
                        echo "$dir - No checks reported yet. Waiting 10 seconds... (Attempt $((attempts + 1))/$max_attempts)"
                        sleep 10
                        attempts=$((attempts + 1))
                    done

                    echo "$dir - Watching checks for Pull Request: $PR_URL"
                    if gh pr checks "${PR_URL}" --watch; then
                        echo "$dir - All checks passed. Merging Pull Request..."
                        # Merge the pull request
                        gh pr merge --merge "${PR_URL}"
                    else
                        echo "$dir - Error: Pull request checks failed. Merge aborted."
                        exit 1
                    fi
                else
                    echo "$dir - Error: Unable to extract the pull request URL from the output."
                    exit 1
                fi
            fi
        else
            echo "$dir - No action needed. The develop branch is not ahead of the main branch."
        fi
    fi
    
    # Change back to the parent directory
    cd ..

done



