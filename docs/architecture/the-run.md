# The run

[Overview](./README.md) → [Starting a run](./starting-a-run.md) → **The run**

What one run does, from its durable execution starting to its pull request opening, and the contract between the run and the agent in the sandbox.

## The constraint

A run waits hours for its agent, but a Lambda invocation lasts at most 900 seconds ([Lambda quotas](https://docs.aws.amazon.com/general/latest/gr/lambda-service.html)). So the run cannot hold a connection to the agent while it works. It starts the agent, suspends, and is woken when the agent's session ends.

- AgentCore Runtime supports background work: the invoke returns at once and the session keeps working while it reports itself busy ([long-running agents](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-long-run.html)).
- AgentCore documents no API that tells a caller a session has finished, so there is nothing to poll.
- A durable function can create a callback and suspend until an outside system completes it. A heartbeat timeout fails the callback if the outside system goes quiet ([callbacks](https://docs.aws.amazon.com/durable-execution/sdk-reference/operations/callback/)).

## Parts in the sandbox

| Part | What it is |
| --- | --- |
| Agent runner | Our program in the sandbox image. Starts the Claude Agent SDK session, sends heartbeats while it works, and completes the run's callback with the result when it ends. Fixed code, not the agent. |
| Agent | The Claude Agent SDK session, set up by the factory definition. Works on the checkout and pushes the run branch. |

## Sequence

1. Resolve the version: the version label, or the newest tag.
2. Set `factory:running` and comment that the run has started.
3. Mint the run's GitHub token ([ADR 0001](../adr/0001-agent-holds-scoped-github-token.md)).
4. Create a callback and invoke the version's AgentCore endpoint with the [start request](#1-start-request-run-to-agent-runner). The invoke returns at once.
5. Suspend until the agent runner completes the callback, or the callback fails.
6. Revoke the token.
7. Check GitHub for the run branch and whether it has commits beyond the base commit. The run trusts GitHub, not the agent's report.
8. Act on the [outcome](#outcomes) and write it to the run record.

## The contract

```text
Run ──(1) start request──▶ Agent runner ──starts──▶ Claude Agent SDK session
Run ◀──(3) callback─────── Agent runner ◀──result message, with (2) the agent's structured output
```

Every factory version's image stays deployed, so the run's current code must understand every agent runner it might start. Both messages carry `contractVersion`, so a mismatch fails the run with a clear reason.

### 1. Start request: run to agent runner

| Field | Purpose |
| --- | --- |
| `contractVersion` | Which contract this message follows. |
| `runId`, `callbackId` | Which run this is and how to report back to it. |
| `repository`, `baseCommit`, `branch` | What to clone, where to start, and which branch to push. |
| `githubToken` | For cloning and pushing. |
| `issue`: number, title, body | The run passes the issue so the agent does not fetch it. The token has `contents: write` only, and the run record keeps exactly what the agent was given. |

### 2. Agent's structured output

The agent must end with this object. The Claude Agent SDK validates it against a JSON schema and retries on a mismatch ([structured outputs](https://code.claude.com/docs/en/agent-sdk/structured-outputs)).

| Field | Values |
| --- | --- |
| `outcome` | `completed`: made the change and pushed it. `declined`: chose not to make a change, for example because the issue is unclear, out of scope or cannot be done safely. |
| `summary` | Markdown. The pull request description, or the comment saying why it declined. |

The pull request title comes from the issue title, set by the run.

### 3. Callback: agent runner to run

| Field | Source |
| --- | --- |
| `contractVersion` | The agent runner. |
| `harness` name and version, `model` | The agent runner, from what is in the image. |
| `subtype` | The SDK's result message: `success` or one of its `error_*` endings. |
| `durationMs`, `numTurns`, `costUsdEstimate`, `usage` per model | The SDK's result message. |
| `agent` | The structured output. Present only when `subtype` is `success`. |
| `sessionId` | The SDK, for investigating a run. |

The SDK's `error_*` endings mean the session did not reach its end: `error_max_turns`, `error_max_budget_usd`, `error_during_execution` and `error_max_structured_output_retries` ([agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop)).

The agent runner does not report whether it pushed. The run checks GitHub.

## Outcomes

| Result | The run |
| --- | --- |
| `success`, `completed`, branch has new commits | Opens the pull request, sets `factory:done`, comments with the link. |
| `success`, `completed`, no new commits | Sets `factory:failed`, comments that the agent reported completion but pushed nothing. |
| `success`, `declined` | Sets `factory:declined`, comments with the agent's summary. |
| An `error_*` ending | Sets `factory:failed`, comments with the ending. |
| Callback failed or heartbeats stopped | Sets `factory:failed`, comments that the sandbox stopped responding. |

## Decided

- **Models come from the Anthropic API with an API key.** The key is in the sandbox, so the agent can read it, as with the GitHub token. Where it is stored is part of credentials, not yet designed.
- **Cost is the SDK's estimate.** The run record keeps `costUsdEstimate` and the token counts per model. The SDK calls its figure a client-side estimate from a price table bundled with the SDK, so it can shift between SDK versions and so between factory versions ([cost tracking](https://code.claude.com/docs/en/agent-sdk/cost-tracking)).
- **A run fits in one AgentCore session,** which lasts at most 8 hours. The agent's limits sit under that, and the durable execution's timeout just above it.

## Open

| Open item | Notes |
| --- | --- |
| Keeping the transcript | The agent runner could upload the SDK's full message stream to S3. Leaning towards leaving it out of the first version and keeping `sessionId` only. |
| Limit values | The agent's turn and budget limits, the heartbeat interval and timeout, and the durable execution timeout. Set in the factory definition where they affect the agent. |
| Who may complete the run's callback | The sandbox's AWS role needs `lambda:SendDurableExecutionCallbackSuccess` on the run's function, so the agent could in principle complete it with a false result. Step 7 still checks GitHub, so a false result cannot open a pull request without commits. |
