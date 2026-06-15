---
name: creator-plan
description: Create a plan base on the title and simple detail
---
# Plan Prompt
Create a detailed plan for a <given md file> with format like:

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
- 

## Tools / Skills
- mcp database / tools

## Implementation
<!-- Write you've done in here -->
```

## Rules
### Created files
sometime project has theese directory, please check it first and you will know where's the task directory should be created
- todos/
- todo/
- task/
- tasks/

## Details
### task title
- the title is base on the given file

### Context
- Context is the related file that give ai detail where, what, and how the given files
- and give the detailed current condition if needed

### Goals
- the thing that ai should be done
- should be created, or changes

### Notes
- notes is tell ai what ai need to be concern

### Testing
- you can give ai information how need to do with testing, like using test feature, or curl if api, or playwright if need to test in browser
- for playwright if needed, because playwright consumpt a lot of token

### Tools / Skills
- what tools, mcp or skills that ai use
- check the available skills or mcp
- tools you can give the bash command if needed

### Implementation
- don't create this first, just add `<!-- Write you've done in here -->`
- this is only need to update when the ai done with their works, you don't need to create this

