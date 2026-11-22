---
status: accepted
---

# Models come from the Anthropic API with an API key

The Claude Agent SDK needs access to a model.

## Decision

- The agent session calls the Anthropic API with an API key.
- The key is in the sandbox.

## Accepted risk

The agent can read the key, as it can read the GitHub token ([ADR 0001](./0001-agent-holds-scoped-github-token.md)).

## Consequences

- Where the factory stores the key is not yet designed.
