---
name: workflow-orchestration
description: Operating discipline for non-trivial work — plan first, offload to subagents, verify before claiming done, and capture lessons after every correction. Use when starting a multi-step task, a feature push, or a bug fix, or when the user invokes "/workflow-orchestration".
disable-model-invocation: true
---

# Workflow Orchestration

How to run a non-trivial task from start to finish. Non-trivial means **3+ steps or an
architectural decision**. Below that bar, skip this and just do the work.

At session start, read `tasks/lessons.md` if it exists and apply anything relevant to the
current project.

## 1. Plan mode by default

- Enter plan mode for any non-trivial task before touching code.
- Write the spec in detail up front — ambiguity resolved on paper is cheaper than ambiguity
  resolved in a diff.
- If something goes sideways mid-implementation, **stop and re-plan**. Do not keep pushing on a
  plan that has already been invalidated.
- Plan the verification too, not just the build. "How will I prove this works?" is part of the
  plan, not an afterthought.

## 2. Subagent strategy

- Use subagents liberally to keep the main context window clean.
- Offload research, codebase exploration, and parallel analysis — anything that produces a lot
  of intermediate reading for a small conclusion.
- One task per subagent. Focused scope, focused prompt, focused return value.
- For a genuinely hard problem, throw more compute at it: several subagents attacking different
  angles beats one agent iterating serially.
- Launch independent subagents in a single message so they run concurrently.

## 3. Task management

1. **Plan first** — write the plan to `tasks/todo.md` as checkable items.
2. **Verify the plan** — check in with the user before starting implementation.
3. **Track progress** — mark items complete as you go, not in a batch at the end.
4. **Explain changes** — a high-level summary at each step, not a diff dump.
5. **Document results** — add a review section to `tasks/todo.md` when finished.
6. **Capture lessons** — update `tasks/lessons.md` after any correction.

## 4. Self-improvement loop

After **any** correction from the user:

- Append the pattern to `tasks/lessons.md` — what you did, what was wrong, what to do instead.
- Write it as a rule for yourself, phrased so it prevents the same class of mistake, not just
  the exact instance.
- Iterate ruthlessly on these lessons until the mistake rate drops. A lesson that keeps getting
  violated is badly written — rewrite it.

## 5. Verification before done

Never mark a task complete without proving it works.

- Run the tests. Check the logs. Demonstrate correctness with actual output.
- Where relevant, diff behavior between the base branch and your changes.
- Ask: **"Would a staff engineer approve this?"** If the honest answer is no, it isn't done.
- If something is unverified, say so explicitly rather than implying it passed.

## 6. Demand elegance (balanced)

- For non-trivial changes, pause before presenting: *is there a more elegant way?*
- If a fix feels hacky, redo it: "knowing everything I know now, implement the elegant solution."
- Skip this entirely for simple, obvious fixes. Polishing a one-liner is over-engineering.
- Challenge your own work before the user has to.

## 7. Autonomous bug fixing

Given a bug report, a failing test, an error, or a red CI run: **just fix it.**

- No hand-holding requests. No "would you like me to investigate?"
- Point yourself at the logs, the stack trace, the failing assertion — then resolve them.
- Zero context switching required from the user.

## Core principles

- **Simplicity first** — make every change as simple as possible. Impact minimal code.
- **No laziness** — find root causes. No temporary fixes, no workarounds left in place.
  Senior-developer standards.
- **Minimal impact** — touch only what the task requires. Every changed line should trace back
  to the request. Avoid introducing bugs by avoiding unnecessary changes.
