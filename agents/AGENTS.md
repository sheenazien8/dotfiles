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
