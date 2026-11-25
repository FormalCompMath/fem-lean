# Review and trust policy

## Trust model

Lean checks whether a proof term has the stated type. Humans must still check
that the type expresses the intended theorem and that definitions represent the
intended objects. Review therefore prioritizes:

1. definitions and representation choices;
2. theorem statements and their assumptions;
3. compiling examples and downstream uses;
4. proof maintainability.

A green CI run is necessary but is not, by itself, semantic review.

## Definition review checklist

A definition PR should provide the standard mathematical definition, its source,
and the Lean representation. Reviewers should check:

- explicit and implicit parameters, universes, coercions, and typeclass search;
- whether a predicate, subtype, structure, or typeclass is appropriate;
- invariants and degenerate inputs, such as empty domains or degenerate cells;
- boundary, measure, norm, and orientation conventions;
- whether the definition is too weak for intended theorems or too strong for
  expected applications;
- equivalence with a standard formulation when useful;
- concrete examples that would expose an unintended or vacuous definition.

Core representation changes should link to an RFC and compare alternatives using
small downstream examples.

## Statement review checklist

Compare the informal and Lean statements before reviewing the proof. Check:

- quantifier order and implicit variables;
- continuity, coercivity, symmetry, regularity, and boundary assumptions;
- mesh-family versus fixed-mesh quantification;
- norm and seminorm choices;
- inequality directions and coercivity/continuity constants;
- dependencies of constants on dimension, polynomial degree, domain, and shape
  regularity;
- whether the formal version is stronger, weaker, or different from the source;
- non-vacuity and at least one intended concrete instantiation.

Any difference from the source must be explicit in the PR and blueprint. A change
to a previously approved statement invalidates its semantic approval.

## Examples as interface tests

Examples are compiled mathematical checks, not prose decorations. Useful early
examples include:

- nodal basis functions satisfy the Kronecker-delta property at nodes;
- an affine reference map sends reference vertices to the correct vertices;
- taking the discrete space equal to the continuous space recovers the weak
  solution;
- a model bilinear form satisfies the abstract variational interface;
- a familiar corollary can be derived from a new general theorem.

Examples live downstream and must not be imported by library modules.

## Proof review checklist

Once the statement is fixed and CI succeeds, the kernel handles correctness.
Human proof review focuses on:

- duplicated arguments that deserve a lemma;
- accidental dependencies on concrete models;
- unstable instances, coercions, notation, or automation;
- opportunities to reuse Mathlib;
- fragile proof scripts and unnecessary heartbeat increases;
- documentation and module placement.

## Continuous trust checks

The main branch must not contain proof placeholders or project-specific axioms.
CI uses `axiom-audit` over the `FemLean` root namespace and permits only:

- `propext`;
- `Classical.choice`;
- `Quot.sound`.

This catches placeholder axioms, native-decide trust extensions, and custom
axioms, including transitive dependencies. Milestone releases should additionally
publish `#print axioms` output for their main declarations when practical.

Blueprint declaration checking ensures that referenced Lean names exist. It does
not prove that the informal and formal statements agree; that remains a human
review obligation.

## Approval rules

- The author cannot be the sole reviewer.
- Ordinary results need at least one independent approval.
- Core interfaces and breaking shared representations normally need an RFC and
  two approvals.
- Stale approvals are dismissed after subsequent changes.
- All review conversations must be resolved before merge.
