# 8. Crosscutting concepts

## Security

### Decided

- **Webhook authentication.** The webhook receiver's function URL is public. The webhook receiver checks GitHub's webhook signature on every request.
- **GitHub token.** The run mints one GitHub App installation token per run. The token covers one repository with `contents: write` only. The run revokes the token when the agent session ends. [ADR 0001](../adr/0001-agent-holds-scoped-github-token.md) holds the full decision and the accepted risk.
- **Pull requests.** The run opens the pull request. The agent's token has no `pull_requests` permission.
- **Branch protection.** A ruleset protects `main`. Changes need a reviewed pull request, and the GitHub App cannot bypass the ruleset.
- **Outbound traffic.** An allowlist limits outbound traffic from the sandbox.
- **Anthropic API key.** The key is in the sandbox. The agent can read it.
- **Issue content.** The run passes the issue's number, title and body in the start request. The agent's token gives no access to issues.

### Not yet designed

- Where the factory stores the Anthropic API key and the GitHub App's private key.
- IAM roles and policies for each container.
- How the sandbox gets read access to the factory definition repository.
- Who can add the `factory:ready` label.
- The contents of the outbound allowlist.

## Observability

### Decided

- **Progress for the issue author.** The run posts comments and sets labels on the issue. [Runtime view](./06-runtime-view.md) lists them.
- **Run record.** Each run writes its factory version, input, duration, cost and outcome to the run record.
- **Session ID.** The run record stores the SDK's `sessionId` for each run.

### Not yet designed

- Logs: format, destination and retention.
- Metrics and alarms, including an alarm on the dead-letter queue.
- Tracing. Lambda durable functions support OpenTelemetry tracing across steps, waits and callbacks ([source](https://aws.amazon.com/about-aws/whats-new/2026/11/lambda-durable-otel/)).
- How a factory engineer investigates one run from end to end.

## Error handling and idempotency

- **Retries.** The event queue redelivers an event when the event handler fails. After too many receives, SQS moves the event to the dead-letter queue.
- **Idempotent run start.** The execution name contains GitHub's delivery ID. Starting the same execution name with the same input returns the existing execution. [Runtime view](./06-runtime-view.md#a-retried-event) describes the scenario.
- **One run per issue.** A conditional write on the claim stops two events from starting two runs for one issue.
- **Unresponsive sandbox.** The agent runner sends heartbeats. A heartbeat timeout fails the callback, and the run sets `factory:failed`.
- **Failed runs.** A failed run sets `factory:failed` and comments with the reason. The issue author adds `factory:ready` to start a new run.

## Factory versioning

- A factory version is a semver tag in the factory definition repository.
- A factory version pins the plugin and the settings file. A change to either makes a new factory version.
- A `factory:v<semver>` label maps to exactly one commit of the factory definition.
- The sandbox image holds the harness. A harness upgrade applies to every factory version.
- The run record stores the harness version and the sandbox image for each run.
- [ADR 0012](../adr/0012-a-factory-version-is-a-plugin-at-a-git-tag.md) holds the decision.

## Limits and timeouts

| Limit | Set in | Relation |
| --- | --- | --- |
| The agent's turn limit and budget limit | The factory definition's settings file | Below the 8 hour AgentCore Runtime session limit. |
| Heartbeat interval and heartbeat timeout | Not yet decided | |
| Durable execution timeout | Not yet decided | Above the 8 hour AgentCore Runtime session limit. |

The values are open. See [Risks and technical debt](./11-risks-and-technical-debt.md).

## Cost tracking

The run record stores `costUsdEstimate` and the token counts per model. [ADR 0010](../adr/0010-cost-is-the-sdk-estimate.md) holds the decision.
