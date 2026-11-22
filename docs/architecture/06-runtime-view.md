# 6. Runtime view

## Starting a run

An issue author adds `factory:ready` to an issue. GitHub sends an `issues` event with action `labeled`.

1. The webhook receiver verifies the webhook signature and puts the event on the event queue.
2. The event handler reads the issue's claim from the run record.
3. If the claim names an active run, the event handler follows [A label on a busy issue](#a-label-on-a-busy-issue) and stops.
4. The event handler replaces the claim with the new execution name, `r<repoId>-i<issueNumber>-<deliveryId>`.
5. The event handler starts the run's durable execution asynchronously under that name.
6. The event handler writes the execution ARN to the claim.

`repoId` is the repository's numeric ID. `deliveryId` is GitHub's `X-GitHub-Delivery` header.

### The claim

The run record holds one claim per issue. The claim names the issue's current run by execution name and, after step 6, by execution ARN. Only the event handler writes the claim.

The event handler asks Lambda for the status of the claimed execution:

| Status | The claimed run is |
| --- | --- |
| `RUNNING`, `PAUSING`, `PAUSED` | Active. |
| `SUCCEEDED`, `FAILED`, `TIMED_OUT`, `STOPPED` | Finished. The event handler can replace the claim. |

The write in step 4 is conditional. It succeeds only if the claim still names the execution that the event handler checked. When two events race for one issue, one write succeeds and one fails.

### A label on a busy issue

The claim names an active run.

1. The event handler removes `factory:ready` from the issue.
2. The event handler comments that a run is already in progress.

### A retried event

The event handler fails part-way through [Starting a run](#starting-a-run). The event queue delivers the same message again.

1. The event handler computes the same execution name, because the delivery ID is the same.
2. Lambda returns the existing execution when the event handler starts it again under the same name with the same input ([AWS docs](https://docs.aws.amazon.com/lambda/latest/dg/durable-execution-idempotency.html)).
3. The event handler writes the execution ARN to the claim.

A delivery that GitHub redelivers keeps its delivery ID ([GitHub docs](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks)). The same steps apply.

## The run

One durable execution performs these steps.

1. The run resolves the factory version. It uses the `factory:v<semver>` label, or the newest tag when the issue has no such label.
2. The run sets `factory:running` on the issue. It removes `factory:ready` and any `factory:done`, `factory:declined` or `factory:failed` label.
3. The run comments on the issue that the run has started.
4. The run mints the run's GitHub token ([ADR 0001](../adr/0001-agent-holds-scoped-github-token.md)).
5. The run creates a callback.
6. The run invokes the AgentCore endpoint with the [start request](./05-building-block-view.md#1-start-request-run-to-agent-runner). The invoke returns at once.
7. The run suspends.
8. The agent runner clones the factory definition at the run's tag into the sandbox.
9. The agent runner starts the agent session with the plugin's path and the settings.
10. The agent runner reads the `plugins` list in the SDK's `init` message. If the plugin is missing, the agent runner fails the callback.
11. The agent runner sends heartbeats while the agent works.
12. The agent clones the repository, makes the change and pushes the run branch.
13. The agent runner completes the callback with the [callback message](./05-building-block-view.md#3-callback-agent-runner-to-run). The run resumes.
14. The run revokes the token.
15. The run asks GitHub whether the run branch exists and has commits beyond the base commit.
16. The run acts on the [outcome](#outcomes) and writes it to the run record.

If the heartbeats stop, the callback fails. When the callback fails, the run resumes at step 14.

### Outcomes

| Result | The run |
| --- | --- |
| `success`, `completed`, and the run branch has new commits | Opens the pull request, sets `factory:done`, and comments with the link. |
| `success`, `completed`, and the run branch has no new commits | Sets `factory:failed`. Comments that the agent reported completion and pushed no commits. |
| `success`, `declined` | Sets `factory:declined`. Comments with the agent's summary. |
| An `error_*` ending | Sets `factory:failed`. Comments with the ending. |
| The agent runner failed the callback | Sets `factory:failed`. Comments with the agent runner's reason. |
| The heartbeats stopped | Sets `factory:failed`. Comments that the sandbox stopped responding. |

Each outcome label replaces `factory:running`. Each comment and each pull request names its run. The run sets the pull request title from the issue title.

## Running an issue again

An issue's run has finished. The issue author adds `factory:ready` again.

1. The event handler follows [Starting a run](#starting-a-run). The claim names a finished run, so the event handler replaces it.
2. The new run starts from the latest commit on the default branch.
3. The new run works on its own run branch and opens its own pull request.

Earlier pull requests stay open. A person closes them.

## After the pull request

GitHub reports that a run's pull request is merged or closed.

1. The webhook receiver verifies the webhook signature and puts the event on the event queue.
2. The event handler reads the result of the pull request's checks from GitHub.
3. The event handler writes the check result, merged or closed, and the time to merge to that run's record.
