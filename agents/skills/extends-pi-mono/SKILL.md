---
name: extends-pi-mono
description: Create or extends pi coding agents with extension
---

# How to Create Custom Extensions for the Pi Coding Agent: A Complete Guide

> Learn how to create custom extensions for the Pi coding agent. This guide shows you how to write TypeScript or JavaScript modules to register tools, commands, and lifecycle hooks.

- Repository: [Mario Zechner/pi-mono](https://github.com/badlogic/pi-mono)
- Tags: how-to-guide
- Published: 2026-02-16

---

**You can create custom extensions for the Pi coding agent by writing a TypeScript or JavaScript module that exports a default factory function receiving an `ExtensionAPI` object, allowing you to register tools, commands, and lifecycle hooks.**

The Pi coding agent from the `badlogic/pi-mono` repository supports a powerful plugin architecture that enables developers to create custom extensions without modifying core code. By leveraging the `ExtensionAPI` defined in [`src/core/extensions/types.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/types.ts), you can add new tools, UI interactions, and automation hooks to tailor the agent to your specific workflow.

## Understanding the Pi Extension Architecture

### The ExtensionAPI Object

An extension is simply a module that exports a default function receiving an **`ExtensionAPI`** object. This API provides three functional groups:

- **Registration methods** – `on()`, `registerTool()`, `registerCommand()`, `registerShortcut()`, `registerFlag()`, `registerMessageRenderer()`
- **Flag access** – `getFlag()` to read configuration values
- **Action methods** – `sendMessage()`, `exec()`, `setLabel()`, `setModel()`, and UI helpers via `ctx.ui.*`

The complete type definitions reside in **[`src/core/extensions/types.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/types.ts)**, which specifies the `ExtensionAPI` interface and all related event types.

### Extension Discovery and Loading Pipeline

The loading pipeline lives in **[`src/core/extensions/loader.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/loader.ts)** and executes four distinct phases:

1. **Discover** – The `discoverExtensionsInDir` function scans `./extensions/` (global) and `./.pi/extensions/` (project-local) for `*.ts` and `*.js` files
2. **Resolve** – `resolveExtensionEntries` checks for a [`package.json`](https://github.com/badlogic/pi-mono/blob/main/package.json) with a `pi.extensions` field or falls back to [`index.ts`](https://github.com/badlogic/pi-mono/blob/main/index.ts) entry points
3. **Load** – `loadExtension` creates a runtime stub via `createExtensionRuntime`, then invokes the exported factory function with the API object created by `createExtensionAPI`
4. **Bind** – `loadExtensionFromFactory` replaces stub methods with real implementations from the core `ExtensionRunner`, allowing safe action calls

## How to Create a Custom Extension for Pi

### Basic Extension Structure

Every extension must export a default factory function. Here is the minimal "Hello World" example from **[`examples/extensions/hello.ts`](https://github.com/badlogic/pi-mono/blob/main/examples/extensions/hello.ts)**:

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Run once when the agent starts
  pi.on("agent_start", async () => {
    console.log("👋 Hello from my custom extension!");
  });

  // Add a slash-command that the user can type
  pi.registerCommand("greet", {
    description: "Say hello from the extension",
    handler: async (_args, ctx) => {
      ctx.ui.notify("Hello, world!", "info");
    },
  });
}

```

### Registering Lifecycle Events

The `pi.on()` method lets you hook into agent lifecycle events defined in [`src/core/extensions/types.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/types.ts). Available events include:

- `agent_start` – Fires when the agent process starts
- `session_start` / `session_end` – Conversation open/close
- `turn_start` / `turn_end` – Each LLM interaction cycle
- `tool_call` – Before a tool executes
- `session_before_switch` – When clearing conversation history

Example usage:

```typescript
pi.on("turn_start", () => {
  console.log("New turn beginning");
});

pi.on("tool_call", async (event, ctx) => {
  if (event.toolName === "bash") {
    console.log("About to execute bash command");
  }
});

```

### Creating Custom Tools

Tools extend the agent's capabilities beyond built-in commands. Register a tool using `pi.registerTool()` with a `ToolDefinition` object:

```typescript
import type { ExtensionAPI, ToolDefinition } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const reverseTool: ToolDefinition = {
    name: "reverse",
    description: "Reverse a string",
    async run(args) {
      const text = args.join(" ");
      return { output: text.split("").reverse().join("") };
    },
  };

  pi.registerTool(reverseTool);
}

```

Users can now invoke `/reverse hello world` and receive "dlrow olleh" as output.

### Adding Commands and Shortcuts

Beyond tools, you can register slash commands and keyboard shortcuts:

```typescript
// Register a slash command
pi.registerCommand("deploy", {
  description: "Deploy the current project",
  handler: async (args, ctx) => {
    await ctx.exec("npm", ["run", "deploy"]);
    ctx.ui.notify("Deployment complete", "success");
  },
});

// Register a keyboard shortcut (Ctrl+Shift+T)
pi.registerShortcut("ctrl+shift+t", async (ctx) => {
  await ctx.sendMessage("Trigger custom workflow");
});

```

## UI Integration and RPC Mode

### Available UI Methods

When the agent runs with `--mode rpc`, extensions can interact with the client UI through `ctx.ui`. The API includes:

- `select(title, options)` – Modal list selection
- `confirm(title, message)` – Yes/no dialog
- `input(prompt, placeholder)` – Single-line text input
- `editor(title, prefill)` – Multi-line text editor
- `notify(message, type?)` – Toast notifications
- `setTitle(title)`, `setWidget(id, content)`, `setStatus(text)`, `setEditorText(text)` – Status bar and editor updates

The **[`examples/extensions/rpc-demo.ts`](https://github.com/badlogic/pi-mono/blob/main/examples/extensions/rpc-demo.ts)** file demonstrates every UI method in action.

### Example: Dangerous Command Confirmation

This extension intercepts `bash` tool calls and prompts the user before executing dangerous commands:

```typescript
// block-dangerous-bash.ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const cmd = (event.input as { command: string }).command;
    const dangerous = /\b(rm\s+(-rf?|--recursive)|sudo)\b/.test(cmd);

    if (!dangerous) return;
    if (!ctx.hasUI) return { block: true, reason: "No UI to confirm" };

    const chosen = await ctx.ui.select(`Run dangerous command? ${cmd}`, ["Allow", "Block"]);
    if (chosen !== "Allow") {
      ctx.ui.notify("Command blocked", "warning");
      return { block: true, reason: "User blocked" };
    }

    ctx.ui.notify("Command allowed", "info");
  });
}

```

## Extension Distribution and Discovery

### Project-Local Extensions

For extensions specific to a single project, place TypeScript or JavaScript files in the `./.pi/extensions/` directory. The `discoverExtensionsInDir` function in [`src/core/extensions/loader.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/loader.ts) automatically scans this location when the agent starts in that project directory.

### Global Extensions

For extensions available across all projects, copy files to `$PI_AGENT_DIR/extensions/` (typically `~/.pi/extensions/` on the host). The `getAgentDir()` function in [`src/config.ts`](https://github.com/badlogic/pi-mono/blob/main/src/config.ts) determines the global directory path.

### NPM Package Distribution

Extensions can be distributed as standard npm packages using the `pi.extensions` manifest field. Create a [`package.json`](https://github.com/badlogic/pi-mono/blob/main/package.json) with:

```json
{
  "name": "pi-awesome-extension",
  "version": "0.1.0",
  "main": "dist/index.js",
  "pi": {
    "extensions": ["src/index.ts"]
  }
}

```

The `discoverAndLoadExtensions` function reads this manifest via `readPiManifest` (lines 65-71 in [`src/core/extensions/loader.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/loader.ts)) and loads the specified entry points. After installing the package with `npm i`, Pi automatically discovers and loads the extension.

## Summary

- **Extensions are factory functions** that receive an `ExtensionAPI` object and register capabilities through its methods.
- **Discovery happens automatically** in `./.pi/extensions/` (project-local) and `$PI_AGENT_DIR/extensions/` (global), or via npm packages with a `pi.extensions` manifest.
- **The loading pipeline** in [`src/core/extensions/loader.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/loader.ts) handles discovery, resolution, runtime creation, and binding through functions like `discoverExtensionsInDir`, `resolveExtensionEntries`, and `loadExtensionFromFactory`.
- **You can register tools, commands, shortcuts, and event listeners** to extend functionality at every lifecycle stage from `agent_start` to `tool_call`.
- **UI integration** works in RPC mode through `ctx.ui` methods like `select()`, `confirm()`, and `notify()`, enabling interactive extensions.

## Frequently Asked Questions

### What programming languages can I use to create Pi coding agent extensions?

You can write Pi coding agent extensions in **TypeScript** or **JavaScript**. The extension loader in [`src/core/extensions/loader.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/loader.ts) discovers and executes both `.ts` and `.js` files. TypeScript is recommended for full type safety and IntelliSense support via the `@mariozechner/pi-coding-agent` package types defined in [`src/core/extensions/types.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/types.ts).

### How does the Pi extension loader discover and load my custom extension?

The discovery process uses `discoverExtensionsInDir` and `discoverAndLoadExtensions` in [`src/core/extensions/loader.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/loader.ts). It scans `./.pi/extensions/` (project-local) and the global extensions directory (resolved by `getAgentDir()` in [`src/config.ts`](https://github.com/badlogic/pi-mono/blob/main/src/config.ts)) for `*.ts` and `*.js` files. For npm packages, it reads the `pi.extensions` field via `readPiManifest`. Each discovered file is loaded via `loadExtension`, which creates a runtime stub with `createExtensionRuntime`, then invokes your factory function with the `ExtensionAPI` created by `createExtensionAPI`.

### Can I modify the Pi coding agent UI from within an extension?

Yes, when running in RPC mode (`--mode rpc`), extensions can interact with the client UI through the `ctx.ui` object available in handlers and event callbacks. The `ExtensionAPI` provides UI methods including `select()`, `confirm()`, `input()`, `editor()`, `notify()`, `setTitle()`, and `setStatus()`. These are defined in [`src/core/extensions/types.ts`](https://github.com/badlogic/pi-mono/blob/main/src/core/extensions/types.ts) and demonstrated in [`examples/extensions/rpc-demo.ts`](https://github.com/badlogic/pi-mono/blob/main/examples/extensions/rpc-demo.ts). Note that UI access requires `ctx.hasUI` to be true, indicating an RPC client is connected.

### Where should I place my extension files for automatic discovery?

You have three options for extension placement. **Project-local extensions** belong in `./.pi/extensions/` relative to your working directory, scanned automatically by `discoverExtensionsInDir`. **Global extensions** go in `$PI_AGENT_DIR/extensions/` (typically `~/.pi/extensions/`), resolved via `getAgentDir()` in [`src/config.ts`](https://github.com/badlogic/pi-mono/blob/main/src/config.ts). **NPM packages** containing a `pi.extensions` manifest field are discovered after installation in `node_modules`. You can also load extensions explicitly via the CLI flag `--extension path/to/file.ts`.
