# 10. Quality requirements

## Requirements

| Quality | Requirement |
| --- | --- |
| Comparability | The run record holds enough to compare two factory versions on time, cost and outcome. The factory writes it from the first run. |
| Reproducibility | A `factory:v<semver>` label maps to exactly one commit of the factory definition. |
| Reliability | Every run that starts ends with one outcome label and one comment on the issue. [Risks and technical debt](./11-risks-and-technical-debt.md) lists one known gap. |
| Isolation | A run reads and changes only its own run branch and its own pull request. |
| Verifiability | The repository's existing checks decide whether a pull request is good. |
| Performance | Speed is not a priority. A run can take hours. |

## Example of the comparability requirement

A factory engineer can state "version 2 took half the time and half the cost of version 1" from the run record alone.

## Not yet designed

- Measurable quality scenarios for each requirement.
- A fair comparison of factory versions. See [Risks and technical debt](./11-risks-and-technical-debt.md).
