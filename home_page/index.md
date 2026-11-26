---
layout: default
title: Home
nav_order: 1
permalink: /
usemathjax: true
---

# FemLean

Reusable, machine-checked finite element theory in Lean 4.
{: .fs-6 .fw-300 }

[Getting started]({{ '/getting-started/' | relative_url }}){: .btn .btn-primary }
[Blueprint]({{ '/blueprint/' | relative_url }}){: .btn }
[中文文档]({{ '/zh-CN/' | relative_url }}){: .btn .btn-outline }

{: .note }
The project is starting M1: abstract Galerkin theory and Céa's lemma, followed by a
Poisson model problem and a two-dimensional $$P_1$$ energy-error theorem.

## Mathematical roadmap

The project uses Braess's *Finite Elements* as a source of mathematical results,
while Lean modules are organized by dependency rather than book chapter.

The first vertical slice connects abstract Galerkin theory to a concrete conforming
finite element method.

## Project resources

- [Contribution workflow](https://github.com/FormalCompMath/fem-lean/blob/main/CONTRIBUTING.md)
- [Architecture](https://github.com/FormalCompMath/fem-lean/blob/main/docs/architecture.md)
- [Review and trust policy](https://github.com/FormalCompMath/fem-lean/blob/main/docs/review.md)
- [Roadmap](https://github.com/FormalCompMath/fem-lean/blob/main/docs/roadmap.md)
- [Open tasks](https://github.com/FormalCompMath/fem-lean/issues)
- [Design discussions](https://github.com/FormalCompMath/fem-lean/discussions)

## Live mathematical status

- [Blueprint]({{ '/blueprint/' | relative_url }})
- [Blueprint as PDF]({{ '/blueprint.pdf' | relative_url }})
- [Dependency graph]({{ '/blueprint/dep_graph_document.html' | relative_url }})
- [Lean API documentation]({{ '/docs/' | relative_url }})
- [Task board](https://github.com/orgs/FormalCompMath/projects/1)

A blueprint node can be stated without being formalized. `\leanok` records formal
completion, while independent semantic review is recorded through pull requests.
Builds and axiom audits protect the main branch; neither replaces human review of
mathematical definitions and statements.
