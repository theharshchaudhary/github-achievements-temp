#!/usr/bin/env bash
# Opens and merges N pull requests sequentially to progress the "Pull Shark" badge.
# Usage: scripts/pull-shark.sh [count]   (default: 5)
set -euo pipefail

COUNT="${1:-5}"
GH="${GH:-gh}"
command -v "$GH" >/dev/null 2>&1 || GH="/c/Program Files/GitHub CLI/gh.exe"

cd "$(git rev-parse --show-toplevel)"
mkdir -p log

for i in $(seq 1 "$COUNT"); do
  branch="pull-shark-$(date +%s)-$i"
  git checkout -q main
  git pull -q --ff-only

  git checkout -q -b "$branch"
  echo "Entry $i at $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> log/pull-shark.log
  git add log/pull-shark.log
  git commit -q -m "Pull Shark: add log entry $i"
  git push -q -u origin "$branch"

  pr=$("$GH" pr create --base main --head "$branch" \
    --title "Pull Shark: log entry $i" --body "Automated PR $i of $COUNT.")
  "$GH" pr merge "$pr" --merge --admin --delete-branch >/dev/null
  echo "Merged $pr"
done

git checkout -q main
git pull -q --ff-only
