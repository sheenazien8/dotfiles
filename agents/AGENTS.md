# Global Rules

## Code Generation
- Don't write code unless explicitly requested by the user
- Only generate code when user asks for implementation
- Never assume what code needs to be written

## Simplicity
- Keep all solutions simple and straightforward
- Avoid overengineering or complex patterns
- Use minimal code to achieve the goal
- Don't add unnecessary features or abstractions

## Comments and Documentation
- Don't add inline comments in code
- Don't add explanatory comments
- Only use docs for method documentation when required
- Keep code self-explanatory without comments

## Response Style
- Be concise and direct
- Focus on what was requested
- Don't explain obvious things
- Ask clarifying questions if requirements are unclear

## Skils
- please read all of the available skill, and use that if you need that

## Git 
- Don't commit your changes unless user requuest it

## Development Guidelines
### Laravel Projects

#### 1. Architecture

- Follow Clean Architecture principles
- Business logic MUST NOT live inside Controllers
- Use:
  - Services for domain logic
  - Repositories for data abstraction (if required)
  - FormRequest for validation
- Avoid fat Controllers and fat Models
- Controllers should only orchestrate request → service → response

---

#### 2. Code Standards

- Follow PSR-12
- Use PHP 8.2+
- Use typed properties
- Use explicit return types
- Avoid `mixed`
- Prefer constructor injection over facades (except config/log)
- No static business logic

Example:

```php
public function store(StoreUserRequest $request): JsonResponse
{
    $user = $this->userService->create($request->validated());

    return response()->json($user);
}
```

#### Database
* Always use migrations
* No raw SQL unless absolutely necessary
* Define proper relationships
* Add indexes for:
* Foreign keys
* Frequently filtered columns
* Never ignore N+1 problems

#### API Design
* Follow RESTful conventions
* Use API Resources for JSON transformation
* Standard JSON format:
```
{
  "success": true,
  "data": {},
  "message": ""
}
```
* avoid above if you know that's the current project is use different format, and follow the current project format

#### Testing
* Feature tests for endpoints
* Unit tests for services
* Use factories
* Do not hit external APIs in tests
* Tests must be deterministic

#### Security
* Always validate input
* Use Policies for authorization
* Never expose stack traces in production
* Sanitize user-generated content

### Golang Projects


### Typescript Projects


### Flutter Projects

## Databases
- You have to use mcp when you need to fetch the database schema
- Always prioritize fetch the data using mcp if available, before grep the code for knowing the schema

## Workflow Orchestration
### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update tasks/lessons.md with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
##*# 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes -- don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests -- then resolve them
- Zero context switching required from the user
- Go fix failing Cl tests without being told how

## Task Management
1. Plan First: Write plan to tasks/todo.md with checkable items
2. Verify Plan: Check in before starting implementation
3. Track Progress: Mark items complete as you go
4. Explain Changes: High-level summary at each step
5. Document Results: Add review section to tasks/todo.d
6. Capture Lessons: Update tasks/lessons.md after corrections

## Core Principles
- Simplicity First: Make every change as simple as possible. Impact minimal code.
- No Laziness: Find root causes. No temporary fixes. Senior developer standards.
- Minimal Impact: Changes should only touch what's necessary. Avoid introducing bugs.
