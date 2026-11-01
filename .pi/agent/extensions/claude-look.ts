/**
 * Claude Code's look for pi's input, with Gil's Claude Code status line
 * (~/.claude/statusline.sh) underneath, plus pi's spend and cache rate:
 *
 *   ──────────────────────────────────────────────────────────────
 *   ❯ type here
 *   ──────────────────────────────────────────────────────────────
 *   kimi-k2.6 · medium | $0.023 · ↑70k ↓25k · cache 99.9% | ██▄░░░░░░░ 24% of 262k tokens | 📁acme | 🔀main (2 files uncommitted, 3 ahead)
 *   💬 the last thing you asked
 *
 * Built from pi's border-status-editor example. Remove this file to go back.
 */
import {
	CustomEditor,
	type ExtensionAPI,
	type ExtensionContext,
	type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { Component, EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { statSync } from "node:fs";
import { basename, join } from "node:path";

const PROMPT = "❯ ";
const INDENT = "  ";

// The same colours as statusline.sh with COLOR="slate".
const RESET = "\x1b[0m";
const GRAY = "\x1b[38;5;245m";
const BAR_EMPTY = "\x1b[38;5;238m";
const ACCENT = "\x1b[38;5;60m";
const BAR_WIDTH = 10;

type GitState = {
	branch: string;
	uncommitted: string;
};

function rule(width: number, color: (text: string) => string): string {
	if (width <= 0) {
		return "";
	}
	return color("─".repeat(width));
}

function shortTokens(count: number): string {
	if (count < 1000) {
		return `${count}`;
	}
	if (count < 1_000_000) {
		return `${Math.round(count / 1000)}k`;
	}
	return `${(count / 1_000_000).toFixed(1)}M`;
}

function contextBar(percent: number): string {
	let bar = "";
	for (let cell = 0; cell < BAR_WIDTH; cell++) {
		const progress = percent - cell * 10;
		if (progress >= 8) {
			bar += `${ACCENT}█${RESET}`;
		} else if (progress >= 3) {
			bar += `${ACCENT}▄${RESET}`;
		} else {
			bar += `${BAR_EMPTY}░${RESET}`;
		}
	}
	return bar;
}

function fetchAge(repoRoot: string): string {
	try {
		const fetchedAt = statSync(join(repoRoot, ".git", "FETCH_HEAD")).mtimeMs;
		const seconds = Math.floor((Date.now() - fetchedAt) / 1000);
		if (seconds < 60) {
			return " <1m ago";
		}
		if (seconds < 3600) {
			return ` ${Math.floor(seconds / 60)}m ago`;
		}
		if (seconds < 86400) {
			return ` ${Math.floor(seconds / 3600)}h ago`;
		}
		return ` ${Math.floor(seconds / 86400)}d ago`;
	} catch {
		return "";
	}
}

async function readGitState(pi: ExtensionAPI, cwd: string): Promise<GitState | undefined> {
	const run = async (args: string[]) => {
		const result = await pi.exec("git", ["-C", cwd, ...args], { cwd }).catch(() => undefined);
		if (!result || result.code !== 0) {
			return undefined;
		}
		return result.stdout.trim();
	};

	const branch = await run(["branch", "--show-current"]);
	if (!branch) {
		return undefined;
	}

	const status = (await run(["--no-optional-locks", "status", "--porcelain", "-uall"])) ?? "";
	const changedLines: string[] = [];
	for (const line of status.split("\n")) {
		if (line.length > 0) {
			changedLines.push(line);
		}
	}

	let sync = "no upstream";
	const upstream = await run(["rev-parse", "--abbrev-ref", "@{upstream}"]);
	if (upstream) {
		const counts = (await run(["rev-list", "--left-right", "--count", "HEAD...@{upstream}"])) ?? "0\t0";
		const [aheadText, behindText] = counts.split(/\s+/);
		const ahead = Number(aheadText);
		const behind = Number(behindText);
		const repoRoot = (await run(["rev-parse", "--show-toplevel"])) ?? cwd;
		if (ahead === 0 && behind === 0) {
			sync = `synced${fetchAge(repoRoot)}`;
		} else if (behind === 0) {
			sync = `${ahead} ahead`;
		} else if (ahead === 0) {
			sync = `${behind} behind`;
		} else {
			sync = `${ahead} ahead, ${behind} behind`;
		}
	}

	let uncommitted = `${changedLines.length} files uncommitted`;
	if (changedLines.length === 1) {
		uncommitted = `${changedLines[0].slice(3)} uncommitted`;
	}
	return { branch, uncommitted: `(${uncommitted}, ${sync})` };
}

function lastUserMessage(ctx: ExtensionContext): string {
	let last = "";
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message" || entry.message.role !== "user") {
			continue;
		}
		const content = entry.message.content as unknown;
		let text = "";
		if (typeof content === "string") {
			text = content;
		} else if (Array.isArray(content)) {
			const parts: string[] = [];
			for (const part of content) {
				if (part && part.type === "text") {
					parts.push(part.text);
				}
			}
			text = parts.join(" ");
		}
		const flattened = text.replace(/\s+/g, " ").trim();
		if (flattened.length > 0) {
			last = flattened;
		}
	}
	return last;
}

function statusLines(pi: ExtensionAPI, ctx: ExtensionContext, git: GitState | undefined, width: number): string[] {
	let output = 0;
	let input = 0;
	let cacheRead = 0;
	let cost = 0;
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") {
			continue;
		}
		const message = entry.message as AssistantMessage;
		input += message.usage.input;
		output += message.usage.output;
		cacheRead += message.usage.cacheRead ?? 0;
		cost += message.usage.cost.total;
	}

	let model = "no model";
	if (ctx.model) {
		model = ctx.model.id.split("/").pop() ?? ctx.model.id;
	}
	let spend = `$${cost.toFixed(3)} · ↑${shortTokens(input)} ↓${shortTokens(output)}`;
	const promptTokens = input + cacheRead;
	if (promptTokens > 0) {
		const cacheHitPercent = (cacheRead / promptTokens) * 100;
		spend += ` · cache ${cacheHitPercent.toFixed(1)}%`;
	}

	// Spend comes first after the model, so a narrow terminal cuts the git part instead.
	let line = `${ACCENT}${model} · ${pi.getThinkingLevel()}${GRAY} | ${spend}`;

	const usage = ctx.getContextUsage();
	const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
	let percent = 0;
	if (usage && usage.percent !== null) {
		percent = Math.min(100, Math.round(usage.percent));
	}
	line += ` | ${contextBar(percent)} ${GRAY}${percent}% of ${shortTokens(contextWindow)} tokens`;
	line += ` | 📁${basename(ctx.cwd)}`;
	if (git) {
		line += ` | 🔀${git.branch} ${git.uncommitted}`;
	}

	line += RESET;

	const lines = [truncateToWidth(line, width)];
	const message = lastUserMessage(ctx);
	if (message.length > 0) {
		lines.push(truncateToWidth(`${GRAY}💬 ${message}${RESET}`, width, "..."));
	}
	return lines;
}

class EmptyFooter implements Component {
	render(): string[] {
		return [];
	}

	invalidate(): void {}
}

export default function (pi: ExtensionAPI) {
	let activeTui: TUI | undefined;
	let gitCwd: string | undefined;
	let git: GitState | undefined;

	const refreshGit = async () => {
		if (!gitCwd) {
			return;
		}
		git = await readGitState(pi, gitCwd);
		activeTui?.requestRender();
	};

	// A turn can commit, switch branches, or spend money, so redraw once it ends.
	pi.on("agent_settled", () => {
		void refreshGit();
		activeTui?.requestRender();
	});

	pi.on("session_shutdown", () => {
		activeTui = undefined;
	});

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setFooter(() => new EmptyFooter());
		gitCwd = ctx.cwd;
		void refreshGit();

		class ClaudeLookEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				super(tui, theme, keybindings, { paddingX: 0 });
				activeTui = tui;
			}

			render(width: number): string[] {
				const theme = ctx.ui.theme;
				const innerWidth = Math.max(1, width - visibleWidth(PROMPT));
				const lines = super.render(innerWidth);
				if (lines.length < 2) {
					return lines;
				}

				const borderColor = (text: string) => this.borderColor(text);
				const result: string[] = [rule(width, borderColor)];
				const contentLines = lines.slice(1, -1);
				for (let index = 0; index < contentLines.length; index++) {
					let prefix = INDENT;
					if (index === 0) {
						prefix = theme.fg("accent", PROMPT);
					}
					result.push(prefix + contentLines[index]);
				}
				result.push(rule(width, borderColor));
				for (const status of statusLines(pi, ctx, git, width)) {
					result.push(status);
				}
				return result;
			}
		}

		ctx.ui.setEditorComponent((tui, theme, keybindings) => new ClaudeLookEditor(tui, theme, keybindings));
	});
}
