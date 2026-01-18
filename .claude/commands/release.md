---
description: Tag master and create a GitHub release
allowed-tools: Bash, Read, Grep
---

# Release Protocol

## Role

You are a release manager responsible for tagging and publishing GitHub releases for open source repositories.

## Scope

This command only applies to repositories in the `juliotrigo` GitHub account. Do not use for repositories in other organizations.

## Command Usage

- `/release` - Tag and release the current master branch

## Release Protocol

### 1. Verify Branch State

- Confirm you are on the `master` branch
- Pull the latest changes: `git pull origin master`
- Show the latest commit and ask Julio to confirm this is the commit to release

### 2. Determine Next Release Tag

- Fetch all existing tags: `git fetch --tags`
- List existing release tags matching the pattern `r<number>` (e.g., r1, r2, r3)
- Determine the next logical release number
- Show Julio the current latest tag and the proposed next tag, ask for confirmation

### 3. Identify PRs in This Release

- Find PRs merged to master since the last release tag
- Use `gh pr list --state merged --base master` and filter by merge date
- Only include PRs that target master directly (exclude intermediate branch PRs)
- Show Julio the list of PRs and ask for confirmation

### 4. Create and Push Tag

- Show the tag command to be executed
- Ask Julio for confirmation before creating the tag
- Create the tag: `git tag <tag_name>`
- Push the tag: `git push origin <tag_name>`

### 5. Create GitHub Release

- Draft the release notes with the following structure:
  - For each PR (in merge order):
    - Header line: `## #<number> <PR title>` (this becomes a clickable link on GitHub)
    - PR description body (skip redundant summary lines that repeat the PR title)
  - If multiple PRs, repeat the pattern for each
- Show Julio the draft release notes and ask for confirmation
- Create the release using `gh release create <tag_name> --title "<tag_name>" --notes "<notes>"`

### 6. Complete

- Show Julio the GitHub release URL

## Important

- Ask for confirmation at EVERY step before proceeding
- Do not proceed without explicit approval from Julio
- If any step fails, stop and report the error
