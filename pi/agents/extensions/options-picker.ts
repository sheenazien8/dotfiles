/**
 * Options Picker Extension
 *
 * Registers a `question` tool the LLM can call whenever it wants
 * to present choices to the user. The user navigates with ↑ ↓ and
 * presses Enter to pick — no manual typing needed.
 *
 * Fallback: if the TUI is not available (JSON / print mode) the tool
 * returns an error message so the agent can ask the user differently.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  Text,
  visibleWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface OptionWithDesc {
  label: string;
  description?: string;
}

interface QuestionDetails {
  question: string;
  options: string[];
  answer: string | null;
  wasCustom?: boolean;
}

const OptionSchema = Type.Object({
  label: Type.String({ description: "Display label for the option" }),
  description: Type.Optional(
    Type.String({ description: "Optional description shown below the label" })
  ),
});

const QuestionParams = Type.Object({
  question: Type.String({ description: "The question to present to the user" }),
  options: Type.Array(OptionSchema, {
    description: "List of options for the user to choose from",
  }),
});

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "question",
    label: "Question",
    description:
      "Present a question with selectable options to the user. " +
      "Use this whenever you need the user to pick from a set of choices " +
      "instead of asking them to type an answer. " +
      "Always prefer this tool over listing options in plain text.",
    parameters: QuestionParams,
    executionMode: "sequential",

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const simpleOptions = params.options.map((o) => o.label);

      if (ctx.mode !== "tui") {
        return {
          content: [
            {
              type: "text",
              text: "UI not available in this mode. Please ask the user to type their answer.",
            },
          ],
          details: {
            question: params.question,
            options: simpleOptions,
            answer: null,
          } as QuestionDetails,
        };
      }

      if (params.options.length === 0) {
        return {
          content: [{ type: "text", text: "Error: No options provided." }],
          details: {
            question: params.question,
            options: [],
            answer: null,
          } as QuestionDetails,
        };
      }

      const allOptions: (OptionWithDesc & { isOther?: boolean })[] = [
        ...params.options,
        { label: "Type a custom answer…", isOther: true },
      ];

      const result = await ctx.ui.custom<{
        answer: string;
        wasCustom: boolean;
        index?: number;
      } | null>((tui, theme, _kb, done) => {
        let optionIndex = 0;
        let editMode = false;
        let cachedLines: string[] | undefined;

        const editorTheme: EditorTheme = {
          borderColor: (s) => theme.fg("accent", s),
          selectList: {
            selectedPrefix: (t) => theme.fg("accent", t),
            selectedText: (t) => theme.fg("accent", t),
            description: (t) => theme.fg("muted", t),
            scrollInfo: (t) => theme.fg("dim", t),
            noMatch: (t) => theme.fg("warning", t),
          },
        };
        const editor = new Editor(tui, editorTheme);

        function setEditMode(enabled: boolean) {
          editMode = enabled;
          // The Editor only draws its cursor (fake cursor + CURSOR_MARKER for
          // the hardware cursor) when its `focused` flag is set.
          editor.focused = enabled;
          if (!enabled) editor.setText("");
          refresh();
        }

        editor.onSubmit = (value) => {
          const trimmed = value.trim();
          if (trimmed) {
            done({ answer: trimmed, wasCustom: true });
          } else {
            setEditMode(false);
          }
        };

        function refresh() {
          cachedLines = undefined;
          tui.requestRender();
        }

        function handleInput(data: string) {
          if (editMode) {
            if (matchesKey(data, Key.escape)) {
              setEditMode(false);
              return;
            }
            editor.handleInput(data);
            refresh();
            return;
          }

          if (matchesKey(data, Key.up)) {
            optionIndex = Math.max(0, optionIndex - 1);
            refresh();
            return;
          }
          if (matchesKey(data, Key.down)) {
            optionIndex = Math.min(allOptions.length - 1, optionIndex + 1);
            refresh();
            return;
          }

          // Number key shortcut: press 1-9 to jump to that option
          const num = parseInt(data, 10);
          if (!isNaN(num) && num >= 1 && num <= allOptions.length) {
            const idx = num - 1;
            const selected = allOptions[idx];
            if (selected.isOther) {
              optionIndex = idx;
              setEditMode(true);
            } else {
              done({ answer: selected.label, wasCustom: false, index: num });
            }
            return;
          }

          if (matchesKey(data, Key.enter)) {
            const selected = allOptions[optionIndex];
            if (selected.isOther) {
              setEditMode(true);
            } else {
              done({
                answer: selected.label,
                wasCustom: false,
                index: optionIndex + 1,
              });
            }
            return;
          }

          if (matchesKey(data, Key.escape)) {
            done(null);
          }
        }

        function render(width: number): string[] {
          if (cachedLines) return cachedLines;

          const lines: string[] = [];
          const rw = Math.max(1, width);

          function addWrapped(text: string) {
            lines.push(...wrapTextWithAnsi(text, rw));
          }

          function addWrappedWithPrefix(prefix: string, text: string) {
            const pw = visibleWidth(prefix);
            if (pw >= rw) {
              addWrapped(prefix + text);
              return;
            }
            const wrapped = wrapTextWithAnsi(text, rw - pw);
            const cont = " ".repeat(pw);
            for (let i = 0; i < wrapped.length; i++) {
              lines.push(`${i === 0 ? prefix : cont}${wrapped[i]}`);
            }
          }

          lines.push(theme.fg("accent", "─".repeat(rw)));
          addWrappedWithPrefix(" ", theme.fg("text", params.question));
          lines.push("");

          for (let i = 0; i < allOptions.length; i++) {
            const opt = allOptions[i];
            const selected = i === optionIndex;
            const isOther = opt.isOther === true;
            const prefix = selected ? theme.fg("accent", "> ") : "  ";
            const label = `${i + 1}. ${opt.label}${isOther && editMode ? " ✎" : ""}`;
            const color = selected || (isOther && editMode) ? "accent" : "text";

            addWrappedWithPrefix(prefix, theme.fg(color, label));

            if (opt.description) {
              addWrappedWithPrefix("     ", theme.fg("muted", opt.description));
            }
          }

          if (editMode) {
            lines.push("");
            addWrappedWithPrefix(" ", theme.fg("muted", "Your answer:"));
            for (const line of editor.render(Math.max(1, rw - 2))) {
              lines.push(` ${line}`);
            }
          }

          lines.push("");
          if (editMode) {
            addWrappedWithPrefix(
              " ",
              theme.fg("dim", "Enter to submit • Esc to go back")
            );
          } else {
            addWrappedWithPrefix(
              " ",
              theme.fg(
                "dim",
                "↑↓ navigate • 1-9 shortcut • Enter to select • Esc to cancel"
              )
            );
          }
          lines.push(theme.fg("accent", "─".repeat(rw)));

          cachedLines = lines;
          return lines;
        }

        return {
          render,
          invalidate: () => {
            cachedLines = undefined;
          },
          handleInput,
        };
      });

      if (!result) {
        return {
          content: [{ type: "text", text: "User cancelled the selection." }],
          details: {
            question: params.question,
            options: simpleOptions,
            answer: null,
          } as QuestionDetails,
        };
      }

      if (result.wasCustom) {
        return {
          content: [{ type: "text", text: `User typed: ${result.answer}` }],
          details: {
            question: params.question,
            options: simpleOptions,
            answer: result.answer,
            wasCustom: true,
          } as QuestionDetails,
        };
      }

      return {
        content: [
          {
            type: "text",
            text: `User selected option ${result.index}: ${result.answer}`,
          },
        ],
        details: {
          question: params.question,
          options: simpleOptions,
          answer: result.answer,
          wasCustom: false,
        } as QuestionDetails,
      };
    },

    renderCall(args, theme, _context) {
      let text =
        theme.fg("toolTitle", theme.bold("question ")) +
        theme.fg("muted", args.question);
      const opts: OptionWithDesc[] = Array.isArray(args.options)
        ? args.options
        : [];
      if (opts.length) {
        const numbered = [...opts.map((o) => o.label), "Type a custom answer…"].map(
          (o, i) => `${i + 1}. ${o}`
        );
        text += `\n${theme.fg("dim", `  Options: ${numbered.join(", ")}`)}`;
      }
      return new Text(text, 0, 0);
    },

    renderResult(result, _options, theme, _context) {
      const details = result.details as QuestionDetails | undefined;
      if (!details) {
        const t = result.content[0];
        return new Text(t?.type === "text" ? t.text : "", 0, 0);
      }

      if (details.answer === null) {
        return new Text(theme.fg("warning", "Cancelled"), 0, 0);
      }

      if (details.wasCustom) {
        return new Text(
          theme.fg("success", "✓ ") +
            theme.fg("muted", "(custom) ") +
            theme.fg("accent", details.answer),
          0,
          0
        );
      }

      const idx = details.options.indexOf(details.answer) + 1;
      const display = idx > 0 ? `${idx}. ${details.answer}` : details.answer;
      return new Text(
        theme.fg("success", "✓ ") + theme.fg("accent", display),
        0,
        0
      );
    },
  });
}
