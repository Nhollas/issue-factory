---
status: accepted
---

# The factory's own code is TypeScript on Lambda durable functions

The factory's own code starts a run, waits hours for an agent, and then opens a pull request. It needs to keep its place across that wait.

## Decision

- The factory's own code runs on AWS Lambda durable functions, with one execution per run.
- The language is TypeScript.

## Relevant durable function features

Announced November 2026:

- **Pause and resume** a running execution from its last checkpoint. Paused time does not count towards the timeout ([source](https://aws.amazon.com/about-aws/whats-new/2026/11/lambda-durable-pause-delete/)).
- **Delete** a finished execution's history and payloads early (same source).
- **OpenTelemetry tracing** across steps, waits and callbacks, for TypeScript, Python and Java ([source](https://aws.amazon.com/about-aws/whats-new/2026/11/lambda-durable-otel/)).
