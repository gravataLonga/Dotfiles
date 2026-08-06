---
name: explain-topic
description: Explain how any part of this project works, in clear and simple terms, grounded in the actual code (not generic docs). Covers configuration, architecture, flows, a class/service, a feature, a convention — anything in the repo. Use whenever the user asks to "explain how X works", "how do I configure X", "document how X is set up", "what does X do", or wants a developer-facing explanation of any project subsystem (filesystem/Flysystem, container/DI, auth/AudienceSettings, routes, SqlFx/DB, cron, MCP, exporters, models, middleware, etc.). Also trigger on "/explain-topic" and phrasings like "explica como funciona", "como configuro", "faz uma explicação de".
disable-model-invocation: true
---

# Explain Topic

Produce a clear, code-grounded explanation of how some part of this project works. The topic
can be anything: a configuration, an architecture flow, a class or service, a feature, a
convention. The explanation must reflect the **real code** in this repo (read it first), not
generic library documentation.

## Workflow

### 1. Get the topic

The topic comes from the user. If they didn't give one, ask what they want explained.

### 2. Investigate the code FIRST

Before writing anything, find and read the actual implementation:
- Prefer the MCP server (`developer-mcp-tools`) for structural questions (routes, handlers).
- Grep/read the relevant config (`config/`), container bindings (`config/container/dependencies.php`),
  and source (`App/`, `src/`).
- Ground every claim, file path, and code snippet in what you actually read. Never invent
  config keys, env vars, class names, or line numbers.

### 3. Ask the framing questions (mandatory)

Use the `AskUserQuestion` tool to collect these BEFORE writing the explanation. Ask the
questions in English. Skip a question only if the user already answered it in their request.

1. **Final format** — Where does the explanation go?
   - `Chat` — written directly in the conversation
   - `File in docs/` — an `.md` file under `docs/`
   - `Email` — formatted as an email (greeting, body, sign-off)
   - `PDF` — a generated PDF document (use the `generate-pdf` skill to produce it)
   - `Other` — ask for details

2. **Length** — How extensive should it be?
   - `Short` — just the essentials, a few lines
   - `Medium` — balanced: what it is + how it works + how to use/configure + common pitfalls
   - `Long` — thorough: full walkthrough, edge cases, references

3. **Extras** — Does the user want any of these? (multi-select)
   - `Introduction` — a short intro framing the topic
   - `Conclusion` — a closing summary
   - `Additional note` — an extra note / warning / tip section

4. **Language** — only if not already known from context:
   - Language (PT / ES / EN / other).

5. **Audience / technical depth** — who is this for? Calibrate vocabulary, assumed
   background, and how deep the explanation goes:
   - `Junior dev` — explain fundamentals, spell out jargon, more hand-holding
   - `Senior dev` — assume strong technical background, go deep, skip the basics
   - `Product owner` — focus on behavior and impact, minimal code, plain language
   - `Research / deep-dive` — exhaustive, precise, edge cases and internals
   - `Other` — ask for details

### 4. Write the explanation

Respect the answers and these defaults:

- **Natural, human voice.** The output must read like a thoughtful colleague wrote it by
  hand, not like AI-generated copy. Vary sentence length, write plainly, avoid robotic
  boilerplate, marketing fluff, and tell-tale AI phrasing ("In conclusion", "It's important
  to note that", "Let's dive in", over-hedging, padded transitions). Get to the point.
- **On-topic only.** Explain exactly what was asked. Do not drag in adjacent subsystems
  the user didn't ask about.
- **Concise.** Fewer words, no filler. Match the chosen length.
- **Structure:** short sections + code blocks. A common spine is *What it is → How it works →
  How to use / configure → Common errors → References*, but adapt freely to the topic
  (a flow explanation, a class walkthrough, and a config guide look different).
- Include `Introduction` / `Conclusion` / `Additional note` sections only if the user asked
  for them.

### 5. Format rules per destination

- **Chat:** NEVER use markdown tables (they render poorly in the terminal) — use bullet
  lists instead. Keep it scannable.
- **File in docs/:** create the `.md` under `docs/` (e.g. `docs/<area>/<topic>.md`).
  Tables are fine here. Tell the user the path when done.
- **Email:** include greeting + body + sign-off; plain, paste-ready text.
- **PDF:** write the explanation as Markdown, then invoke the `generate-pdf` skill to render
  it into a PDF. Tell the user where the file was saved.

### 6. References

End with a short "References" list mapping each claim to its source file (and approx line),
so the reader can verify against the code.

## Notes

- The explanation language is whatever the user requested, independent of the chat language
  and of the question language (which is always English).
- This skill explains and documents; it does not change application code.
