---
status: accepted
---

# An issue has one active run at most, and runs are isolated

An issue author can add `factory:ready` to an issue more than once. Two runs on one issue at the same time would produce two competing pull requests.

## Decision

- An issue has one active run at most.
- The run record holds one claim per issue. A conditional write on the claim decides which event starts a run.
- The event handler rejects `factory:ready` while the issue has an active run. It removes the label and comments.
- After a run ends, adding `factory:ready` again starts a new run on the same issue.
- Each run starts from the latest commit on the default branch, works on its own run branch and opens its own pull request.
- A run never reads or changes another run's branch or pull request.
- The factory leaves earlier pull requests open. A person closes them.

## Consequences

- A second run does not build on the first run's work.
- An issue can have several open pull requests from different runs.
