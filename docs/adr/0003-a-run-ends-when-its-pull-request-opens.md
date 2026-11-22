---
status: accepted
---

# A run ends when its pull request opens

Review can take days. A run that waited for review would stay active for that whole time.

## Decision

- A run ends when its pull request opens, when the agent declines, or when the run fails.
- Nothing in the factory waits for review.
- When GitHub reports the pull request merged or closed, the event handler adds the result to that run's record. The result is the check result, merged or closed, and the time to merge.

## Consequences

- The factory does not respond to review comments. To get a different result, the issue author adds `factory:ready` again.
- The run record for one run is written in two parts, by the run and later by the event handler.
