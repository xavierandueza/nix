import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const COMPACT_THRESHOLD_TOKENS = 150_000;

export default function (pi: ExtensionAPI) {
	let previousTokens: number | null | undefined;

	const triggerCompaction = (ctx: ExtensionContext, customInstructions?: string) => {
		ctx.compact({
			customInstructions,
			onComplete: () => {
				if (ctx.hasUI) {
					ctx.ui.notify("Compaction completed", "info");
				}
			},
			onError: (error) => {
				if (ctx.hasUI) {
					ctx.ui.notify(`Compaction failed: ${error.message}`, "error");
				}
			},
		});
	};

	pi.on("turn_end", (_event, ctx) => {
		const usage = ctx.getContextUsage();
		const currentTokens = usage?.tokens ?? null;
		if (currentTokens === null) {
			return;
		}

		const crossedThreshold =
			previousTokens !== undefined &&
			previousTokens !== null &&
			previousTokens <= COMPACT_THRESHOLD_TOKENS;
		previousTokens = currentTokens;

		if (!crossedThreshold || currentTokens <= COMPACT_THRESHOLD_TOKENS) {
			return;
		}

		triggerCompaction(ctx);
	});
}
