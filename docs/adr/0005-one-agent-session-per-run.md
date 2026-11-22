---
status: accepted
---

# A run is one agent session, on the Claude Agent SDK first

The factory could split a run into several agent steps, or support several harnesses from the start. Neither has data behind it yet.

## Decision

- A run is one agent session.
- The first version supports the Claude Agent SDK only.
- Each factory version names its model. The Codex SDK and OpenAI models can be added later.
- The model vendor is chosen per factory version, not per run or per step.

## Consequences

- Several steps per run can be added later if the run record shows that they help.
- The contract between the run and the agent runner carries the harness name and version, so the run record can compare harnesses.
