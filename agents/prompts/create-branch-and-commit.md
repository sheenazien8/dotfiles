---
description: create a new branch and commit changes
argument-hint: "[branch-name]"
---

Create a new git branch named ${1:-} from the current branch, then commit the staged (or related unstaged) changes with a simple, descriptive message.

- If a branch name is provided, use it; otherwise generate a short kebab-case name that summarizes the changes.
- Switch to the new branch before committing.
- Do not push unless explicitly asked.
- Do not commit unrelated changes.
