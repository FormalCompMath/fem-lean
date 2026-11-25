# FormalCompMath FemLean

A Lean 4 library for reusable, machine-checked finite element theory, using
Dietrich Braess's *Finite Elements* as a mathematical roadmap rather than as a
file-by-file translation target.

## Status

The project is at the infrastructure milestone. The first mathematical milestone
is an abstract Galerkin layer culminating in Céa's lemma, followed by a Poisson
model and a two-dimensional \(P_1\) energy-error theorem.

## Development

The pinned toolchain is Lean 4.36.0 with Mathlib 4.36.0.

```bash
lake exe cache get
lake build
lake env lean tests/Smoke.lean
```

See [CONTRIBUTING.md](CONTRIBUTING.md), [the architecture](docs/architecture.md),
[the review policy](docs/review.md), and [the roadmap](docs/roadmap.md).

## Trust policy

The main branch must build without `sorry`, `admit`, or project-specific axioms.
CI audits declarations under `FemLean` and permits only Lean's standard axioms
`propext`, `Classical.choice`, and `Quot.sound`.

## Reference material

The copyrighted book PDF is kept locally under `references/` and is not tracked.
Blueprint entries paraphrase mathematical statements and cite edition and page;
they do not reproduce the book wholesale.

## License

Apache-2.0. See [LICENSE](LICENSE).
