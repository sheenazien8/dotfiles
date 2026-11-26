import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Editor } from "@earendil-works/pi-tui";

const SOFTWARE_CURSOR = /\x1b\[7m([\s\S]*?)\x1b\[0m/g;

let patched = false;

function stripSoftwareCursor(): void {
	if (patched) return;
	patched = true;
	const original = Editor.prototype.render;
	Editor.prototype.render = function (this: Editor, width: number): string[] {
		return original.call(this, width).map((line) => line.replace(SOFTWARE_CURSOR, "$1"));
	};
}

export default function cursorFocus(_pi: ExtensionAPI) {
	stripSoftwareCursor();
}
