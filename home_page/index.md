---
usemathjax: true
---

FemLean is a Lean 4 library for reusable, machine-checked finite element theory.
Its first vertical slice is abstract Galerkin theory, a Poisson model problem,
and a two-dimensional \(P_1\) energy-error estimate.

The project treats Braess's *Finite Elements* as a mathematical roadmap. Lean
modules are organized by dependency rather than book chapter.

## Project resources

- [GitHub repository](https://github.com/FormalCompMath/fem-lean)
- [Roadmap](https://github.com/FormalCompMath/fem-lean/blob/main/docs/roadmap.md)
- [Contributing workflow](https://github.com/FormalCompMath/fem-lean/blob/main/CONTRIBUTING.md)
- [Review and trust policy](https://github.com/FormalCompMath/fem-lean/blob/main/docs/review.md)
- [Open tasks](https://github.com/FormalCompMath/fem-lean/issues)
- [Design discussions](https://github.com/FormalCompMath/fem-lean/discussions)

## Live mathematical status

- [Blueprint]({{ site.url }}/blueprint/)
- [Blueprint as PDF]({{ site.url }}/blueprint.pdf)
- [Dependency graph]({{ site.url }}/blueprint/dep_graph_document.html)
- [Lean API documentation]({{ site.url }}/docs/)

A blueprint node can be stated without being formalized. `\leanok` records formal
completion, while independent semantic review is recorded through the pull
request and review policy. The main branch is protected by builds and an axiom
audit; neither replaces human review of mathematical definitions and statements.
