import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const COMPACT_THRESHOLD_TOKENS = 150_000;

const CUSTOM_INSTRUCTIONS =
	"Emphasise: (1) the overall goal and objective of the session, " +
	"(2) key findings and discoveries made so far, " +
	"(3) exactly what work needs to continue and in what order.";

export default function (pi: ExtensionAPI) {
	let previousTokens: number | null | undefined;
	let autoTriggered = false;

	pi.on("session_compact", (_event, _ctx) => {
		if (!autoTriggered) return;
		autoTriggered = false;
		pi.sendUserMessage("Continue.");
	});

	pi.on("turn_end", (_event, ctx) => {
		const usage = ctx.getContextUsage();
		const currentTokens = usage?.tokens ?? null;
		if (currentTokens === null) return;

		const crossedThreshold =
			previousTokens !== undefined &&
			previousTokens !== null &&
			previousTokens <= COMPACT_THRESHOLD_TOKENS;
		previousTokens = currentTokens;

		if (!crossedThreshold || currentTokens <= COMPACT_THRESHOLD_TOKENS) return;

		triggerCompaction(ctx);
	});

	function triggerCompaction(ctx: ExtensionContext) {
		autoTriggered = true;
		ctx.compact({
			customInstructions: CUSTOM_INSTRUCTIONS,
			onComplete: () => {
				if (ctx.hasUI) {
					ctx.ui.notify("Compaction completed", "info");
				}
			},
			onError: (error) => {
				autoTriggered = false;
				if (ctx.hasUI) {
					ctx.ui.notify(`Compaction failed: ${error.message}`, "error");
				}
			},
		});
	}
}
