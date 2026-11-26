import { readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import type { KeyId } from "@earendil-works/pi-tui";

function readConfig(): Record<string, string | string[] | undefined> {
	try {
		const raw = readFileSync(join(getAgentDir(), "keybindings.json"), "utf-8");
		const parsed = JSON.parse(raw) as unknown;
		return parsed && typeof parsed === "object" ? (parsed as Record<string, string | string[] | undefined>) : {};
	} catch {
		return {};
	}
}

export function resolveKeys(id: string, fallback: string[]): KeyId[] {
	const value = readConfig()[id];
	if (typeof value === "string" && value.length > 0) return [value as KeyId];
	if (Array.isArray(value)) {
		const keys = value.filter((entry): entry is string => typeof entry === "string" && entry.length > 0);
		if (keys.length > 0) return keys as KeyId[];
	}
	return fallback as KeyId[];
}
