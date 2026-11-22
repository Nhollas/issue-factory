---
status: accepted
---

# A factory version is a plugin and a settings file at a git tag

Supersedes [ADR 0006](./0006-each-factory-version-is-its-own-image.md).

ADR 0006 built one sandbox image per factory version. Each image held its own copy of the agent runner. The run's code then had to stay compatible with every agent runner ever deployed.

The factory needs versions so that a factory engineer can compare them. The thing to compare is what changes the agent's behaviour. The agent runner is not part of that.

## Decision

- A factory version is a semver tag in the factory definition repository.
- The factory definition holds two things: a Claude plugin and a settings file.
- The plugin holds the skills and the hooks, and can hold agents and MCP server definitions ([plugins](https://code.claude.com/docs/en/agent-sdk/plugins)).
- The settings file holds the model, the turn limit and the budget limit. The plugin format has no documented place for these.
- The factory has one sandbox image. The image holds the agent runner and the harness.
- The sandbox image deploys together with the run's code.
- At the start of a run, the agent runner clones the factory definition at the run's tag into the sandbox. The SDK loads a plugin from a local directory only.
- The agent runner passes the plugin's path and the settings to the SDK when it starts the agent session.
- The SDK skips a plugin path that does not exist and reports no error. The agent runner reads the `plugins` list in the SDK's `init` message and fails the run if the plugin is missing.
- A label such as `factory:v1.4.0` selects a factory version exactly. With no version label, the run uses the newest tag.

## Considered options

| Option | Why not |
| --- | --- |
| One sandbox image per factory version (ADR 0006) | Every old agent runner stays deployed. The run's code must stay compatible with all of them. |
| The plugin's own `version` field as the factory version | A git tag names one commit. The manifest is optional and its version is a field that a person edits. |

## Consequences

- The run and the agent runner always deploy together. The contract between them needs no version field.
- The format of the factory definition must stay stable, or old tags stop working.
- A factory version does not pin the harness. A harness upgrade applies to every factory version at once. The run record stores the harness version for each run.
- A fair comparison of two factory versions runs both on the same sandbox image.
- The sandbox needs read access to the factory definition repository.
- A second harness needs a second sandbox image.
