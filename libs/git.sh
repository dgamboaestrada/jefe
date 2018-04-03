#!/bin/bash
#
# git.sh
#

# Get name of current branch
current_branch() {
    branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || branch_name="(unnamed branch)"     # detached HEAD
    branch_name=${branch_name##refs/heads/}
    echo "$branch_name"
}
