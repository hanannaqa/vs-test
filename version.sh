#!/bin/bash

# Script to automatically bump Git version for microservices and tag for Docker image

# Get the latest tag from Git
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags exist, start with the initial version
if [ -z "$latest_tag" ]; then
  latest_tag="v1.0.0"
fi

echo "Latest tag: $latest_tag"

# Remove 'v' from the tag to work with version numbers
version=${latest_tag#v}

# Split the version into major, minor, and patch components
IFS='.' read -r major minor patch <<< "$version"
echo "Current version breakdown - Major: $major, Minor: $minor, Patch: $patch"

# Get the latest commit message
latest_commit_message=$(git log -1 --pretty=%B)
echo "Latest commit message: $latest_commit_message"

# Determine the version increment based on the commit message
if [[ "$latest_commit_message" == *"major"* ]]; then
  major=$((major + 1))
  minor=0
  patch=0
  echo "Incrementing major version"
elif [[ "$latest_commit_message" == *"minor"* ]]; then
  minor=$((minor + 1))
  patch=0
  echo "Incrementing minor version"
else
  patch=$((patch + 1))
  echo "Incrementing patch version"
fi

# Create the new version tag
new_version="v$major.$minor.$patch"
echo "New version to be tagged: $new_version"

# Tag the new version in Git
git tag -a "$new_version" -m "Release $new_version"
if git push origin "$new_version"; then
  echo "Tag $new_version pushed to origin"
else
  echo "Failed to push tag. Check for permissions or branch protections."
  exit 1
fi

# Export the version to use it in your CI/CD pipeline
echo "::set-output name=version::$new_version"
