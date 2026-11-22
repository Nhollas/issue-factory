# Prior art

References that the design borrows from. The findings come from reading their docs and code. Nothing was run.

| Reference | What to borrow | What to avoid |
| --- | --- | --- |
| [Warp Factories](https://docs.warp.dev/factories) | A factory kept as files: agents as Markdown, triggers, runners. An improvement layer that measures every run and proposes changes for review. | The order of work lives in a prompt, so nothing enforces it. |
| [AWS autonomous cloud coding agents sample](https://github.com/aws-samples/sample-autonomous-cloud-coding-agents) | A versioned file with an ordered list of steps, pinned on the run at submit time. A durable workflow per task. | Its version stamp doesn't cover the real prompt text. It is tied to one harness. It records cost per task only. In maintenance mode. |
| [GitHub Agentic Workflows: safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/) | The agent can only request actions. A separate job with write access carries them out. |  |
| [Stripe Minions](https://blog.bytebytego.com/p/how-stripes-minions-ship-1300-prs) | Fixed code steps mixed with agent steps. |  |
| [Spotify Honk](https://engineering.atspotify.com/2025/12/feedback-loops-background-coding-agents-part-3) | Existing pipelines are the authority on whether the work is good. |  |
| [Open SWE](https://github.com/langchain-ai/open-swe) | A team that built its own backend above a managed agent runtime: intake, routing, state and integrations. | Its workflow is a general coding agent. |
