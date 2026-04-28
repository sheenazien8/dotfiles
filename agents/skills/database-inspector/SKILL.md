---
name: database-inspector
description: Inspect database schema, tables, indexes, constraints, functions, views, and analyze structure before modifying anything.
tags: [database, schema, sql, inspection]
---

# Database Inspector Skill

## Purpose

This skill is used to safely inspect a database structure before making schema changes, writing queries, generating migrations, or debugging data-related issues.

It prevents hallucination about tables or columns that may not exist.

---

## When to Use

Use this skill when:

- The user asks about database structure
- You need to generate queries or migrations
- You are debugging database errors
- You need to verify columns, indexes, or constraints
- You are modifying models or relationships
- You are analyzing performance issues
- You are debugging why the data from API didn't results as expected

Do NOT assume schema structure without inspecting it.

---

## Inspection Workflow

Follow this order:

### Identify Database Type

Detect whether it is:
- PostgreSQL
- MySQL
- SQLite
- SQL Server

Check:
- configuration files
- environment variables
- connection strings

---

### Tools
- Sometimes the project has mcp and if has always use the mcp, but if not you can use the .env or asking the user
