# Starting a run

[Overview](./README.md) → **Starting a run** → [The run](./the-run.md)

How a label on an issue becomes a run, how the factory keeps one run active per issue, and how an author runs an issue again.

## Rules

- An issue has at most one active run.
- Each run is isolated. It starts from the latest default branch, works on its own branch and opens its own pull request. It never reads or changes another run's branch or pull request.
- A run ends when its pull request opens or when it fails. Nothing waits for review.
- To run an issue again, the author adds `factory:ready` again. Earlier pull requests are left for people to close.

## Labels

| Label | Set by | Meaning |
| --- | --- | --- |
| `factory:ready` | Author | Start a run. |
| `factory:running` | Factory, replacing `factory:ready` and any earlier end label | A run is active. |
| `factory:done` | Factory, replacing `factory:running` | The run opened a pull request. GitHub shows the linked pull request. |
| `factory:declined` | Factory, replacing `factory:running` | The agent chose not to make a change. A comment on the issue says why. |
| `factory:failed` | Factory, replacing `factory:running` | The run failed. A comment on the issue says why. |
| `factory:v<semver>`, such as `factory:v1.4.0` | Author | The factory definition version, matching the tag in the definition repository exactly. With none, the run uses the newest tag. The factory never removes it. |

## The claim

The run record holds one claim item per issue. It names the issue's current run: its execution name and, once started, its execution ARN. Only the event handler writes it. A run never changes its claim.

The handler decides whether the claimed run is still active by asking Lambda for its execution status:

| Status | Claimed run is |
| --- | --- |
| `RUNNING`, `PAUSING`, `PAUSED` | Active. The issue is busy. |
| `SUCCEEDED`, `FAILED`, `TIMED_OUT`, `STOPPED` | Finished. The claim can be replaced. |

A run that ends without running its own code, such as one that times out or is stopped, finishes its claim the same way as any other.

The replacing write is conditional on the claim still naming the run the handler checked, so two events racing for one issue cannot both start a run.

## Handling `factory:ready`

The event handler receives an `issues` event with action `labeled` for the label `factory:ready`:

1. Reads the issue's claim. If it names a run that is still active, removes `factory:ready`, comments that a run is already in progress, and stops.
2. Replaces the claim with the new execution name, `r<repoId>-i<issueNumber>-<deliveryId>`.
3. Starts the run's durable execution asynchronously under that name.
4. Records the execution ARN on the claim.

The delivery ID is GitHub's `X-GitHub-Delivery` header, which stays the same when a delivery is redelivered ([GitHub docs](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks)). Lambda returns the existing execution when one is started again under the same name with the same input ([AWS docs](https://docs.aws.amazon.com/lambda/latest/dg/durable-execution-idempotency.html)). So if the handler fails part-way, the queue's retry of the same message finishes the same start rather than beginning a second run.

Execution names allow 1 to 64 letters, digits, `-` and `_`. The repository's numeric ID is used because its name can be longer than that.

## Run start and end on the issue

When the run starts, it sets `factory:running`, removes `factory:ready` and any earlier `factory:done`, `factory:declined` or `factory:failed`, and comments that the run has started.

When the run ends, it sets `factory:done`, `factory:declined` or `factory:failed` and comments with the pull request or the reason. [The run](./the-run.md#outcomes) defines which. Each comment and pull request names its run.

## Accepted edge cases

- **A claim with no execution ARN.** If the handler fails between steps 2 and 4 and the message reaches the dead-letter queue, the claim has no ARN to check, so the issue stays busy. We fix it by hand if it ever happens.

## Open

| Open item | Notes |
| --- | --- |
| A run that times out or is stopped leaves `factory:running` on the issue | Its claim is handled, but nothing changes its label or comments. The author can still add `factory:ready`. |
| Whether looking up one execution's status is consistent straight after it finishes | AWS says listing executions is eventually consistent; it does not say whether looking up one is. If not, a `factory:ready` added just after a run ends is turned away. |
