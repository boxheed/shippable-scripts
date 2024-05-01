#!/bin/bash
for dir in */; do
    # Change directory to the subfolder
    cd "$dir"
    
    if [ -d ".git" ]; then
        # Fetch latest PR information
        gh pr list --json number,author,state,mergeable,title --state open > /tmp/open_prs.json

        # Check if there are any open PRs
        if ! jq .[].number open_prs.json >/dev/null 2>&1; then
            echo "No open pull requests found in $dir"
        else
            # Loop through each open PR
            for pr_data in $(jq -r '.[].number' open_prs.json); do

                # Extract PR number, user login, and merge states
                details=$(gh pr view "$pr_data" --json number,author,state,mergeable,title )
                # Extract user login and mergeable state
                user_login=$(jq .author.login <<< "$details")
                mergeable=$(jq .mergeable <<< "$details")
                pr_number=$(jq .number <<< "$details")
                pr_title=$(jq .title <<< "$details")
                gh pr checks $pr_number
                checks_passed=$?

                echo "PR found: $pr_number - $pr_title by $user_login { $mergeable $checks_passed }"

                # Check if PR is from dependabot, has passed checks, and is mergeable
                if [[ "$user_login" == "\"app/dependabot\"" && "$mergeable" == "\"MERGEABLE\"" && $checks_passed -eq 0 ]]; then
                    echo "Merging PR #$pr_number - $pr_title by $user_login"
                    gh pr merge "$pr_number" --auto --merge
                else 
                    echo "Skipping PR #$pr_number - $pr_title by $user_login"
                fi
            done

            # Clean up temporary file
            rm -f /tmp/open_prs.json
        fi
    fi
    
    # Change back to the parent directory
    cd -
done
