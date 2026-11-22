# 1. Introduction and goals

The issue factory turns one labelled GitHub issue into one pull request. An agent does the work. A person reviews and merges the pull request.

## Scope

One factory, for one kind of work: turning a GitHub issue into a pull request.

## Requirements overview

1. An issue author writes a GitHub issue. The issue is the whole body of work.
2. The issue author adds the label `factory:ready`. The label starts a run.
3. The run starts one agent session on the issue. The factory definition sets up the agent session.
4. The run opens one pull request for the issue.
5. The repository's CI runs on the pull request.
6. A reviewer reviews and merges the pull request.
7. When GitHub reports the pull request merged or closed, the event handler adds the result to the run record.

The factory posts its progress on the GitHub issue. [Runtime view](./06-runtime-view.md) describes each step.

## Quality goals

| Priority | Goal | Meaning |
| --- | --- | --- |
| 1 | Comparable factory versions | A factory engineer can compare two factory versions on time, cost and outcome, from the first run onwards. |
| 2 | Enforced steps | Every run opens the pull request, posts progress and writes the run record. Fixed code does these steps. |
| 3 | Facts from systems of record | Check results come from GitHub. Times and costs come from the factory's own records. |
| 4 | Isolated runs | A run reads and changes only its own branch and its own pull request. |

[Quality requirements](./10-quality-requirements.md) holds the detail.

## Stakeholders

| Stakeholder | Expectation |
| --- | --- |
| Issue author | Adds one label and sees the run's progress and result on the issue. |
| Reviewer | Receives one pull request per run, with the repository's checks run on it. |
| Factory engineer | Changes the factory definition and compares factory versions using the run record. |
