## Guidelines

- This is pre-launch software with no users: prefer the breaking change to migrations, shims or backwards-compatible paths.
- No inline comments. If code needs explaining, rename it, restructure it, or link the spec or ADR that explains it. Delete inline comments in code you touch.
- Trunk-based development: commit and push straight to `main`. No feature branches or merge requests.

## Writing documentation

- Describe the current design only, in the present tense. Rejected options and the reasons for a decision go in an ADR and nowhere else.
- Do not define something by what it is not. Write "the run reads the branch from GitHub", not "the run trusts GitHub, not the agent".
- One term, one meaning. Define every domain term in the [glossary](docs/architecture/12-glossary.md) before using it, and use that exact term every time.
- No metaphors or figures of speech. Write "the run suspends", not "the run sleeps".
- Every sentence names who does what to what. Use the active voice.
- One fact per sentence. 25 words at most.
- Architecture documentation follows [arc42](https://arc42.org/overview). Put content in the section arc42 assigns it to. Keep a heading for a section that is not yet designed and say so.
