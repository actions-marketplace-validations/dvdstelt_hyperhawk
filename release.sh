#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: ./release.sh major | minor | patch"
    exit 1
}

[[ $# -ne 1 ]] && usage

case "$1" in
    major|minor|patch) bump="$1" ;;
    *) usage ;;
esac

# Ensure we are on main and up to date
branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" != "main" ]]; then
    echo "Switching to main..."
    git checkout main
fi
echo "Pulling latest changes..."
git pull --ff-only origin main

# Read current version from package.json
current=$(node -p "require('./package.json').version")
IFS='.' read -r maj min pat <<< "$current"

case "$bump" in
    major) maj=$((maj + 1)); min=0; pat=0 ;;
    minor) min=$((min + 1)); pat=0 ;;
    patch) pat=$((pat + 1)) ;;
esac

new_version="$maj.$min.$pat"
tag="v$new_version"

echo "Bumping $current -> $new_version"

# Update version in package.json (and sync package-lock.json)
npm version "$new_version" --no-git-tag-version

# Rebuild dist with new version baked in
echo "Building..."
npm run build

# Commit, tag, push
git add package.json package-lock.json dist/
git commit -m "chore: release $tag"
git tag "$tag"
floating_tag="v$maj"
git tag -f "$floating_tag"
git push origin main
git push origin "$tag"
git push origin "$floating_tag" --force

echo "Done - $tag pushed to origin"
