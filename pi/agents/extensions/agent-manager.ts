import {
	CONFIG_DIR_NAME,
	CustomEditor,
	type ExtensionAPI,
	type ExtensionContext,
	getAgentDir,
	type KeybindingsManager,
	parseFrontmatter,
} from "@earendil-works/pi-coding-agent";
import type { Api, Model } from "@earendil-works/pi-ai";
import { Container, DynamicBorder, type EditorTheme, Key, type SelectItem, SelectList, Text, type TUI, visibleWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";

export interface AgentConfig {
	name: string;
	description: string;
	provider?: string;
	model?: string;
	thinkingLevel?: "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";
	color?: string;
	autoSwitch?: string[];
	skills?: string[];
	tools?: string[];
	blockedTools?: string[];
	confirmTools?: string[];
	confirmCommands?: string[];
	readOnly?: boolean;
	systemPrompt?: string;
	source: "user" | "project" | "json";
	filePath?: string;
}

interface AgentsJsonFile {
	[name: string]: Omit<AgentConfig, "name" | "source" | "filePath">;
}

interface OriginalState {
	model: Model<Api> | undefined;
	thinkingLevel: "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max" | undefined;
	tools: string[];
}

const NAMED_COLORS: Record<string, [number, number, number]> = {
	red: [235, 87, 87],
	coral: [233, 137, 115],
	green: [141, 192, 122],
	emerald: [46, 204, 113],
	blue: [97, 175, 239],
	cyan: [86, 182, 194],
	yellow: [229, 192, 123],
	orange: [209, 154, 102],
	purple: [198, 120, 221],
	magenta: [213, 90, 245],
	pink: [206, 130, 172],
	gray: [128, 128, 128],
	white: [240, 240, 240],
};

export function parseColor(colorStr?: string): ((text: string) => string) | undefined {
	if (!colorStr) return undefined;
	const trimmed = colorStr.trim().toLowerCase();

	if (NAMED_COLORS[trimmed]) {
		const [r, g, b] = NAMED_COLORS[trimmed]!;
		return (text: string) => `\x1b[38;2;${r};${g};${b}m${text}\x1b[0m`;
	}

	if (trimmed.startsWith("#")) {
		const hex = trimmed.slice(1);
		if (hex.length === 6) {
			const r = parseInt(hex.slice(0, 2), 16);
			const g = parseInt(hex.slice(2, 4), 16);
			const b = parseInt(hex.slice(4, 6), 16);
			if (!isNaN(r) && !isNaN(g) && !isNaN(b)) {
				return (text: string) => `\x1b[38;2;${r};${g};${b}m${text}\x1b[0m`;
			}
		} else if (hex.length === 3) {
			const r = parseInt(hex[0]! + hex[0]!, 16);
			const g = parseInt(hex[1]! + hex[1]!, 16);
			const b = parseInt(hex[2]! + hex[2]!, 16);
			if (!isNaN(r) && !isNaN(g) && !isNaN(b)) {
				return (text: string) => `\x1b[38;2;${r};${g};${b}m${text}\x1b[0m`;
			}
		}
	}

	return undefined;
}

function parseList(value: unknown): string[] | undefined {
	if (Array.isArray(value)) {
		return value.filter((item): item is string => typeof item === "string").map((s) => s.trim()).filter(Boolean);
	}
	if (typeof value === "string") {
		return value.split(",").map((s) => s.trim()).filter(Boolean);
	}
	return undefined;
}

function loadAgentsFromDirectory(dir: string, source: "user" | "project"): AgentConfig[] {
	const agents: AgentConfig[] = [];
	if (!fs.existsSync(dir)) return agents;

	let entries: fs.Dirent[];
	try {
		entries = fs.readdirSync(dir, { withFileTypes: true });
	} catch {
		return agents;
	}

	for (const entry of entries) {
		if (!entry.name.endsWith(".md")) continue;
		if (!entry.isFile() && !entry.isSymbolicLink()) continue;

		const filePath = path.join(dir, entry.name);
		let content: string;
		try {
			content = fs.readFileSync(filePath, "utf-8");
		} catch {
			continue;
		}

		try {
			const { frontmatter, body } = parseFrontmatter<Record<string, unknown>>(content);
			const name = (typeof frontmatter.name === "string" ? frontmatter.name : entry.name.replace(/\.md$/, "")).trim();
			const description = typeof frontmatter.description === "string" ? frontmatter.description.trim() : "";
			if (!name) continue;

			let provider: string | undefined;
			let model: string | undefined;

			if (typeof frontmatter.provider === "string") {
				provider = frontmatter.provider.trim();
			}
			if (typeof frontmatter.model === "string") {
				const modelStr = frontmatter.model.trim();
				if (!provider && modelStr.includes("/")) {
					const parts = modelStr.split("/");
					provider = parts[0];
					model = parts.slice(1).join("/");
				} else {
					model = modelStr;
				}
			}

			const thinkingLevel = typeof frontmatter.thinkingLevel === "string"
				? (frontmatter.thinkingLevel.trim().toLowerCase() as AgentConfig["thinkingLevel"])
				: undefined;

			const color = typeof frontmatter.color === "string" ? frontmatter.color.trim() : undefined;
			const autoSwitch = parseList(frontmatter.autoSwitch ?? frontmatter.keywords ?? frontmatter.patterns);
			const skills = parseList(frontmatter.skills ?? frontmatter.skill);
			const tools = parseList(frontmatter.tools ?? frontmatter.allowedTools);
			const blockedTools = parseList(frontmatter.blockedTools);
			const confirmTools = parseList(frontmatter.confirmTools);
			const confirmCommands = parseList(frontmatter.confirmCommands);
			const readOnly = frontmatter.readOnly === true;

			agents.push({
				name,
				description,
				provider,
				model,
				thinkingLevel,
				color,
				autoSwitch,
				skills,
				tools,
				blockedTools,
				confirmTools,
				confirmCommands,
				readOnly,
				systemPrompt: body.trim() ? body.trim() : undefined,
				source,
				filePath,
			});
		} catch {
			continue;
		}
	}

	return agents;
}

function loadAgentsFromJson(filePath: string, source: "user" | "project"): AgentConfig[] {
	const agents: AgentConfig[] = [];
	if (!fs.existsSync(filePath)) return agents;

	try {
		const raw = fs.readFileSync(filePath, "utf-8");
		const data = JSON.parse(raw) as AgentsJsonFile;
		for (const [name, config] of Object.entries(data)) {
			if (!name || typeof config !== "object" || config === null) continue;

			let provider = config.provider;
			let model = config.model;
			if (!provider && model && model.includes("/")) {
				const parts = model.split("/");
				provider = parts[0];
				model = parts.slice(1).join("/");
			}

			agents.push({
				name: name.trim(),
				description: config.description || "",
				provider,
				model,
				thinkingLevel: config.thinkingLevel,
				color: config.color,
				autoSwitch: parseList(config.autoSwitch),
				skills: parseList(config.skills ?? (config as Record<string, unknown>).skill),
				tools: parseList(config.tools),
				blockedTools: parseList(config.blockedTools),
				confirmTools: parseList(config.confirmTools),
				confirmCommands: parseList(config.confirmCommands),
				readOnly: config.readOnly === true,
				systemPrompt: (config.systemPrompt || (config as Record<string, unknown>).instructions as string || "").trim() || undefined,
				source,
				filePath,
			});
		}
	} catch {
		// Ignore parse errors
	}

	return agents;
}

export function loadAllAgents(cwd: string): Map<string, AgentConfig> {
	const agentMap = new Map<string, AgentConfig>();

	// 1. User global Markdown files: ~/.pi/agent/agents/*.md
	const userAgentsDir = path.join(getAgentDir(), "agents");
	for (const a of loadAgentsFromDirectory(userAgentsDir, "user")) {
		agentMap.set(a.name, a);
	}

	// 2. User global JSON config: ~/.pi/agent/agents.json
	const userJsonPath = path.join(getAgentDir(), "agents.json");
	for (const a of loadAgentsFromJson(userJsonPath, "user")) {
		agentMap.set(a.name, a);
	}

	// 3. Project-local Markdown files: <cwd>/.pi/agents/*.md
	const projectAgentsDir = path.join(cwd, CONFIG_DIR_NAME, "agents");
	for (const a of loadAgentsFromDirectory(projectAgentsDir, "project")) {
		agentMap.set(a.name, a);
	}

	// 4. Project-local JSON config: <cwd>/.pi/agents.json
	const projectJsonPath = path.join(cwd, CONFIG_DIR_NAME, "agents.json");
	for (const a of loadAgentsFromJson(projectJsonPath, "project")) {
		agentMap.set(a.name, a);
	}

	return agentMap;
}

function matchPattern(input: string, pattern: string): boolean {
	const trimmedPattern = pattern.trim();
	if (!trimmedPattern) return false;

	if (trimmedPattern.startsWith("/") && trimmedPattern.lastIndexOf("/") > 0) {
		const lastSlash = trimmedPattern.lastIndexOf("/");
		const regexStr = trimmedPattern.slice(1, lastSlash);
		const flags = trimmedPattern.slice(lastSlash + 1);
		try {
			const regex = new RegExp(regexStr, flags);
			return regex.test(input);
		} catch {
			// Fallback to substring
		}
	}

	const lowerInput = input.toLowerCase();
	const lowerPattern = trimmedPattern.toLowerCase();

	const wordBoundaryRegex = new RegExp(`\\b${escapeRegExp(lowerPattern)}\\b`, "i");
	return wordBoundaryRegex.test(lowerInput);
}

function escapeRegExp(string: string) {
	return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function toolAllowed(toolName: string, patterns: string[]): boolean {
	return patterns.some((p) => toolName === p || toolName.startsWith(`${p}_`));
}

export default function agentManagerExtension(pi: ExtensionAPI) {
	let agents = new Map<string, AgentConfig>();
	let activeAgent: AgentConfig | undefined;
	let originalState: OriginalState | undefined;
	let autoSwitchEnabled = true;

	function refreshAgents(cwd: string) {
		agents = loadAllAgents(cwd);
	}

	function updateStatus(ctx: ExtensionContext) {
		if (activeAgent) {
			const colorFn = parseColor(activeAgent.color);
			const label = colorFn ? colorFn(`● [Agent: ${activeAgent.name}]`) : `● [Agent: ${activeAgent.name}]`;
			ctx.ui.setStatus("agent-manager", label);
		} else {
			ctx.ui.setStatus("agent-manager", undefined);
		}
	}

	async function applyAgent(agent: AgentConfig, ctx: ExtensionContext): Promise<boolean> {
		if (!originalState) {
			originalState = {
				model: ctx.model,
				thinkingLevel: pi.getThinkingLevel(),
				tools: pi.getActiveTools(),
			};
		}

		if (agent.provider && agent.model) {
			let model = ctx.modelRegistry.find(agent.provider, agent.model);
			if (!model) {
				const available = ctx.modelRegistry.getAvailable();
				model = available.find((m) => m.provider === agent.provider && m.id === agent.model)
					?? available.find((m) => m.id === `${agent.provider}/${agent.model}`)
					?? available.find((m) => m.id === agent.model);
			}
			if (model) {
				const ok = await pi.setModel(model);
				if (!ok) {
					ctx.ui.notify(`Agent "${agent.name}": Model auth/key failed for ${model.provider}/${model.id}`, "warning");
				}
			} else {
				ctx.ui.notify(`Agent "${agent.name}": Model ${agent.provider}/${agent.model} not found`, "warning");
			}
		} else if (agent.model && !agent.provider) {
			const available = ctx.modelRegistry.getAvailable();
			const matched = available.find((m) => m.id === agent.model || `${m.provider}/${m.id}` === agent.model);
			if (matched) {
				await pi.setModel(matched);
			}
		}

		if (agent.thinkingLevel) {
			pi.setThinkingLevel(agent.thinkingLevel);
		}

		const allTools = pi.getAllTools().map((t) => t.name);
		let targetTools: string[] = allTools;

		if (agent.readOnly) {
			const readOnlyDefaults = ["read", "grep", "find", "ls"];
			targetTools = allTools.filter((t) => readOnlyDefaults.includes(t));
		} else if (agent.tools && agent.tools.length > 0) {
			targetTools = allTools.filter((t) => toolAllowed(t, agent.tools!));
		}

		if (agent.blockedTools && agent.blockedTools.length > 0) {
			targetTools = targetTools.filter((t) => !agent.blockedTools!.includes(t));
		}

		if (targetTools.length > 0) {
			pi.setActiveTools(targetTools);
		}

		activeAgent = agent;
		updateStatus(ctx);
		return true;
	}

	async function resetToDefault(ctx: ExtensionContext) {
		activeAgent = undefined;
		if (originalState) {
			if (originalState.model) {
				await pi.setModel(originalState.model);
			}
			if (originalState.thinkingLevel) {
				pi.setThinkingLevel(originalState.thinkingLevel);
			}
			pi.setActiveTools(originalState.tools);
		} else {
			pi.setActiveTools(["read", "bash", "edit", "write"]);
		}
		updateStatus(ctx);
		ctx.ui.notify("Agent reset: Default settings restored", "info");
	}

	// Helper to get sorted agent names for cycling
	function getAgentOrder(): string[] {
		return Array.from(agents.keys()).sort();
	}

	async function cycleAgent(ctx: ExtensionContext): Promise<void> {
		refreshAgents(ctx.cwd);
		const agentNames = getAgentOrder();
		if (agentNames.length === 0) {
			ctx.ui.notify(
				`No agents defined. Add agents to ${path.join(getAgentDir(), "agents")}/*.md or agents.json`,
				"warning",
			);
			return;
		}

		const cycleList = ["(default)", ...agentNames];
		const currentName = activeAgent?.name ?? "(default)";
		const currentIndex = cycleList.indexOf(currentName);
		const nextIndex = currentIndex === -1 ? 0 : (currentIndex + 1) % cycleList.length;
		const nextName = cycleList[nextIndex];

		if (nextName === "(default)") {
			await resetToDefault(ctx);
			return;
		}

		const chosen = agents.get(nextName);
		if (!chosen) return;

		await applyAgent(chosen, ctx);
		ctx.ui.notify(`Agent "${chosen.name}" activated`, "info");
	}

	function setupCustomEditor(ctx: ExtensionContext) {
		class AgentColoredEditor extends CustomEditor {
			private keybindingsMgr: KeybindingsManager;

			constructor(tui: TUI, theme: EditorTheme, kb: KeybindingsManager) {
				super(tui, theme, kb, { paddingX: 0 });
				this.keybindingsMgr = kb;
			}

			override handleInput(data: string): void {
				// When input is empty and user presses Tab (and not in autocomplete list), cycle agents
				if (
					this.keybindingsMgr.matches(data, "tui.input.tab") &&
					this.getText().trim().length === 0
				) {
					void cycleAgent(ctx);
					return;
				}

				super.handleInput(data);
			}

			protected override renderTopBorder(width: number, hiddenLineCount: number): string {
				if (!activeAgent || !activeAgent.color) {
					return super.renderTopBorder(width, hiddenLineCount);
				}
				const colorFn = parseColor(activeAgent.color);
				if (!colorFn) {
					return super.renderTopBorder(width, hiddenLineCount);
				}

				const badge = `[ 🤖 Agent: ${activeAgent.name} ]`;
				const badgeWidth = visibleWidth(badge);
				if (width <= badgeWidth + 4) {
					return colorFn("─".repeat(Math.max(1, width)));
				}

				const leftLine = "── ";
				const rightLen = Math.max(0, width - leftLine.length - badgeWidth);
				return colorFn(`${leftLine}${badge}${"─".repeat(rightLen)}`);
			}

			protected override renderBottomBorder(width: number, hiddenLineCount: number): string {
				if (!activeAgent || !activeAgent.color) {
					return super.renderBottomBorder(width, hiddenLineCount);
				}
				const colorFn = parseColor(activeAgent.color);
				if (!colorFn) {
					return super.renderBottomBorder(width, hiddenLineCount);
				}
				const scrollIndicator = hiddenLineCount > 0 ? ` ↓ ${hiddenLineCount} more ` : "";
				const scrollWidth = visibleWidth(scrollIndicator);
				const remaining = Math.max(0, width - scrollWidth);
				return colorFn("─".repeat(remaining)) + (scrollIndicator ? colorFn(scrollIndicator) : "");
			}
		}

		ctx.ui.setEditorComponent((tui, theme, kb) => new AgentColoredEditor(tui, theme, kb));
	}

	async function showAgentSelector(ctx: ExtensionContext): Promise<void> {
		refreshAgents(ctx.cwd);
		const agentList = Array.from(agents.values());

		if (agentList.length === 0) {
			ctx.ui.notify(
				`No agents found. Add agents to ${path.join(getAgentDir(), "agents")}/*.md or agents.json`,
				"warning",
			);
			return;
		}

		const items: SelectItem[] = agentList.map((ag) => {
			const isActive = activeAgent?.name === ag.name;
			const colorFn = parseColor(ag.color);
			const label = isActive ? `${ag.name} (active)` : ag.name;
			const styledLabel = colorFn ? colorFn(label) : label;

			const parts: string[] = [];
			if (ag.provider && ag.model) parts.push(`${ag.provider}/${ag.model}`);
			else if (ag.model) parts.push(ag.model);
			if (ag.thinkingLevel) parts.push(`thinking:${ag.thinkingLevel}`);
			if (ag.skills) parts.push(`skills:[${ag.skills.join(",")}]`);
			if (ag.tools) parts.push(`tools:[${ag.tools.join(",")}]`);
			if (ag.readOnly) parts.push("read-only");
			if (ag.description) parts.push(ag.description);

			return {
				value: ag.name,
				label: styledLabel,
				description: parts.join(" | "),
			};
		});

		items.push({
			value: "(default)",
			label: "(default / reset)",
			description: "Reset to original model, tools and default agent state",
		});

		const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
			const container = new Container();
			container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
			container.addChild(new Text(theme.fg("accent", theme.bold("Select Agent"))));

			const selectList = new SelectList(items, Math.min(items.length, 12), {
				selectedPrefix: (text) => theme.fg("accent", text),
				selectedText: (text) => theme.fg("accent", text),
				description: (text) => theme.fg("muted", text),
				scrollInfo: (text) => theme.fg("dim", text),
				noMatch: (text) => theme.fg("warning", text),
			});

			selectList.onSelect = (item) => done(item.value);
			selectList.onCancel = () => done(null);

			container.addChild(selectList);
			container.addChild(new Text(theme.fg("dim", "↑↓ navigate • enter select • esc cancel")));
			container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

			return {
				render(width: number) {
					return container.render(width);
				},
				invalidate() {
					container.invalidate();
				},
				handleInput(data: string) {
					selectList.handleInput(data);
					tui.requestRender();
				},
			};
		});

		if (!result) return;

		if (result === "(default)") {
			await resetToDefault(ctx);
			return;
		}

		const chosen = agents.get(result);
		if (chosen) {
			await applyAgent(chosen, ctx);
			ctx.ui.notify(`Agent "${chosen.name}" activated`, "info");
		}
	}

	// 1. Lifecycle: session_start
	pi.on("session_start", (_event, ctx) => {
		refreshAgents(ctx.cwd);
		setupCustomEditor(ctx);
		updateStatus(ctx);
	});

	// 2. Lifecycle: input - Auto-switching & prefix parsing
	pi.on("input", async (event, ctx) => {
		if (event.source === "extension") return { action: "continue" };
		const text = event.text.trim();

		// Check for @<agentName> prefix: e.g. "@reviewer please check this"
		const prefixMatch = text.match(/^@([a-zA-Z0-9_-]+)(?:\s+(.*))?$/s);
		if (prefixMatch) {
			const requestedName = prefixMatch[1]!;
			const remainingText = (prefixMatch[2] || "").trim();

			refreshAgents(ctx.cwd);
			const targetAgent = agents.get(requestedName);
			if (targetAgent) {
				await applyAgent(targetAgent, ctx);
				ctx.ui.notify(`Switched to @${targetAgent.name}`, "info");
				if (remainingText.length > 0) {
					return { action: "transform", text: remainingText };
				}
				return { action: "handled" };
			}
		}

		// Check auto-switch rules if enabled
		if (autoSwitchEnabled) {
			refreshAgents(ctx.cwd);
			for (const agent of agents.values()) {
				if (agent.autoSwitch && agent.autoSwitch.length > 0) {
					const matched = agent.autoSwitch.some((pattern) => matchPattern(text, pattern));
					if (matched) {
						if (!activeAgent || activeAgent.name !== agent.name) {
							await applyAgent(agent, ctx);
							ctx.ui.notify(`Auto-switched to agent: ${agent.name}`, "info");
						}
						break;
					}
				}
			}
		}

		return { action: "continue" };
	});

	// 3. Lifecycle: before_agent_start - Inject agent system prompt & designated skills
	pi.on("before_agent_start", async (event, _ctx) => {
		if (!activeAgent) return;

		let extraPrompt = "";

		// Format agent instructions
		if (activeAgent.systemPrompt) {
			extraPrompt += `\n\n[Active Agent: ${activeAgent.name}]\n${activeAgent.systemPrompt}\n`;
		}

		// Inject designated skills if configured
		if (activeAgent.skills && activeAgent.skills.length > 0 && event.systemPromptOptions?.skills) {
			const activeSkillNames = activeAgent.skills.map((s) => s.toLowerCase());
			const matchedSkills = event.systemPromptOptions.skills.filter((sk) =>
				activeSkillNames.includes(sk.name.toLowerCase())
			);

			if (matchedSkills.length > 0) {
				extraPrompt += `\n\n[Designated Skills for ${activeAgent.name}]\n`;
				extraPrompt += `The following specialized skills are assigned to this agent:\n`;
				for (const sk of matchedSkills) {
					extraPrompt += `- Skill '${sk.name}': ${sk.description} (location: ${sk.filePath})\n`;
				}
				extraPrompt += `\nAlways read and apply the instructions from the assigned skill files when executing tasks.\n`;
			}
		}

		if (extraPrompt) {
			return {
				systemPrompt: event.systemPrompt + extraPrompt,
			};
		}
	});

	// 4. Lifecycle: tool_call - Permissions & Confirmation Gating
	pi.on("tool_call", async (event, ctx) => {
		if (!activeAgent) return;

		const toolName = event.toolName;

		// 1. Whitelist check
		if (activeAgent.readOnly) {
			const allowed = ["read", "grep", "find", "ls"];
			if (!allowed.includes(toolName)) {
				return {
					block: true,
					reason: `Agent '${activeAgent.name}' is in read-only mode. Tool '${toolName}' is forbidden.`,
				};
			}
		} else if (activeAgent.tools && activeAgent.tools.length > 0) {
			if (!toolAllowed(toolName, activeAgent.tools)) {
				return {
					block: true,
					reason: `Tool '${toolName}' is not in the allowed list for agent '${activeAgent.name}'. Allowed: [${activeAgent.tools.join(", ")}]`,
				};
			}
		}

		// 2. Blacklist check
		if (activeAgent.blockedTools && activeAgent.blockedTools.includes(toolName)) {
			return {
				block: true,
				reason: `Tool '${toolName}' is explicitly blocked for agent '${activeAgent.name}'.`,
			};
		}

		// 3. Confirmation on sensitive tools
		if (activeAgent.confirmTools && activeAgent.confirmTools.includes(toolName)) {
			if (ctx.hasUI) {
				let details = "";
				if (toolName === "write" || toolName === "edit") {
					const filePath = (event.input as { path?: string })?.path;
					if (filePath) details = ` on '${filePath}'`;
				}
				const ok = await ctx.ui.confirm(
					`Permission: ${activeAgent.name}`,
					`Agent '${activeAgent.name}' wants to execute '${toolName}'${details}. Allow?`,
				);
				if (!ok) {
					return { block: true, reason: `User rejected execution of tool '${toolName}'.` };
				}
			}
		}

		// 4. Bash dangerous command confirmation
		if (toolName === "bash" && activeAgent.confirmCommands && activeAgent.confirmCommands.length > 0) {
			const cmd = (event.input as { command?: string })?.command || "";
			const matchesConfirm = activeAgent.confirmCommands.some((pat) => matchPattern(cmd, pat));
			if (matchesConfirm && ctx.hasUI) {
				const ok = await ctx.ui.confirm(
					`Confirm Bash: ${activeAgent.name}`,
					`Agent '${activeAgent.name}' wants to run:\n\n${cmd}\n\nAllow execution?`,
				);
				if (!ok) {
					return { block: true, reason: `User rejected command: ${cmd}` };
				}
			}
		}
	});

	// 5. Register shortcut (e.g. Ctrl+Shift+A) for cycling agents anytime
	pi.registerShortcut(Key.ctrlShift("a"), {
		description: "Cycle through available agents",
		handler: async (ctx) => {
			await cycleAgent(ctx);
		},
	});

	// 6. Register /agent slash command
	pi.registerCommand("agent", {
		description: "Manage and switch agents (/agent, /agent <name>, /agent cycle, /agent list, /agent reset, /agent autoswitch)",
		getArgumentCompletions: (prefix: string) => {
			const list = Array.from(agents.keys());
			list.push("list", "current", "reset", "autoswitch", "reload");
			const filtered = list.filter((item) => item.toLowerCase().startsWith(prefix.toLowerCase()));
			return filtered.map((item) => ({ value: item, label: item }));
		},
		handler: async (args, ctx) => {
			const sub = (args || "").trim();

			if (!sub || sub === "select") {
				await showAgentSelector(ctx);
				return;
			}

			if (sub === "list") {
				refreshAgents(ctx.cwd);
				const list = Array.from(agents.values());
				if (list.length === 0) {
					ctx.ui.notify("No agents configured.", "info");
					return;
				}
				const lines = list.map((a) => {
					const active = activeAgent?.name === a.name ? " (active)" : "";
					const modelStr = a.provider && a.model ? `${a.provider}/${a.model}` : a.model || "default";
					const toolsStr = a.readOnly ? "read-only" : a.tools ? a.tools.join(",") : "all";
					return `• ${a.name}${active} [${modelStr}] (tools: ${toolsStr}) - ${a.description}`;
				});
				ctx.ui.notify(`Available Agents:\n${lines.join("\n")}`, "info");
				return;
			}

			if (sub === "current") {
				if (!activeAgent) {
					ctx.ui.notify("No specific agent active (using default settings).", "info");
				} else {
					const modelStr = activeAgent.provider && activeAgent.model ? `${activeAgent.provider}/${activeAgent.model}` : activeAgent.model || "default";
					ctx.ui.notify(
						`Active Agent: ${activeAgent.name}\n` +
						`Description: ${activeAgent.description}\n` +
						`Model: ${modelStr}\n` +
						`Thinking: ${activeAgent.thinkingLevel || "default"}\n` +
						`Color: ${activeAgent.color || "default"}\n` +
						`Skills: ${activeAgent.skills ? activeAgent.skills.join(", ") : "none"}\n` +
						`Tools: ${activeAgent.readOnly ? "read-only" : activeAgent.tools ? activeAgent.tools.join(",") : "all"}\n` +
						`Blocked: ${activeAgent.blockedTools ? activeAgent.blockedTools.join(",") : "none"}\n` +
						`AutoSwitch: ${activeAgent.autoSwitch ? activeAgent.autoSwitch.join(", ") : "none"}`,
						"info"
					);
				}
				return;
			}

			if (sub === "cycle" || sub === "next") {
				await cycleAgent(ctx);
				return;
			}

			if (sub === "reset" || sub === "default" || sub === "none") {
				await resetToDefault(ctx);
				return;
			}

			if (sub === "reload") {
				refreshAgents(ctx.cwd);
				ctx.ui.notify(`Agents reloaded (${agents.size} found).`, "info");
				return;
			}

			if (sub.startsWith("autoswitch")) {
				const flag = sub.replace(/^autoswitch\s*/, "").trim().toLowerCase();
				if (flag === "off" || flag === "disable" || flag === "false") {
					autoSwitchEnabled = false;
					ctx.ui.notify("Agent auto-switching disabled.", "info");
				} else if (flag === "on" || flag === "enable" || flag === "true") {
					autoSwitchEnabled = true;
					ctx.ui.notify("Agent auto-switching enabled.", "info");
				} else {
					autoSwitchEnabled = !autoSwitchEnabled;
					ctx.ui.notify(`Agent auto-switching is now ${autoSwitchEnabled ? "enabled" : "disabled"}.`, "info");
				}
				return;
			}

			// Direct name switch: /agent <name>
			refreshAgents(ctx.cwd);
			const target = agents.get(sub);
			if (target) {
				await applyAgent(target, ctx);
				ctx.ui.notify(`Agent "${target.name}" activated.`, "info");
			} else {
				ctx.ui.notify(`Agent "${sub}" not found. Type /agent list to see available agents.`, "error");
			}
		},
	});
}
