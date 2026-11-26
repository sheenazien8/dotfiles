import { spawn } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { resolveKeys } from "./lib/keybindings.ts";

type ContentBlock = { type: string; text?: string; mimeType?: string };

function blocksToText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	const parts: string[] = [];
	for (const raw of content) {
		const block = raw as ContentBlock;
		if (block?.type === "text" && typeof block.text === "string") parts.push(block.text);
		else if (block?.type === "image") parts.push(`[image: ${block.mimeType ?? "unknown"}]`);
	}
	return parts.join("\n");
}

function fence(text: string, lang = ""): string {
	const ticks = text.includes("```") ? "````" : "```";
	return `${ticks}${lang}\n${text}\n${ticks}`;
}

function renderMessage(message: { role?: string; [key: string]: unknown }): string[] {
	const out: string[] = [];

	if (message.role === "user") {
		const text = blocksToText(message.content).trim();
		if (text) out.push("## User", "", text, "");
		return out;
	}

	if (message.role === "assistant") {
		const model = `${message.provider ?? "?"}/${message.model ?? "?"}`;
		out.push(`## Assistant (${model})`, "");
		const content = Array.isArray(message.content) ? (message.content as ContentBlock[]) : [];
		for (const block of content) {
			if (block.type === "thinking" && typeof block.text === "string" && block.text.trim()) {
				out.push("<details><summary>thinking</summary>", "", block.text.trim(), "", "</details>", "");
			}
		}
		for (const block of content) {
			if (block.type === "text" && typeof block.text === "string" && block.text.trim()) {
				out.push(block.text.trim(), "");
			} else if (block.type === "toolCall") {
				const call = block as unknown as { name?: string; arguments?: unknown };
				out.push(`**Tool call: \`${call.name ?? "?"}\`**`, "", fence(JSON.stringify(call.arguments ?? {}, null, 2), "json"), "");
			}
		}
		return out;
	}

	if (message.role === "toolResult") {
		const name = typeof message.toolName === "string" ? message.toolName : "tool";
		const error = message.isError === true ? " (error)" : "";
		out.push(`**Tool result: \`${name}\`${error}**`, "");
		const text = blocksToText(message.content).trim();
		if (text) out.push(fence(text), "");
		return out;
	}

	if (message.role === "system") {
		const text = blocksToText(message.content).trim();
		if (text) out.push("## System", "", text, "");
		return out;
	}

	return out;
}

function renderEntry(entry: {
	type: string;
	timestamp?: string;
	[key: string]: unknown;
}): string[] {
	if (entry.type === "message") {
		const message = entry.message as { role?: string };
		if (!message || typeof message !== "object") return [];
		return renderMessage(message as { role?: string; [key: string]: unknown });
	}

	if (entry.type === "compaction") {
		const summary = typeof entry.summary === "string" ? entry.summary : "";
		return [`> **Compaction summary**`, "", ...summary.split("\n").map((line) => `> ${line}`), ""];
	}

	if (entry.type === "branch_summary") {
		const summary = typeof entry.summary === "string" ? entry.summary : "";
		return [`> **Branch summary**`, "", ...summary.split("\n").map((line) => `> ${line}`), ""];
	}

	if (entry.type === "model_change") {
		return [`_model changed to \`${entry.provider ?? "?"}/${entry.modelId ?? "?"}\`_`, ""];
	}

	if (entry.type === "thinking_level_change") {
		return [`_thinking level set to \`${entry.thinkingLevel ?? "?"}\`_`, ""];
	}

	return [];
}

function buildTranscript(ctx: ExtensionContext): string {
	const name = ctx.sessionManager.getSessionName();
	const id = ctx.sessionManager.getSessionId();
	const entries = ctx.sessionManager.buildContextEntries();

	const lines: string[] = [
		"# Pi session transcript",
		"",
		`- Session: ${name ?? id}`,
		`- Directory: ${ctx.cwd}`,
		`- Generated: ${new Date().toISOString()}`,
		"",
		"---",
		"",
	];

	for (const entry of entries) {
		lines.push(...renderEntry(entry as unknown as { type: string; [key: string]: unknown }));
	}

	return `${lines.join("\n").replace(/\n{3,}/g, "\n\n").trimEnd()}\n`;
}

function resolveEditor(): { command: string; args: string[] } {
	const configured = (process.env.VISUAL || process.env.EDITOR || "nvim").trim();
	const [command, ...args] = configured.split(/\s+/);
	return { command, args };
}

async function openTranscriptInEditor(ctx: ExtensionContext): Promise<void> {
	if (!ctx.hasUI) {
		ctx.ui.notify("Open transcript in editor requires TUI mode", "warning");
		return;
	}

	const transcript = buildTranscript(ctx);
	if (!transcript.includes("## ")) {
		ctx.ui.notify("Nothing in the conversation yet", "info");
		return;
	}

	const directory = mkdtempSync(join(tmpdir(), "pi-transcript-"));
	const filePath = join(directory, "transcript.md");
	writeFileSync(filePath, transcript, "utf-8");

	const { command, args } = resolveEditor();

	await ctx.ui.custom<void>((tui, _theme, _kb, done) => {
		tui.stop();
		process.stdout.write("\x1b[2J\x1b[H");

		const finish = () => {
			try {
				rmSync(directory, { recursive: true, force: true });
			} catch {
				// best effort
			}
			tui.start();
			tui.requestRender(true);
			done(undefined);
		};

		const child = spawn(command, [...args, filePath], { stdio: "inherit", env: process.env });
		child.on("error", finish);
		child.on("close", finish);

		return { render: () => [], invalidate: () => {} };
	});
}

export default function transcriptEditor(pi: ExtensionAPI) {
	const handler = async (ctx: ExtensionContext) => {
		await openTranscriptInEditor(ctx);
	};

	for (const key of resolveKeys("extension.transcriptEditor", ["alt+v", "f4"])) {
		pi.registerShortcut(key, { description: "Open conversation transcript in $EDITOR", handler });
	}

	pi.registerCommand("history", {
		description: "Open the full conversation in $EDITOR (nvim/vim)",
		handler: async (_args, ctx) => {
			await openTranscriptInEditor(ctx);
		},
	});
}
