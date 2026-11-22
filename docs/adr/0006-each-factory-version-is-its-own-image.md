---
status: superseded by 0012
---

# Each factory version is its own image

The run record compares factory versions. That comparison is only sound if a version label maps exactly to what ran.

## Decision

- The factory definition lives in one repository and serves every target repository.
- A factory version is a semver tag in that repository.
- A factory version pins the harness and its version, the model, the instructions, the skills, the hooks and the sandbox image. A change to any of them makes a new factory version.
- Tagging a factory version builds one sandbox image that contains the harness and the definition's files.
- Each image is deployed as one AgentCore Runtime version behind its own endpoint. AgentCore Runtime versions are immutable.
- A label such as `factory:v1.4.0` selects a factory version exactly. With no version label, the run uses the newest tag.

## Consequences

- Every factory version's image stays deployed.
- The run's current code must understand every deployed agent runner. The contract carries `contractVersion` for that reason.
- The AgentCore limits on versions and endpoints per runtime are unknown. See [Risks and technical debt](../architecture/11-risks-and-technical-debt.md).
