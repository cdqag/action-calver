#!/bin/bash

new_version=$1

if [ -z "$new_version" ]; then
  echo "Please provide a new version number"
  exit 1
fi

# This script is used to release a new version of the project.

git checkout main
git pull

# Ensure the semver tool is installed before running this script. For installation, visit: https://github.com/fsaintjacques/semver-tool

major_version=$(semver get major "$new_version")

git tag -a "v$new_version" -m "Release $new_version"
git push origin "v$new_version"

# delete major tag if it exists
if git rev-parse "v$major_version" >/dev/null 2>&1
then
  git tag -d "v$major_version"
  git push origin ":v$major_version"
fi

git tag -a "v$major_version" -m "Release $major_version"
git push origin "v$major_version"
