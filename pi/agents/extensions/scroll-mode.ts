import { spawn } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { Component, TUI } from "@earendil-works/pi-tui";
import { Key, Markdown, matchesKey, truncateToWidth, visibleWidth, CURSOR_MARKER, stripTerminalSequences } from "@earendil-works/pi-tui";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { getMarkdownTheme } from "@earendil-works/pi-coding-agent";
import { resolveKeys } from "./lib/keybindings.ts";

type MarkdownTheme = ReturnType<typeof getMarkdownTheme>;

interface Block {
	label: string;
	body: string;
}

type Dict = { [key: string]: unknown };

function contentText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	const parts: string[] = [];
	for (const raw of content) {
		const block = raw as { type?: string; text?: string; mimeType?: string };
		if (block?.type === "text" && typeof block.text === "string") parts.push(block.text);
		else if (block?.type === "image") parts.push(`[image: ${block.mimeType ?? "unknown"}]`);
	}
	return parts.join("\n");
}

function fence(text: string, lang = ""): string {
	const ticks = text.includes("```") ? "````" : "```";
	return `${ticks}${lang}\n${text}\n${ticks}`;
}

function entryToBlock(entry: Dict): Block | undefined {
	if (entry.type === "message") {
		const message = entry.message as Dict | undefined;
		if (!message || typeof message !== "object") return undefined;

		if (message.role === "user") {
			const text = contentText(message.content).trim();
			return text ? { label: "You", body: text } : undefined;
		}

		if (message.role === "assistant") {
			const model = `${message.provider ?? "?"}/${message.model ?? "?"}`;
			const parts: string[] = [];
			const content = Array.isArray(message.content) ? (message.content as Dict[]) : [];
			for (const block of content) {
				if (block.type === "thinking" && typeof block.text === "string" && block.text.trim()) {
					parts.push("<details><summary>thinking</summary>", "", block.text.trim(), "", "</details>", "");
				}
			}
			for (const block of content) {
				if (block.type === "text" && typeof block.text === "string" && block.text.trim()) {
					parts.push(block.text.trim(), "");
				} else if (block.type === "toolCall") {
					parts.push(`**Tool call: \`${block.name ?? "?"}\`**`, "", fence(JSON.stringify(block.arguments ?? {}, null, 2), "json"), "");
				}
			}
			const body = parts.join("\n").trimEnd();
			return body ? { label: `Assistant · ${model}`, body } : undefined;
		}

		if (message.role === "toolResult") {
			const name = typeof message.toolName === "string" ? message.toolName : "tool";
			const error = message.isError === true ? " (error)" : "";
			const text = contentText(message.content).trim();
			return text ? { label: `Tool · ${name}${error}`, body: fence(text) } : undefined;
		}
		return undefined;
	}

	if (entry.type === "compaction") {
		const summary = typeof entry.summary === "string" ? entry.summary : "";
		return summary ? { label: "Compaction summary", body: summary } : undefined;
	}

	if (entry.type === "branch_summary") {
		const summary = typeof entry.summary === "string" ? entry.summary : "";
		return summary ? { label: "Branch summary", body: summary } : undefined;
	}

	if (entry.type === "model_change") {
		return { label: "Model changed", body: `\`${entry.provider ?? "?"}/${entry.modelId ?? "?"}\`` };
	}

	if (entry.type === "thinking_level_change") {
		return { label: "Thinking level", body: `\`${entry.thinkingLevel ?? "?"}\`` };
	}

	if (entry.type === "custom_message") {
		const text = contentText(entry.content).trim();
		return text ? { label: `Custom · ${entry.customType ?? "?"}`, body: text } : undefined;
	}

	return undefined;
}

function buildBlocks(ctx: ExtensionContext): Block[] {
	const blocks: Block[] = [];
	for (const entry of ctx.sessionManager.buildContextEntries()) {
		const block = entryToBlock(entry as unknown as Dict);
		if (block) blocks.push(block);
	}
	return blocks;
}

function fit(line: string, width: number): string {
	const w = visibleWidth(line);
	if (w > width) return truncateToWidth(line, width);
	if (w === width) return line;
	return line + " ".repeat(width - w);
}

function clamp(value: number, min: number, max: number): number {
	return Math.max(min, Math.min(max, value));
}

function extractAnsiCode(str: string, pos: number): { code: string; length: number } | null {
	if (pos >= str.length || str[pos] !== "\x1b") return null;
	const next = str[pos + 1];
	if (next === "[") {
		let j = pos + 2;
		while (j < str.length && !/[mGKHJ]/.test(str[j])) j++;
		if (j < str.length) return { code: str.substring(pos, j + 1), length: j + 1 - pos };
		return null;
	}
	if (next === "]" || next === "_") {
		let j = pos + 2;
		while (j < str.length) {
			if (str[j] === "\x07") return { code: str.substring(pos, j + 1), length: j + 1 - pos };
			if (str[j] === "\x1b" && str[j + 1] === "\\") return { code: str.substring(pos, j + 2), length: j + 2 - pos };
			j++;
		}
		return null;
	}
	return null;
}

function getSearchHighlight(theme: Theme, text: string): string {
	try {
		return theme.bg("searchMatchBg", theme.fg("searchMatchText", theme.bold(text)));
	} catch {
		return theme.inverse(theme.bold(text));
	}
}

function highlightSearchMatches(line: string, query: string, theme: Theme): string {
	if (!query) return line;

	const lowerQuery = query.toLowerCase();
	const visibleToOrig: number[] = [];
	let visibleCount = 0;
	for (let i = 0; i < line.length; ) {
		const ansi = extractAnsiCode(line, i);
		if (ansi) {
			i += ansi.length;
			continue;
		}
		visibleToOrig[visibleCount] = i;
		visibleCount++;
		i++;
	}
	visibleToOrig[visibleCount] = line.length;

	const plain = stripTerminalSequences(line).toLowerCase();

	const parts: string[] = [];
	let lastEnd = 0;

	for (let i = 0; i <= plain.length - lowerQuery.length; ) {
		if (plain.slice(i, i + lowerQuery.length) === lowerQuery) {
			if (lastEnd < i) {
				const origStart = visibleToOrig[lastEnd];
				const origEnd = visibleToOrig[i];
				parts.push(line.slice(origStart, origEnd));
			}

			const matchOrigStart = visibleToOrig[i];
			const matchOrigEnd = visibleToOrig[i + lowerQuery.length];
			const matchText = line.slice(matchOrigStart, matchOrigEnd);
			parts.push(getSearchHighlight(theme, matchText));

			lastEnd = i + lowerQuery.length;
			i = lastEnd;
		} else {
			i++;
		}
	}

	if (lastEnd < plain.length) {
		const origStart = visibleToOrig[lastEnd];
		parts.push(line.slice(origStart));
	}

	return parts.join("");
}

const PIN_BOTTOM = -1;

function resolveEditor(): { command: string; args: string[] } {
	const configured = (process.env.VISUAL || process.env.EDITOR || "nvim").trim();
	const [command, ...args] = configured.split(/\s+/);
	return { command, args };
}

function transcriptText(blocks: Block[]): string {
	return `${blocks
		.map((block) => `${block.label}\n${"-".repeat(Math.max(3, block.label.length))}\n\n${block.body}`)
		.join("\n\n")}\n`;
}

class ScrollModeComponent implements Component {
	private scrollTop = PIN_BOTTOM;
	private cache?: { width: number; lines: string[] };
	private lastViewport = 1;
	private flash?: string;
	private flashTimer?: ReturnType<typeof setTimeout>;
	private editorBusy = false;
	private searchActive = false;
	private searchQuery = "";
	private searchCursor = 0;
	private searchMatches: number[] = [];
	private searchMatchIndex = -1;

	constructor(
		private readonly tui: TUI,
		private readonly theme: Theme,
		private readonly blocks: Block[],
		private readonly mdTheme: MarkdownTheme,
		private readonly onExit: () => void,
	) {}

	dispose(): void {
		if (this.flashTimer) clearTimeout(this.flashTimer);
	}

	invalidate(): void {
		this.cache = undefined;
	}

	private build(width: number): string[] {
		if (this.cache?.width === width) return this.cache.lines;
		const lines: string[] = [];
		for (const block of this.blocks) {
			lines.push(this.theme.fg("accent", this.theme.bold(block.label)));
			const markdown = new Markdown(block.body, 0, 0, this.mdTheme);
			lines.push(...markdown.render(width));
			lines.push("");
		}
		this.cache = { width, lines };
		return lines;
	}

	private scroll(delta: number): void {
		const total = this.cache?.lines.length ?? 0;
		const maxScroll = Math.max(0, total - this.lastViewport);
		if (this.scrollTop === PIN_BOTTOM) this.scrollTop = maxScroll;
		this.scrollTop = clamp(this.scrollTop + delta, 0, maxScroll);
		this.tui.requestRender();
	}

	private showFlash(message: string): void {
		this.flash = message;
		if (this.flashTimer) clearTimeout(this.flashTimer);
		this.flashTimer = setTimeout(() => {
			this.flash = undefined;
			this.tui.requestRender();
		}, 1500);
		this.tui.requestRender();
	}

	private async openInEditor(): Promise<void> {
		if (this.editorBusy) return;
		this.editorBusy = true;

		const directory = mkdtempSync(join(tmpdir(), "pi-scroll-"));
		const filePath = join(directory, "transcript.txt");
		writeFileSync(filePath, transcriptText(this.blocks), "utf-8");
		const { command, args } = resolveEditor();

		this.tui.stop();
		process.stdout.write("\x1b[2J\x1b[H");

		await new Promise<void>((resolve) => {
			const child = spawn(command, [...args, filePath], { stdio: "inherit", env: process.env });
			child.on("error", () => resolve());
			child.on("close", () => resolve());
		});

		try {
			rmSync(directory, { recursive: true, force: true });
		} catch {
			// best effort
		}

		this.editorBusy = false;
		this.tui.start();
		this.tui.requestRender(true);
		this.showFlash("Opened transcript in editor");
	}

	private startSearch(): void {
		this.searchActive = true;
		this.searchQuery = "";
		this.searchCursor = 0;
		this.searchMatches = [];
		this.searchMatchIndex = -1;
		this.tui.requestRender();
	}

	private cancelSearch(): void {
		this.searchActive = false;
		this.tui.requestRender();
	}

	private clearSearch(): void {
		this.searchActive = false;
		this.searchQuery = "";
		this.searchCursor = 0;
		this.searchMatches = [];
		this.searchMatchIndex = -1;
		this.tui.requestRender();
	}

	private findMatches(): void {
		if (!this.searchQuery) {
			this.searchMatches = [];
			this.searchMatchIndex = -1;
			return;
		}
		const query = this.searchQuery.toLowerCase();
		const lines = this.cache?.lines ?? this.build(this.cache?.width ?? 80);
		const matches: number[] = [];
		for (let i = 0; i < lines.length; i++) {
			if (lines[i].toLowerCase().includes(query)) {
				matches.push(i);
			}
		}
		this.searchMatches = matches;
		this.searchMatchIndex = matches.length > 0 ? 0 : -1;
		if (this.searchMatchIndex >= 0) {
			this.scrollToLine(this.searchMatches[this.searchMatchIndex]);
		}
	}

	private scrollToLine(lineIndex: number): void {
		const viewportHeight = Math.max(3, this.tui.terminal.rows - 2);
		const maxScroll = Math.max(0, (this.cache?.lines.length ?? 0) - viewportHeight);
		this.scrollTop = clamp(lineIndex - Math.floor(viewportHeight / 2), 0, maxScroll);
		this.tui.requestRender();
	}

	private gotoMatch(delta: number): void {
		if (this.searchMatches.length === 0) return;
		this.searchMatchIndex = (this.searchMatchIndex + delta + this.searchMatches.length) % this.searchMatches.length;
		this.scrollToLine(this.searchMatches[this.searchMatchIndex]);
	}

	private handleSearchInput(data: string): void {
		if (matchesKey(data, Key.escape)) {
			this.cancelSearch();
			return;
		}
		if (matchesKey(data, Key.enter)) {
			this.searchActive = false;
			this.tui.requestRender();
			return;
		}
		if (matchesKey(data, Key.backspace)) {
			if (this.searchCursor > 0) {
				this.searchQuery = this.searchQuery.slice(0, this.searchCursor - 1) + this.searchQuery.slice(this.searchCursor);
				this.searchCursor--;
				this.findMatches();
				this.tui.requestRender();
			}
			return;
		}
		if (matchesKey(data, Key.delete)) {
			if (this.searchCursor < this.searchQuery.length) {
				this.searchQuery = this.searchQuery.slice(0, this.searchCursor) + this.searchQuery.slice(this.searchCursor + 1);
				this.findMatches();
				this.tui.requestRender();
			}
			return;
		}
		if (matchesKey(data, Key.left)) {
			if (this.searchCursor > 0) {
				this.searchCursor--;
				this.tui.requestRender();
			}
			return;
		}
		if (matchesKey(data, Key.right)) {
			if (this.searchCursor < this.searchQuery.length) {
				this.searchCursor++;
				this.tui.requestRender();
			}
			return;
		}
		if (matchesKey(data, Key.home)) {
			this.searchCursor = 0;
			this.tui.requestRender();
			return;
		}
		if (matchesKey(data, Key.end)) {
			this.searchCursor = this.searchQuery.length;
			this.tui.requestRender();
			return;
		}
		if (matchesKey(data, Key.ctrl("u"))) {
			this.searchQuery = "";
			this.searchCursor = 0;
			this.findMatches();
			this.tui.requestRender();
			return;
		}
		if (data.length === 1 && data.charCodeAt(0) >= 32 && data.charCodeAt(0) < 127) {
			this.searchQuery = this.searchQuery.slice(0, this.searchCursor) + data + this.searchQuery.slice(this.searchCursor);
			this.searchCursor++;
			this.findMatches();
			this.tui.requestRender();
			return;
		}
	}

	handleInput(data: string): void {
		if (this.searchActive) {
			this.handleSearchInput(data);
			return;
		}
		if (matchesKey(data, Key.ctrl("j")) || matchesKey(data, "j") || matchesKey(data, Key.down)) {
			this.scroll(1);
			return;
		}
		if (matchesKey(data, Key.ctrl("k")) || matchesKey(data, "k") || matchesKey(data, Key.up)) {
			this.scroll(-1);
			return;
		}
		if (matchesKey(data, Key.pageDown) || matchesKey(data, Key.ctrl("f"))) {
			this.scroll(this.lastViewport);
			return;
		}
		if (matchesKey(data, Key.pageUp) || matchesKey(data, Key.ctrl("b"))) {
			this.scroll(-this.lastViewport);
			return;
		}
		if (matchesKey(data, Key.ctrl("d"))) {
			this.scroll(Math.max(1, Math.floor(this.lastViewport / 2)));
			return;
		}
		if (matchesKey(data, Key.ctrl("u"))) {
			this.scroll(-Math.max(1, Math.floor(this.lastViewport / 2)));
			return;
		}
		if (matchesKey(data, "g") || matchesKey(data, Key.home)) {
			this.scrollTop = 0;
			this.tui.requestRender();
			return;
		}
		if (matchesKey(data, Key.shift("g")) || matchesKey(data, Key.end)) {
			this.scrollTop = PIN_BOTTOM;
			this.tui.requestRender();
			return;
		}
		if (matchesKey(data, "v")) {
			void this.openInEditor();
			return;
		}
		if (matchesKey(data, "/")) {
			this.startSearch();
			return;
		}
		if (matchesKey(data, "n") && this.searchMatches.length > 0) {
			this.gotoMatch(1);
			return;
		}
		if (matchesKey(data, Key.shift("n")) && this.searchMatches.length > 0) {
			this.gotoMatch(-1);
			return;
		}
		if (matchesKey(data, "q") || matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) {
			this.onExit();
		}
	}

	handleMouse(event: { type: string; wheelDelta?: number }): { handled?: boolean } | undefined {
		if (event.type === "wheel") {
			this.scroll(event.wheelDelta ?? 0);
			return { handled: true };
		}
		return undefined;
	}

	render(width: number): string[] {
		const lines = this.build(width);
		const rows = this.tui.terminal.rows;
		const viewportHeight = Math.max(3, rows - 2);
		this.lastViewport = viewportHeight;

		const maxScroll = Math.max(0, lines.length - viewportHeight);
		if (this.scrollTop === PIN_BOTTOM) this.scrollTop = maxScroll;
		this.scrollTop = clamp(this.scrollTop, 0, maxScroll);

		const view = lines.slice(this.scrollTop, this.scrollTop + viewportHeight);
		while (view.length < viewportHeight) view.push("");

		const percent = maxScroll === 0 ? 100 : Math.round((this.scrollTop / maxScroll) * 100);
		const header = fit(this.theme.fg("accent", this.theme.bold("Scroll mode")) + this.theme.fg("dim", `  ${percent}%`), width);
		let footer: string;
		if (this.searchActive) {
			const prompt = `/${this.searchQuery}`;
			const matchInfo = this.searchMatches.length > 0 ? ` [${this.searchMatchIndex + 1}/${this.searchMatches.length}]` : " [0/0]";
			const beforeCursor = prompt.slice(0, 1 + this.searchCursor);
			const afterCursor = prompt.slice(1 + this.searchCursor);
			footer = fit(
				this.theme.fg("accent", beforeCursor) + CURSOR_MARKER + this.theme.fg("accent", afterCursor) +
				this.theme.fg("dim", matchInfo + "  Enter confirm · Esc cancel"),
				width,
			);
		} else if (this.searchMatches.length > 0) {
			footer = fit(
				this.theme.fg("dim", `Search: ${this.searchQuery} [${this.searchMatchIndex + 1}/${this.searchMatches.length}]  n next · N prev · / search · q exit`),
				width,
			);
		} else {
			footer = fit(
				this.theme.fg("dim", this.flash ?? "Ctrl+J/K scroll · Ctrl+D/U half · PgUp/PgDn page · g/G · v editor · / search · q exit"),
				width,
			);
		}

		const hasActiveSearch = this.searchQuery.length > 0;
		return [
			header,
			...view.map((line) => {
				if (hasActiveSearch && stripTerminalSequences(line).toLowerCase().includes(this.searchQuery.toLowerCase())) {
					return fit(highlightSearchMatches(line, this.searchQuery, this.theme), width);
				}
				return fit(line, width);
			}),
			footer,
		];
	}
}

async function enterScrollMode(ctx: ExtensionContext): Promise<void> {
	if (!ctx.hasUI || ctx.mode !== "tui") {
		ctx.ui.notify("Scroll mode requires the interactive TUI", "warning");
		return;
	}

	const blocks = buildBlocks(ctx);
	if (blocks.length === 0) {
		ctx.ui.notify("Nothing to scroll yet", "info");
		return;
	}

	const mdTheme = getMarkdownTheme();

	await ctx.ui.custom<void>(
		(tui, theme, _kb, done) => {
			if (tui.mode !== "fullscreen") {
				ctx.ui.notify("Scroll mode requires fullscreen TUI mode (set tuiMode to fullscreen)", "warning");
				done(undefined);
				return { render: () => [], invalidate: () => {} };
			}
			return new ScrollModeComponent(tui, theme, blocks, mdTheme, () => done(undefined));
		},
		{
			overlay: true,
			overlayOptions: { width: "100%", maxHeight: "100%", anchor: "top-left", margin: 0 },
		},
	);
}

export default function scrollMode(pi: ExtensionAPI) {
	const handler = async (ctx: ExtensionContext) => {
		await enterScrollMode(ctx);
	};

	for (const key of resolveKeys("extension.scrollMode", ["alt+s", "f3"])) {
		pi.registerShortcut(key, { description: "Open conversation scroll mode", handler });
	}

	pi.registerCommand("scroll", {
		description: "Browse the conversation; Ctrl+J/Ctrl+K to scroll, / to search, v to open in $EDITOR",
		handler: async (_args, ctx) => {
			await enterScrollMode(ctx);
		},
	});
}
