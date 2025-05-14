#!/bin/bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repositories_directory>"
  exit 1
fi

# Assign the first argument to REPO_DIR
REPO_DIR="$1"

# Iterate over each directory in the repositories path
for repo in "$REPO_DIR"/*; do
  if [ -d "$repo/.git" ]; then
    echo "Processing repository: $repo"
    cd "$repo" || continue

    # Reset and clean the working directory
    git reset --hard HEAD
    git clean -fd

    # Find default branch (either 'master' or 'main')
    default_branch=$(git show-ref --head | grep -oE "refs/heads/(master|main)" | awk -F/ '{print $3}' | head -n1)

    # Checkout the default branch and pull the latest changes
    if [ -n "$default_branch" ]; then
      git checkout "$default_branch"
      git pull origin "$default_branch"
    else
      echo "No default branch (master or main) found in $repo"
    fi

    # Delete all local branches except the default branch
    for branch in $(git branch | grep -v "$default_branch"); do
      git branch -D "$branch"
    done

  else
    echo "$repo is not a Git repository"
  fi
done
