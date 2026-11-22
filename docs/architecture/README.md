# Issue factory architecture

The issue factory turns a labelled GitHub issue into one pull request for a person to review.

This documentation follows the [arc42](https://arc42.org/overview) template. The diagrams follow the [C4 model](https://c4model.com). [workspace.dsl](./workspace.dsl) is the source of the diagrams, and `scripts/render-c4.sh` renders them.

| Section | Contents |
| --- | --- |
| [1. Introduction and goals](./01-introduction-and-goals.md) | What the factory does, its quality goals and its stakeholders. |
| [2. Constraints](./02-constraints.md) | Fixed technology and platform limits. |
| [3. Context and scope](./03-context-and-scope.md) | The people and external systems around the factory. |
| [4. Solution strategy](./04-solution-strategy.md) | The principles and the approach to each quality goal. |
| [5. Building block view](./05-building-block-view.md) | The containers, the run record and the interfaces. |
| [6. Runtime view](./06-runtime-view.md) | Starting a run, the run, running an issue again, and after the pull request. |
| [7. Deployment view](./07-deployment-view.md) | Where each container runs. |
| [8. Crosscutting concepts](./08-crosscutting-concepts.md) | Security, observability, error handling, versioning, limits and cost. |
| [9. Architecture decisions](./09-architecture-decisions.md) | The index of ADRs. |
| [10. Quality requirements](./10-quality-requirements.md) | The quality requirements in detail. |
| [11. Risks and technical debt](./11-risks-and-technical-debt.md) | Open questions, risks, known gaps and deferred work. |
| [12. Glossary](./12-glossary.md) | The domain terms. |

[Prior art](../research/prior-art.md) lists the systems that this design borrows from.
