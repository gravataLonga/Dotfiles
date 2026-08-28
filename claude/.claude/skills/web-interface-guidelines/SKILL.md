---
name: web-interface-guidelines
description: Framework-agnostic checklist for reviewing UI code — accessibility, focus states, forms, animation, typography, content handling, images, performance, URL state, touch, safe areas, dark mode, i18n, server rendering, hover states, copy, and anti-patterns. Rules are stated in platform terms (HTML/CSS/DOM) and map onto JSX, templates, single-file components, or plain markup. Use whenever reviewing or writing interface code, or on "review this UI", "check accessibility", "is this component accessible", "a11y review", "UI review", "frontend review", "check this against the web interface guidelines".
---

# Web Interface Guidelines

Review interface code against the rules below.

**Scope:** the files or pattern given when the skill was invoked. If none were given, review the
files currently under discussion, or the working tree changes if there is no clearer target.

Read the files, check against the rules, report findings. Output concise but comprehensive —
sacrifice grammar for brevity. High signal-to-noise.

Rules are stated in platform terms (HTML/CSS/DOM). Map them onto whatever the file actually uses:
template syntax, JSX, single-file components, server-rendered markup, utility classes, CSS-in-JS.
Flag the underlying defect, not the syntax.

## Rules

### Accessibility
- Icon-only buttons need an accessible name (`aria-label` or visually-hidden text)
- Form controls need an associated `<label>` or accessible name
- Interactive elements need keyboard activation, not just pointer events
- `<button>` for actions, `<a>` for navigation (or the framework's link component)
- Images need `alt` (or `alt=""` if decorative)
- Decorative icons need `aria-hidden="true"`
- Async updates (toasts, validation) need a live region (`aria-live="polite"`)
- Use semantic HTML (`<button>`, `<a>`, `<label>`, `<table>`) before ARIA
- Headings hierarchical `<h1>`–`<h6>`; include skip link for main content
- `scroll-margin-top` on heading anchors
- Meaningful media needs captions, transcripts, or descriptions as applicable
- Media controls need keyboard support; decorative media needs assistive-tech hiding

### Focus States
- Interactive elements need a visible focus indicator
- Never remove `outline` without a focus replacement
- Use `:focus-visible` over `:focus` (avoid focus ring on click)
- Group focus with `:focus-within` for compound controls
- Sticky headers/footers/overlays must not cover the focused element

### Forms
- Inputs need `autocomplete` and a meaningful `name`
- Use correct `type` (`email`, `tel`, `url`, `number`) and `inputmode`
- Never block paste (paste handler + `preventDefault`)
- Labels clickable (`for` attribute or label wrapping the control)
- Disable spellcheck on emails, codes, usernames (`spellcheck="false"`)
- Checkboxes/radios: label + control share single hit target (no dead zones)
- Submit button stays enabled until request starts; spinner during request
- Errors inline next to fields; focus first error on submit
- Placeholders end with `…` and show example pattern
- `autocomplete="off"` on non-auth fields to avoid password manager triggers
- Warn before navigation with unsaved changes (`beforeunload` or router guard)

### Animation
- Honor `prefers-reduced-motion` (provide reduced variant or disable)
- Animate `transform`/`opacity` only (compositor-friendly)
- Never `transition: all` — list properties explicitly
- Set correct `transform-origin`
- SVG: transforms on `<g>` wrapper with `transform-box: fill-box; transform-origin: center`
- Animations interruptible — respond to user input mid-animation
- Autoplay motion >5 seconds alongside other content needs pause, stop, or hide controls
- Muted decorative loops must stop under `prefers-reduced-motion`

### Typography
- `…` not `...`
- Curly quotes `“` `”` not straight `"`
- Non-breaking spaces: `10&nbsp;MB`, `⌘&nbsp;K`, brand names
- Loading states end with `…`: `"Loading…"`, `"Saving…"`
- `font-variant-numeric: tabular-nums` for number columns/comparisons
- `text-wrap: balance` / `text-wrap: pretty` on headings (prevents widows)

### Content Handling
- Text containers handle long content: truncation, line clamping, or `overflow-wrap: break-word`
- Flex children need `min-width: 0` to allow text truncation
- Handle empty states — don't render broken UI for empty strings/arrays
- User-generated content: anticipate short, average, and very long inputs

### Images
- `<img>` needs explicit `width` and `height` (prevents CLS)
- Below-fold images: `loading="lazy"`
- Above-fold critical images: `fetchpriority="high"` (or framework equivalent)

### Performance
- Large lists (>50 items): virtualize, or `content-visibility: auto`
- No layout reads during render (`getBoundingClientRect`, `offsetHeight`, `offsetWidth`, `scrollTop`)
- Batch DOM reads/writes; avoid interleaving
- Prefer uncontrolled inputs; controlled inputs must be cheap per keystroke
- Add `<link rel="preconnect">` for CDN/asset domains
- Critical fonts: `<link rel="preload" as="font">` with `font-display: swap`
- Prefer `<video autoplay muted loop playsinline>` over animated GIF; provide a still alternative
- Short non-essential loops: Safari H.264 MP4 `<picture>` source, `prefers-reduced-motion` media
  condition, and still fallback

### Navigation & State
- URL reflects state — filters, tabs, pagination, expanded panels in query params
- Links are real links (Cmd/Ctrl+click, middle-click support)
- Deep-link all stateful UI (local component state that outlives an interaction usually belongs in
  the URL)
- Destructive actions need confirmation modal or undo window — never immediate

### Touch & Interaction
- `touch-action: manipulation` (prevents double-tap zoom delay)
- `-webkit-tap-highlight-color` set intentionally
- `overscroll-behavior: contain` in modals/drawers/sheets
- During drag: disable text selection, `inert` on dragged elements
- Drag/swipe/pinch/path gestures need tap/click and keyboard alternatives unless essential
- Autofocus sparingly — desktop only, single primary input; avoid on mobile

### Safe Areas & Layout
- Full-bleed layouts need `env(safe-area-inset-*)` for notches
- Avoid unwanted scrollbars: constrain horizontal overflow, fix content overflow
- Flex/grid over JS measurement for layout

### Dark Mode & Theming
- `color-scheme: dark` on `<html>` for dark themes (fixes scrollbar, inputs)
- `<meta name="theme-color">` matches page background
- Native `<select>`: explicit `background-color` and `color` (Windows dark mode)

### Locale & i18n
- Dates/times: use `Intl.DateTimeFormat` not hardcoded formats
- Numbers/currency: use `Intl.NumberFormat` not hardcoded formats
- Detect language via `Accept-Language` / `navigator.languages`, not IP
- Brand names, code tokens, identifiers: wrap with `translate="no"` to prevent garbled
  auto-translation

### Server Rendering & Hydration
Skip this section if the page isn't server-rendered.

- Inputs with a bound `value` need a change handler (or use an uncontrolled default)
- Date/time, locale, and random values: guard against server/client mismatch
- Hydration-warning suppression only where truly needed

### Hover & Interactive States
- Buttons/links need a hover state (visual feedback)
- Interactive states increase contrast: hover/active/focus more prominent than rest

### Content & Copy
- Active voice: "Install the CLI" not "The CLI will be installed"
- Title Case for headings/buttons (Chicago style)
- Numerals for counts: "8 deployments" not "eight"
- Specific button labels: "Save API Key" not "Continue"
- Error messages include fix/next step, not just problem
- Second person; avoid first person
- `&` over "and" where space-constrained

### Anti-patterns (flag these)
- `user-scalable=no` or `maximum-scale=1` disabling zoom
- Paste handler calling `preventDefault`
- `transition: all`
- Removed `outline` without focus-visible replacement
- Click handler navigation without a real link
- Non-interactive element (`<div>`, `<span>`) with a click handler
- Images without dimensions
- Large lists rendered without virtualization
- Form inputs without labels
- Icon buttons without an accessible name
- Hardcoded date/number formats (use `Intl.*`)
- Autofocus without clear justification
- Animated GIF when compressed video is suitable
- Gesture-only action without tap/click and keyboard alternative

## Output Format

Group by file. Use `file:line` format (clickable in editors). Terse findings.

```text
## src/components/button

src/components/button:42 - icon button missing accessible name
src/components/button:18 - input lacks label
src/components/button:55 - animation missing prefers-reduced-motion
src/components/button:67 - transition: all → list properties

## src/components/modal

src/components/modal:12 - missing overscroll-behavior: contain
src/components/modal:34 - "..." → "…"

## src/components/card

✓ pass
```

State issue + location. Skip explanation unless fix non-obvious. No preamble.
