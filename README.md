# issue-factory

A software factory: a labelled GitLab issue goes in, agents do the work, and one merge request comes out for a person to review.

**Status:** design. Nothing is built yet.

## Scope

One factory, for one kind of work: turning a GitLab issue into a merge request.

1. A person fills out a GitLab issue. The issue is the whole body of work.
2. They add the factory label. That starts a run.
3. The factory runs its agents on the issue, in the order the factory definition sets.
4. The factory opens one merge request for that issue.
5. GitLab CI runs on the merge request.
6. A person reviews and merges.
7. When the merge request is merged or closed, the factory records the result and the run ends.

Communication happens on the GitLab issue. Verification is the repository's existing GitLab pipeline. A run stays open until the merge request is merged or closed, which can take days.

## Design

The architecture is designed before anything is built. Decisions and open items live in [docs/](docs/).
