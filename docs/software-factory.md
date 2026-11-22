# Software factory: decisions and open items

## Purpose and scope

A software factory: a labelled GitHub issue goes in, an agent does the work, and one pull request comes out for a person to review. It is to be designed and then built.

- **Scope:** one factory, for one kind of work: turning a GitHub issue into a pull request.
- **Method:** design the architecture first, then build. Ground each choice in documented capabilities of real tools and in how others have built similar systems.

## Workflow

A prepared, labelled GitHub issue goes in, one pull request comes out, and a person merges it.

1. A person fills out a GitHub issue. The issue is the whole body of work.
2. They add the factory label. That starts a run.
3. The factory runs one agent session on the issue, set up by the factory definition.
4. The factory opens one pull request for that issue.
5. The repository's checks run on the pull request.
6. A person reviews and merges.
7. When the pull request is merged or closed, the factory adds the result to the run record.

- **Communication happens on the GitHub issue.** The factory posts its progress there: run started, pull request opened, the agent declined and why, or the run failed and why.
- **Verification is the repository's existing checks,** run on the pull request.
- **The run ends when the pull request opens.** Nothing waits for review. When GitHub reports the pull request merged or closed, the factory writes the outcome, the check result and the time to merge into that run's record.
- **One active run per issue.** If a run fails, adding the label again starts a new, isolated run on the same issue. A label added while a run is active is turned away. See [Starting a run](architecture/starting-a-run.md).

## Factory definition

The factory definition is central and versioned. It is a set of files: the instructions, skills and hooks, and the harness and model they run on.

- **Central.** One definition, owned in one place, used for every repository.
- **Version chosen per run.** Versions are semver tags in the definition's repository. A label such as `factory:v1.4.0` picks one exactly. With no version label, the run uses the newest tag.
- **One agent per run.** A run is one agent session. Steps can come back later if the data shows they help.
- **A version pins everything that affects the result:** the harness and its version, the model, the instructions, skills and hooks, and the sandbox image. Changing any of them makes a new version.
- **Each version is its own image.** Tagging a version builds a sandbox image with the harness and the definition's files, deployed as an AgentCore Runtime version behind its own endpoint. The run calls that endpoint. AgentCore versions are immutable, so a version label maps exactly to what runs.

## Run record

Every run records enough to compare one factory version against another, from the first run onwards.

- **Which version ran:** the factory definition version, the harness and its version, the models used, and the sandbox image.
- **What it ran on:** the issue and the repository commit.
- **The agent session:** how long it took and what it cost.
- **Outcome:** whether a pull request opened, and the result of its checks.
- **After the pull request:** merged or closed, and time to merge.

The aim is to be able to say "version 2 took half the time and half the cost" and trust it. This must be recorded from day one, because it can't be reconstructed later.

## Principles

- **Buy the sandboxing and the agent loop. Build only what the workflow needs around them.** That is starting a run from a label, starting the agent session, opening the pull request, posting progress and keeping the run record.
- **Fixed code does the steps that must happen every time.** Opening the pull request, posting progress and recording the run are code. Choices that depend on the work, such as how to implement it, are left to the agent.
- **Trust what the system records over what the agent reports about itself.** Check results come from GitHub. Times and costs come from the factory's own records.
- **A harness is a swappable worker.** The factory starts one in a sandbox and reads back its events, result and cost.

## Technology

GitHub, the model vendors and the sandbox host are fixed. The rest is a leaning.

| Area | Position | Status |
| --- | --- | --- |
| Code host | GitHub | Fixed |
| Model vendors | Anthropic API, with an API key, in the first version. OpenAI later, with its own harness and models | Fixed |
| Where agents run | AWS Bedrock AgentCore Runtime | Fixed |
| Harnesses | Claude Agent SDK only in the first version. Each version names its harness, so the Codex SDK can be added later | Fixed |
| The factory's own code | AWS Lambda durable functions, one execution per run | Leaning |
| Language | TypeScript | Leaning |

Recent durable function features that bear on the design, announced November 2026:

- **Pause and resume** a running execution from its last checkpoint. Paused time doesn't count towards the timeout. [Source](https://aws.amazon.com/about-aws/whats-new/2026/11/lambda-durable-pause-delete/)
- **Delete** a finished execution's history and payloads early. Same source.
- **OpenTelemetry tracing** across steps, waits and callbacks, for TypeScript, Python and Java. [Source](https://aws.amazon.com/about-aws/whats-new/2026/11/lambda-durable-otel/)

## Unresolved

One item is open.

| # | Open item | Position so far |
| --- | --- | --- |
| 1 | How to compare versions fairly. Live runs give each version different issues, so a difference may just be harder issues. | Leaning towards benchmarks: the same fixed issues run through each version, as [Warp Factories benchmarks](https://docs.warp.dev/factories/benchmarks/) do. The run record then shows how each version does on live work. |

The vendor is chosen per factory version, not per run or per step.

Speed is not a priority: the factory runs around the clock, so a full install of the repository on every run is acceptable.

## Prior art

References to borrow from. Findings come from reading their docs and code, and nothing was run.

| Reference | What to borrow | What to avoid |
| --- | --- | --- |
| [Warp Factories](https://docs.warp.dev/factories) | A factory kept as files: agents as Markdown, triggers, runners. An improvement layer that measures every run and proposes changes for review. | The order of work lives in a prompt, so nothing enforces it. |
| [AWS autonomous cloud coding agents sample](https://github.com/aws-samples/sample-autonomous-cloud-coding-agents) | A versioned file with an ordered list of steps, pinned on the run at submit time. A durable workflow per task. | Its version stamp doesn't cover the real prompt text. It is tied to one harness. It records cost per task only. In maintenance mode. |
| [GitHub Agentic Workflows: safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/) | The agent can only request actions. A separate job with write access carries them out. |  |
| [Stripe Minions](https://blog.bytebytego.com/p/how-stripes-minions-ship-1300-prs) | Fixed code steps mixed with agent steps. |  |
| [Spotify Honk](https://engineering.atspotify.com/2025/12/feedback-loops-background-coding-agents-part-3) | Existing pipelines are the authority on whether the work is good. |  |
| [Open SWE](https://github.com/langchain-ai/open-swe) | A team that built its own backend above a managed agent runtime: intake, routing, state and integrations. | Its workflow is a general coding agent. |
