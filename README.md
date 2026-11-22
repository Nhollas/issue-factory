# issue-factory

A software factory: a labelled GitHub issue goes in, agents do the work, and one pull request comes out for a person to review.

**Status:** design. Nothing is built yet.

## Scope

One factory, for one kind of work: turning a GitHub issue into a pull request.

1. A person fills out a GitHub issue. The issue is the whole body of work.
2. They add the factory label. That starts a run.
3. The factory runs its agents on the issue, in the order the factory definition sets.
4. The factory opens one pull request for that issue.
5. The repository's checks run on the pull request.
6. A person reviews and merges.
7. When the pull request is merged or closed, the factory records the result and the run ends.

Communication happens on the GitHub issue. Verification is the repository's existing checks. A run stays open until the pull request is merged or closed, which can take days.

## Design

The architecture is designed before anything is built. Decisions and open items live in [docs/](docs/).
