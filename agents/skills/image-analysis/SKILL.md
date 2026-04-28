---
name: image-analysis
description: Automatically delegate image-related tasks to the reader-images subagent
---

## When to use

Load this skill when:
- You encounter image files (png, jpg, jpeg, gif, webp, svg, bmp)
- User asks about visual content, screenshots, or diagrams
- User requests OCR or text extraction from images
- User wants to analyze charts, graphs, or visual data

## Instructions

When you detect an image in the conversation:
1. Immediately invoke `@reader-images` subagent
2. Pass the image reference or path to the subagent
3. Wait for the analysis before responding to the user

Never try to describe images yourself - always delegate to `@reader-images`.
