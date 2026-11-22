## Guidelines

- This is pre-launch software with no users: prefer the breaking change to migrations, shims or backwards-compatible paths.
- No inline comments. If code needs explaining, rename it, restructure it, or link the spec or ADR that explains it. Delete inline comments in code you touch.
- Trunk-based development: commit and push straight to `main`. No feature branches or merge requests.
