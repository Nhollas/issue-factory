# 4. Solution strategy

## Principles

- **Buy the sandbox and the agent loop.** AgentCore Runtime provides the sandbox. The harness provides the agent loop.
- **Build only what the workflow needs around them.** The factory starts a run from a label, starts the agent session, opens the pull request, posts progress and writes the run record.
- **Fixed code does the steps that must happen every time.** The run opens the pull request, posts progress and writes the run record. The agent decides how to implement the issue.
- **The factory takes facts from systems of record.** Check results come from GitHub. Times and costs come from the factory's own records.
- **A harness is a replaceable worker.** The run starts a harness in a sandbox and reads back its result and cost.

## Approach

| Goal | Approach | Decision |
| --- | --- | --- |
| Comparable factory versions | A factory version is one git tag. The tag pins the skills, the hooks, the model and the limits. | [ADR 0012](../adr/0012-a-factory-version-is-a-plugin-at-a-git-tag.md) |
| Comparable factory versions | Every run writes the factory version, the inputs, the time, the cost and the outcome to the run record. | [ADR 0009](../adr/0009-the-run-record-is-dynamodb.md) |
| Enforced steps | One durable execution per run performs the fixed steps in order. | [ADR 0011](../adr/0011-lambda-durable-functions-and-typescript.md) |
| Enforced steps | The run suspends while the agent works and resumes when the agent runner completes a callback. | [ADR 0007](../adr/0007-the-run-suspends-on-a-durable-callback.md) |
| Facts from systems of record | The run reads the run branch from GitHub before it opens a pull request. | [Runtime view](./06-runtime-view.md#the-run) |
| Isolated runs | An issue has one active run at most. Each run has its own branch and its own pull request. | [ADR 0002](../adr/0002-one-active-run-per-issue.md) |
