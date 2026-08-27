---
name: creator-plan
description: Create a structured task plan based on a title and brief details. Use this skill whenever the user wants to plan a task, create a todo, break down work, or organize implementation steps. Trigger when the user mentions planning, creating tasks, breaking down work, or asks for a roadmap for any feature, fix, or refactor.
---

# Plan Creator

Create a detailed, actionable plan for a given task. Before writing the plan, assess whether you have enough context. If the task is ambiguous, complex, or missing key details, ask 2–3 concise clarifying questions first.

## When to Ask Questions

Ask questions **only** when one or more of these are true:
- The task description is vague or could mean multiple things
- You don't know the scope or boundaries of the work
- Technical choices are unclear (stack, approach, constraints)
- You don't know what "done" looks like
- The task involves multiple systems/files and the user hasn't specified which

## When NOT to Ask Questions

If the task is straightforward and you have enough context, skip questions and create the plan immediately:
- Simple, well-defined changes (e.g., "add a nullable email column to users table")
- The user already provided clear files, approach, and scope
- One-line fixes or obvious refactors

## Question Guidelines

- Ask **2–3 questions maximum** — keep it tight
- Make questions specific and actionable, not open-ended
- Focus on: scope, approach, constraints, or acceptance criteria
- Don't ask about things you can reasonably infer or look up

## Plan Format

Once you have enough context, create the plan in this format:

```md
# <task title>

## Context
- files: @path/to/file
- describe the current state

## Goals
- what needs to be done

## Notes
- Deep analyze the context base on the completed tasks

## Testing
- how to verify the work

## Tools / Skills
- mcp database / tools

## Implementation
<!-- Write you've done in here -->
```

## Rules

### Task Title
- Derive from the user's request or the referenced file

### Context
- Include relevant file paths using `@path/to/file`
- Describe the current state of the codebase or relevant area
- If a file is referenced, read it first to understand current state

### Goals
- What needs to be created, changed, or fixed
- Be specific and measurable

### Notes
- Concerns, edge cases, or gotchas the implementer should know
- Reference related tasks or patterns if relevant

### Testing
- How to verify: feature tests, curl for APIs, Playwright for UI (only if needed — Playwright consumes a lot of tokens)

### Tools / Skills
- List relevant MCP tools, skills, or bash commands that will help
- Check available skills or MCPs before listing

### Implementation
- Leave as `<!-- Write you've done in here -->`
- This section is updated by the agent doing the work, not during planning

### Plan File Location
Check for existing task directories in this order:
- `todos/`
- `todo/`
- `task/`
- `tasks/`

Save the plan file there with a clear, kebab-case filename.
