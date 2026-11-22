# 9. Architecture decisions

Each decision is one ADR in [`docs/adr`](../adr). An ADR holds the decision, the reasons and the rejected options.

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](../adr/0001-agent-holds-scoped-github-token.md) | The agent holds a short-lived, narrowly scoped GitHub token. | Accepted |
| [0002](../adr/0002-one-active-run-per-issue.md) | An issue has one active run at most, and runs are isolated. | Accepted |
| [0003](../adr/0003-a-run-ends-when-its-pull-request-opens.md) | A run ends when its pull request opens. | Accepted |
| [0004](../adr/0004-github-events-pass-through-a-queue.md) | GitHub events pass through a queue. | Accepted |
| [0005](../adr/0005-one-agent-session-per-run.md) | A run is one agent session, on the Claude Agent SDK first. | Accepted |
| [0006](../adr/0006-each-factory-version-is-its-own-image.md) | Each factory version is its own image. | Superseded by 0012 |
| [0007](../adr/0007-the-run-suspends-on-a-durable-callback.md) | The run suspends on a durable callback while the agent works. | Accepted |
| [0008](../adr/0008-models-come-from-the-anthropic-api.md) | Models come from the Anthropic API with an API key. | Accepted |
| [0009](../adr/0009-the-run-record-is-dynamodb.md) | The run record is DynamoDB. | Accepted |
| [0010](../adr/0010-cost-is-the-sdk-estimate.md) | Cost is the SDK's estimate. | Accepted |
| [0011](../adr/0011-lambda-durable-functions-and-typescript.md) | The factory's own code is TypeScript on Lambda durable functions. | Accepted |
| [0012](../adr/0012-a-factory-version-is-a-plugin-at-a-git-tag.md) | A factory version is a plugin and a settings file at a git tag. | Accepted |
