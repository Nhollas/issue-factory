# 2. Constraints

## Technology

| Area | Constraint |
| --- | --- |
| Code host | GitHub. |
| Where agents run | AWS Bedrock AgentCore Runtime. |
| Model vendor | The Anthropic API in the first version. OpenAI is planned for a later version, with its own harness and models. |
| Harness | The Claude Agent SDK in the first version. The Codex SDK is planned for a later version. |

[ADR 0011](../adr/0011-lambda-durable-functions-and-typescript.md) sets the technology for the factory's own code.

## Platform limits

| Limit | Value | Source |
| --- | --- | --- |
| One Lambda invocation | 900 seconds at most | [Lambda quotas](https://docs.aws.amazon.com/general/latest/gr/lambda-service.html) |
| One AgentCore Runtime session | 8 hours at most | [ADR 0007](../adr/0007-the-run-suspends-on-a-durable-callback.md) |
| AgentCore Runtime session end | AgentCore documents no API that tells a caller a session has finished | [ADR 0007](../adr/0007-the-run-suspends-on-a-durable-callback.md) |
| Durable execution name | 1 to 64 letters, digits, `-` and `_` | Source not recorded |
| GitHub App installation token | Expires after one hour | [ADR 0001](../adr/0001-agent-holds-scoped-github-token.md) |
| GitHub webhook requests | GitHub cannot sign requests with AWS credentials | [ADR 0004](../adr/0004-github-events-pass-through-a-queue.md) |
| GitHub webhook redelivery | GitHub does not redeliver a failed delivery on its own | Source not recorded |

## Method

- Each design choice rests on a documented capability of a real tool. The documents link the source.
- Speed is not a priority. A run can do a full install of the repository.
