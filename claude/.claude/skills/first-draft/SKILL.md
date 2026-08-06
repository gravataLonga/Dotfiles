---
name: first-draft
description: Interview the user to produce the first-draft scope document (docs/PRD.md) for a brand-new project. Use when starting a project from scratch and there is no spec yet — "vamos arrancar um projecto novo", "ajuda-me a delinear o primeiro draft", "preciso de um PRD", "/first-draft". Stops at the document; writes no application code.
argument-hint: "Uma frase sobre o projecto (opcional)"
disable-model-invocation: true
---

# First Draft

Conduct an interview that turns a vague project idea into **one** short, dense scope
document: `docs/PRD.md`.

**Hard boundary: this skill produces a document and nothing else.** No installing
frameworks, no migrations, no scaffolding, no code of any kind — not even "just to
illustrate". If the user asks for code mid-interview, note it and offer to do it in a
separate turn after the document exists.

## Language

Conduct the interview in **Portuguese**. Write `docs/PRD.md` in **English**.

## Workflow

### 1. Recon — current folder only

Before the first question, inspect the working directory: files present, existing
`docs/`, README, package manifests, git history if any. Do **not** go looking at sibling
or parent projects — the skill stays portable and the user's disk is not fair game.

Open with a 3–5 line summary of what you found, so the user sees the ground you are
standing on. If the folder is empty, say so plainly and move on.

If `docs/PRD.md` already exists, stop and read it. Do not overwrite. Ask whether to
update it (interviewing only around its gaps and TODOs) or to start over.

If the user passed an argument, treat it as their one-line pitch and use it to seed the
first question instead of asking them to repeat it.

### 2. The interview

Walk this spine in order, **one question at a time**, waiting for the answer before
continuing. Never batch questions — it is bewildering and produces shallow answers.

Every question carries **your recommended answer**, with the reasoning compressed to a
sentence. Recommend; don't survey. Branch with follow-ups when an answer opens a real
decision, but cap it at roughly two follow-ups per topic — this is a scoping interview,
not an inquisition.

Anything you can answer by reading the folder, read the folder instead of asking.

**The spine:**

1. **Problema** — what pain, whose, and how it is handled today without this thing.
2. **Utilizadores e papéis** — who logs in, and for each role what they can see and do.
   Permissions belong here, in product language ("o treinador vê só os seus atletas"),
   never in technical terms (policies, gates, middleware). Permissions shape the data
   model, so this must be settled before topic 7.
3. **Critérios de sucesso** — how the user will know v1 was worth building. A metric, a
   signal, or plainly "o X deixou de fazer isto à mão".
4. **Âmbito do v1** — the short list of what exists in v1.
5. **Não-âmbito** — what is deliberately left out. Push for this; a PRD without an
   explicit out-of-scope list has no edges.
6. **Percursos principais** — 2 to 3 end-to-end flows, in numbered steps.
7. **Modelo de dados** — entities, relationships, key fields.
8. **Integrações e dependências** — what comes from outside: other systems, APIs,
   imported data, third-party services.
9. **Não-funcionais** — only where a real constraint exists: data volume, performance,
   mobile, i18n, offline, accessibility. If none bites, record "none" and move on rather
   than manufacturing requirements.
10. **Riscos e incógnitas** — what could make this fail.
11. **Faseamento** — the order things get built, and why that order.

**Deliberately out of the interview:** technology stack and technical auth mechanics.
Those are decided later, in a separate conversation. If the user volunteers a stack, note
it in one line under Phasing and do not interrogate it.

### 3. When the user doesn't know

If the answer is "não sei" or "tanto faz", **do not invent one and do not push**. Leave
an explicit hole: write `**TODO:** <the open question, phrased as a question>` in place,
inside the section it belongs to. A document honest about its gaps beats one padded with
assumptions that read like decisions.

### 4. Write the document

Write `docs/PRD.md` (create `docs/` if needed).

**Target ~2 pages.** Each section fits on one screen. Data model as a table. Journeys as
numbered steps. The rule: if a sentence would not change an implementation decision, cut
it.

State decisions flatly. Add a single line of justification **only** where a real
alternative was on the table during the interview — enough that nobody relitigates it in
a month. Everywhere else, no rationale.

Structure:

```markdown
# <Project> — PRD

## Problem
## Users & roles
## Success criteria
## In scope (v1)
## Out of scope
## Key journeys
## Data model
## Integrations & dependencies
## Non-functional requirements
## Risks & unknowns
## Phasing
```

Entity and field names in English throughout, since that is how they will exist in code.
Keep any `**TODO:**` markers inline, in their own sections — no separate open-questions
section at the end.

### 5. Stop

Report, in Portuguese:

- the file path
- a 3–4 line summary of what the document says
- the list of every `**TODO:**` still open

Then stop. Propose no next step, create no tasks, write no code. The user decides what
happens next with a clear head.
