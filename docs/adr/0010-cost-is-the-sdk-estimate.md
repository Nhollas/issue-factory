---
status: accepted
---

# Cost is the SDK's estimate

The run record needs a cost for each agent session.

## Decision

- The run record stores the SDK's `costUsdEstimate` and the token counts per model.

## Consequences

- The SDK computes the figure on the client from a price table bundled with the SDK ([cost tracking](https://code.claude.com/docs/en/agent-sdk/cost-tracking)).
- The estimate can shift between SDK versions, and so between factory versions.
- The token counts per model allow a recalculation with one price table.
