# 11. Risks and technical debt

## Open questions

| # | Question | Position so far |
| --- | --- | --- |
| 1 | How does a factory engineer compare factory versions fairly? Live runs give each factory version different issues. | Leaning towards benchmarks: the same fixed issues run through each factory version, as [Warp Factories benchmarks](https://docs.warp.dev/factories/benchmarks/) do. The run record then shows how each factory version does on live work. |
| 2 | Does the agent load the target repository's own `CLAUDE.md`? | The file holds useful repository knowledge. It varies outside the factory version. The run record stores the repository commit. |
| 3 | How does the event handler find the run for a merged or closed pull request? | Open. One option: the run branch name contains the run ID. |
| 4 | Does the factory keep the agent session's transcript? | The agent runner could upload the SDK's full message stream to S3. Leaning towards storing `sessionId` only in the first version. |
| 5 | What are the limit values? | Open: the agent's turn and budget limits, the heartbeat interval and timeout, and the durable execution timeout. |
| 6 | Is a lookup of one execution's status consistent straight after the execution finishes? | AWS says that listing executions is eventually consistent. AWS does not say whether a lookup of one execution is. |
| 7 | Where do the agent's instructions live, and how does the agent runner build the prompt? | Open. One option: a skill in the plugin holds the instructions, and the prompt invokes that skill with the issue. |

## Risks

| Risk | Effect | Mitigation |
| --- | --- | --- |
| The agent reads the run's GitHub token. | For up to one hour, the agent could read the repository and push to unprotected branches. | Accepted. See [ADR 0001](../adr/0001-agent-holds-scoped-github-token.md). |
| The agent reads the Anthropic API key. | The agent could use or send the key within the outbound allowlist. | None yet. Credential storage is not yet designed. |
| The agent completes the run's callback with a false result. The sandbox's AWS role needs `lambda:SendDurableExecutionCallbackSuccess` on the run's function. | The run receives a false callback message. | The run asks GitHub for the run branch's commits before it opens a pull request. |
| GitHub fails to deliver a `factory:ready` event. | Nothing happens on the issue. | The issue author removes the label and adds it again. See [Not in the first version](#not-in-the-first-version). |
| A status lookup is stale straight after a run finishes (question 6). | The event handler rejects a `factory:ready` label added just after a run ends. | The issue author adds the label again. |

## Known gaps

| Gap | Effect | Plan |
| --- | --- | --- |
| A run that times out or is stopped leaves `factory:running` on the issue. | The label is wrong and the issue has no comment. The issue author can still add `factory:ready`. | None yet. |
| A claim with no execution ARN. The event handler fails between replacing the claim and writing the ARN, and the event reaches the dead-letter queue. | The event handler has no ARN to check, so the issue stays busy. | A factory engineer fixes the claim by hand. |

## Not in the first version

- **Recovery of lost webhooks.** A scheduled job can redeliver failed deliveries later. A redelivery keeps its delivery ID, so the design stays the same.
- **A second harness.** The Codex SDK and OpenAI models come later. A second harness needs a second sandbox image.
- **More than one agent per run.** [ADR 0005](../adr/0005-one-agent-session-per-run.md) holds the decision.
