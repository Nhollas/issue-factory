---
status: accepted
---

# The run suspends on a durable callback while the agent works

A run waits hours for its agent. A Lambda invocation lasts 900 seconds at most ([Lambda quotas](https://docs.aws.amazon.com/general/latest/gr/lambda-service.html)), so the run cannot hold a connection to the agent.

## Decision

- The run creates a durable function callback, invokes the AgentCore endpoint, and suspends.
- The AgentCore invoke returns at once. The session keeps working in the background ([long-running agents](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-long-run.html)).
- The agent runner in the sandbox sends heartbeats and completes the callback when the agent session ends.
- A heartbeat timeout fails the callback ([callbacks](https://docs.aws.amazon.com/durable-execution/sdk-reference/operations/callback/)).
- A run fits in one AgentCore session, which lasts 8 hours at most. The agent's limits are below that. The durable execution's timeout is just above it.

## Considered options

| Option | Why not |
| --- | --- |
| Poll AgentCore for the end of the session | AgentCore documents no API that tells a caller a session has finished. |

## Consequences

- The sandbox's AWS role needs `lambda:SendDurableExecutionCallbackSuccess` on the run's function. The agent could complete the callback with a false result.
- The run asks GitHub for the run branch's commits before it opens a pull request. A false result cannot open a pull request without commits.
