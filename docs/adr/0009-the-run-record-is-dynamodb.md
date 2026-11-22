---
status: accepted
---

# The run record is DynamoDB

The factory needs a store for one record per run and for the per-issue claim. The claim needs an atomic check-and-write.

## Decision

- The run record is a DynamoDB table.
- A conditional write holds an issue's claim.
- Comparing factory versions starts as a script over all runs.

## Considered options

| Option | Why not |
| --- | --- |
| The durable function's execution history as the record | The history is not the record. AWS can delete a finished execution's history, and the event handler adds the pull request's result after the execution ends. |

## Consequences

- When a script is no longer enough, DynamoDB's export to S3 with Athena is available.
