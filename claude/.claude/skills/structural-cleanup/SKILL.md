---
name: structural-cleanup
description: Review the work just done for cleanup opportunities where a better data structure or organizing model (state machine, typed model, lookup table/registry, discriminated union, reducer/command-event model, module boundary, queue/cache/index/normalized collection) would make the code simpler, safer, or easier to extend. Returns a verdict — implement, recommend, or skip — and only makes the change when it is clear, low-risk, and in scope. Use after a spike, prototype, or feature push, and whenever the user asks to "review the structure", "is there a better data structure here", "clean this up", "did we accumulate accidental complexity", "should this be a state machine", or invokes "/structural-cleanup".
disable-model-invocation: true
---

# Structural Cleanup Review

Look at the work just done and ask one question: **is this code carrying accidental complexity
that a better data structure or organizing model would remove?**

This is a *structure* review, not a bug hunt and not a style pass. It ends with a verdict and,
when justified, the smallest useful change.

## The prime directive

**Do not force an abstraction.** Boring code that is clear, local, and unlikely to grow is the
correct answer most of the time. Be especially skeptical of any abstraction that adds indirection
without removing at least one of:

- branches / repeated conditionals
- duplicated rules or transformations
- representable-but-invalid states
- lifecycle or ordering risk

If it doesn't remove one of those, the verdict is **skip**.

## Workflow

### 1. Establish what "the work we have just been doing" means

Scope the review to the recent work, in this order of preference:

1. Files changed in this conversation (edits you made, files you wrote).
2. Uncommitted changes — `git status`, `git diff`, `git diff --staged`.
3. The current branch vs its base — `git diff <base>...HEAD --stat`.

If none of these narrow it down, ask the user which area to review. Do **not** review the whole
repo.

Read the changed files properly — enough to reason about state, ownership, and data flow. A diff
alone usually hides the shape.

### 2. Inventory the complexity that actually appeared

Look concretely for:

- **Scattered booleans / phases / lifecycle checks** — `isLoading && !isError && hasLoaded`,
  flags set in one place and read in three, states that can contradict each other.
- **Mirrored state** — the same truth stored in two places that must be kept in sync by hand.
- **Repeated conditionals** — the same `switch`/`if` chain on the same discriminator appearing
  in multiple files or functions.
- **Loose parameters / repeated shape assumptions** — long argument lists, bags of primitives,
  the same ad hoc object literal reassembled in several call sites.
- **Unclear ownership** — who is allowed to mutate this? who validates it? invariants enforced
  at call sites instead of in one place.
- **Invalid intermediate states** — combinations the domain forbids but the types permit.
- **Fragile ordering** — "you must call A before B" encoded only in comments or luck.
- **Duplicated transformations** — the same mapping/normalizing done in several layers.
- **Awkward data access** — repeated `O(n)` scans over a list that wants an index/map, manual
  parent-child walking that wants a tree, hand-rolled retry/backlog that wants a queue.

Write down what you found with file:line references. If you found nothing real, say so — that is
a legitimate outcome.

### 3. Consider whether an organizing model encodes the domain more directly

Candidate shapes (this is a menu, not a checklist — pick at most one, usually zero):

- **State machine** instead of scattered booleans, phases, or lifecycle checks.
- **Typed object/model** instead of loose parameters or repeated shape assumptions.
- **Map, registry, lookup table, or discriminated union** instead of branching spread across files.
- **Reducer or command/event model** instead of ad hoc state mutations.
- **Small module boundary** that gathers repeated behavior, ownership, or invariants.
- **Queue, cache, index, graph/tree, or normalized collection** where the data access pattern
  calls for it.

For the candidate you pick, state plainly what invariant it makes structural — "after this, a
request cannot be both `pending` and `settled`", "after this, the shipping rules live in one
table instead of four `if` chains".

If the candidate only relocates the complexity, drop it.

### 4. Size the smallest credible change

Not the ideal end state — the smallest edit that removes the complexity you named. Then assess
risk honestly:

- Files touched.
- Behavior affected (should be: none — this is a refactor).
- Test impact: what covers this today, and what would need to change.
- Whether it should wait: is the design still moving? is the current task mid-flight?

### 5. Decide the verdict

- **implement** — the cleanup is clear, low-risk, behavior-preserving, and fits the current task
  scope. Make the change, then run the relevant checks (tests, typecheck, linter — whatever this
  project actually uses; find the real command, don't guess).
- **recommend** — the cleanup is real but larger, riskier, or would distract from the current
  goal. Describe the proposed shape and why it is worth doing. **Do not implement it.**
- **skip** — the current shape is fine, or the abstraction would add indirection without removing
  branches, duplicated rules, invalid states, or lifecycle risk. Say why briefly and stop.

When implementing, stay surgical: touch only what the cleanup requires, match existing style,
change no behavior. If mid-refactor you discover the change is bigger than it looked, stop, revert
to a clean state, and downgrade the verdict to **recommend**.

## Output format

Always return exactly these five sections, concisely:

1. **Verdict** — `implement` | `recommend` | `skip`
2. **Opportunity** — the concrete data structure or organizing model, or `none`
3. **Why** — the complexity it removes and the invariants it makes clearer
4. **Scope** — the smallest credible change (files, roughly what moves)
5. **Validation** — tests/checks actually run, or the checks that would be needed

Keep it short. No preamble, no options survey, no ranked list of every possible refactor — one
recommendation or none. Prose and bullets, no markdown tables (they render poorly in the terminal).
