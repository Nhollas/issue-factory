---
status: accepted
---

# The agent holds a short-lived, narrowly scoped GitHub token

The agent in the sandbox pushes its branch to GitHub, so it needs a token. We give it one per run, cut down as far as possible, and accept that the agent can read it. Keeping the token out of the sandbox entirely would mean building or buying more than the risk justifies right now.

## Decision

- The factory mints a GitHub App installation token for each run.
- The token covers one repository, with `contents: write` only. The factory opens the pull request itself, so the token has no `pull_requests` permission. It has no `workflows` permission, so the agent cannot change CI.
- The factory revokes the token when the agent finishes, whether the run succeeded or failed. GitHub expires it after an hour regardless.
- A ruleset protects `main`: changes need a reviewed pull request, and the App cannot bypass it.
- Workflows triggered by pull requests hold no secrets, or need approval before they run on the App's pull requests.
- Outbound traffic from the sandbox is limited to an allowlist.

## Accepted risk

We assume the agent can read the token. The likely cause is prompt injection through an issue, a repository file or a dependency, not the agent stumbling on it.

For up to an hour, a compromised agent could read the repository and push to its unprotected branches. It could not merge, change workflows, reach other repositories, or send the token outside the allowlist.

## Considered options

| Option | Why not |
| --- | --- |
| Credential proxy: the sandbox holds a placeholder and a proxy outside it swaps in the real token ([Infisical Agent Vault](https://infisical.com/platform/agent-vault), [Keycard egress-proxy](https://github.com/keycardai/egress-proxy)) | Either a product in preview or a proxy we run ourselves, including TLS interception. It stops the agent stealing the token, not using it. |
| Bundle hand-off: the agent hands the factory a git bundle and the factory pushes | Keeps the token out of the sandbox entirely, but every run's output must go through a hand-off we build and maintain. First choice if the accepted risk stops being acceptable. |
| GitHub API calls through AgentCore Gateway | Every changed file's contents goes through tool calls. Suits small API calls like Jira, not pushing code. |
| Sandbox host with built-in credential injection (Cloudflare Sandbox, Modal) | AgentCore Runtime is fixed. |
| Shared personal access token, as the [AWS sample](https://github.com/aws-samples/sample-autonomous-cloud-coding-agents/blob/main/docs/design/SECURITY.md) does | Long-lived and covers every repository. |
