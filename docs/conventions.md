# Lean conventions

[中文版本](zh-CN/conventions.md)

FemLean follows current Mathlib conventions unless a documented project-specific
reason requires otherwise.

## Names and source mapping

- Use descriptive declaration names in the appropriate `FemLean` namespace.
- Record book edition, section, and page in the blueprint or PR rather than in
  chapter-numbered Lean directories.
- Keep mathematical definitions discoverable through docstrings and blueprint
  links.
- Do not reproduce large copyrighted excerpts from the book.

## Imports and files

- Import the smallest module that provides the required interface.
- Do not import the public `FemLean.lean` root from internal modules.
- Keep independent reusable results in separate modules.
- Avoid giant general-purpose utility files.

## Notation and automation

- Prefer scoped notation; open scopes locally in downstream modules.
- Add global typeclass instances only for canonical constructions.
- Use local instances for experiments and competing representations.
- Add global `simp` attributes only when the rewrite direction contributes to a
  coherent normal form.
- Avoid unnecessary coercions and automation that obscures a theorem statement.

## Statements and examples

- Make important mathematical hypotheses visible in statements or explicit
  structures rather than hiding them in unrelated variables.
- Include compiling examples that exercise new interfaces.
- Do not use custom axioms as interface placeholders on the main branch.
- Temporary unfinished proofs belong only in Draft PRs.

## Refactors and dependencies

- Separate behavior-preserving refactors from mathematical changes.
- Update Lean, Mathlib, and documentation dependencies in dedicated PRs.
- Pin dependency revisions through Lake manifests and document upgrade reasons.
