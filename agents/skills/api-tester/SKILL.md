---
name: api-tester
description: Test REST or HTTP APIs systematically, validate responses, headers, status codes, and detect integration issues.
tags: [api, http, testing, debugging]
---

# API Tester Skill

## Purpose

This skill is used to test and validate APIs in a structured and reliable way.

It ensures:
- Correct HTTP methods
- Proper request payload
- Correct headers
- Accurate response validation

Prevents guessing about API behavior.

---

## When to Use

Use this skill when:

- The user wants to test an endpoint
- Debugging 4xx or 5xx errors
- Validating authentication
- Testing CRUD endpoints
- Verifying API contracts
- Checking CORS or headers
- Testing rate limits

---

## API Testing Workflow

### Identify Endpoint Details

Confirm:

- Base URL
- HTTP method (GET, POST, PUT, DELETE, PATCH)
- Required headers
- Authentication method
- Request body format

If unclear, ask for missing details.

---

### Validate Authentication

Check whether API requires:

- Bearer token
- API key
- Basic auth
- Session cookie

If missing, inform user before testing.

---

### Send Request

Use appropriate tool (curl, HTTP client, etc).

Example:

```bash
curl -X POST https://api.example.com/users \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"John"}'
```

### Tools
- curl
- httpie
- jq
