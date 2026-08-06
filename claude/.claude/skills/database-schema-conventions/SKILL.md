---
name: database-schema-conventions
description: Locked schema rules for designing database tables and writing Laravel migrations — surrogate PKs, unsignedInteger references with no FK constraints, no JSON for queryable data, nullable datetimes instead of booleans, lookup tables instead of enums, mandatory timestamps with audit-trio column ordering, soft deletes, and the immutable-history carve-out. Use whenever creating or altering a table, writing or reviewing a migration, adding a column, designing a data model, or deciding how to store a status/flag/vocabulary/state. Also trigger on "new table", "add a column", "migration", "should this be an enum/boolean/JSON column", "schema review".
disable-model-invocation: true
---

# Database Schema Conventions

These rules are **locked**. They override framework defaults — including Laravel's own migration
idioms (`foreignId()`, `constrained()`, `morphs()`, `enum()`).

**When a case isn't covered here, ask before implementing. Do not guess, and do not fall back to
the framework default.** An uncovered case is a decision for the user to make, not for you to
infer.

---

## 0. The rules at a glance

| # | Rule | Short form |
|---|---|---|
| 1 | **Primary keys** use `id()` (`unsignedBigInteger`, auto-increment). | `$table->id()` |
| 2 | **Reference columns** are `unsignedInteger`. **No** foreign-key constraints, **no** cascade. | `$table->unsignedInteger('user_id')` |
| 3 | **No JSON** for data you'd ever query. JSON only for opaque/config payloads — **confirm first**. | normalize it |
| 4 | **No booleans** for state that *happens* — use a nullable datetime. Booleans allowed only for config/settings. | `cancelled_at`, not `is_cancelled` |
| 5 | **No enums.** Each fixed vocabulary becomes a lookup table, referenced by `_code` (or `_id` for true relations). | `status_code` → `order_statuses` |
| 6 | **Timestamps on every table** (`created_at`/`updated_at`). Only the §7 edge cases may omit them. | `$table->timestamps()` |
| 7 | **Only the audit trio** (`created_at`/`updated_at`/`deleted_at`) sits at the **end** of the table. Domain `_at` columns keep their logical position. | trio last |
| 8 | **Soft-delete** (`deleted_at`) everywhere it makes sense — **except** immutable history rows. | `$table->softDeletes()` |
| 9 | **Immutable history rows** are append-only: **no `updated_at`, no `deleted_at`.** | created/occurred only |

---

## 1. Identifiers & references (Rules 1–2)

- **Primary keys:** always `$table->id()` — the framework default `unsignedBigInteger`, auto-increment.
- **References:** always `$table->unsignedInteger('<name>_id')`. **Never** `foreignId()`,
  `constrained()`, `morphs()`, or `nullableMorphs()` — those imply bigint and/or FK constraints
  this convention does not use.
- **No FK constraints, no `onDelete`/`onUpdate` cascade.** Referential integrity is the
  **application's** job (model observers, service/action classes), never the database's.

> **Deliberate width mismatch.** A `user_id` is `unsignedInteger` (INT) while it references
> `users.id` (`unsignedBigInteger`/BIGINT). This is intentional. It is harmless on SQLite (all
> integers share one storage class) and the 4.2B INT ceiling is not a realistic concern for the
> kind of application these rules target. **Do not "fix" this by widening reference columns.**

**Polymorphic targets** are spelled out by hand (no `morphs()` helper):

```php
$table->string('attachable_type')->nullable();
$table->unsignedInteger('attachable_id')->nullable();
$table->index(['attachable_type', 'attachable_id']);
```

---

## 2. No JSON for queryable data (Rule 3)

JSON is allowed **only** as an opaque payload you never filter, join, or index into.

- ✅ **Allowed (config / non-queried):** a form field's `select`/`radio` choices, a rich-text
  editor's document body when you query a derived `plain_text` column instead, a rendered
  notification payload.
- ❌ **Not allowed (queryable data):** anything you'd `WHERE` / `JOIN` / aggregate on — attribute
  *values*, extracted entities, statuses, tags, counts. **Normalize these into columns or rows.**

**Every new JSON column must be confirmed with the user before it ships.** Default to normalizing;
if you believe a JSON column is warranted, say why and ask.

---

## 3. Datetime over boolean (Rule 4)

State that *occurs at a point in time* is a nullable datetime, not a boolean. Presence = true, and
the column also tells you *when*.

| Instead of… | Use… |
|---|---|
| `is_cancelled` | `cancelled_at` |
| `is_archived` | `archived_at` |
| `pinned` | `pinned_at` |
| `is_completed` | `completed_at` |
| `is_published` | `published_at` |
| `is_disabled` (on a lookup row) | `disabled_at` |

**Booleans are allowed only for genuine config/settings toggles** — a persistent on/off preference
with no meaningful "when" (e.g. `Setting.auto_analyze`, `notifications_enabled`). When in doubt,
prefer the datetime.

---

## 4. Lookup tables instead of enums (Rule 5)

Every fixed vocabulary is a **per-vocabulary table**, seeded, referenced by a stable **`_code`**.
Never `$table->enum()`, never a PHP enum backing a plain string column as the only source of truth.

- **Reference by `_code`** (e.g. `status_code = 'next'`) for vocabularies application logic
  *branches* on — codes are legible (`$order->status_code === 'shipped'`), greppable, and stable
  across reseeds where auto-increment ids are not.
- **Reference by `_id`** only for true relations to richer or user-managed entities (e.g.
  `category_id`, a target row in a graph table).

**One table per vocabulary** — not a single shared `lookups` table with a `group` column.

**Lookup table shape:**

```php
Schema::create('order_statuses', function (Blueprint $table) {
    $table->id();
    $table->string('code')->unique();            // 'pending', 'shipped', 'cancelled'
    $table->string('label');
    $table->unsignedInteger('position')->default(0);
    $table->dateTime('disabled_at')->nullable(); // retire a code without deleting it (Rule 4)
    $table->timestamps();
});
```

Lookups may carry their own vocabulary-specific columns where useful (a status can add a terminal
marker, a source an icon). They are **not** soft-deleted — retire a code via `disabled_at` so
existing rows referencing it stay resolvable.

---

## 5. Timestamps & column order (Rules 6–7)

- Every table gets `$table->timestamps()` unless it is an explicit §7 edge case.
- **Only the audit trio is written last,** in this order: `created_at`, `updated_at`, `deleted_at`
  (i.e. `timestamps()` then `softDeletes()`).
- **Domain datetimes keep their logical position** among the columns they belong with — do not
  sweep every `_at` column to the bottom.

```php
Schema::create('captures', function (Blueprint $table) {
    $table->id();                                   // Rule 1
    $table->unsignedInteger('user_id');             // Rule 2 — no constraint
    $table->text('content');
    $table->string('source_code');                  // Rule 5 → sources lookup
    $table->string('source_url')->nullable();
    $table->string('source_ref')->nullable();       // dedup key
    $table->string('status_code');                  // → capture_statuses lookup
    $table->string('attachable_type')->nullable();  // polymorphic, by hand (§1)
    $table->unsignedInteger('attachable_id')->nullable();
    $table->dateTime('captured_at');                // domain _at — logical position
    $table->dateTime('processed_at')->nullable();   // domain _at — logical position

    $table->index('source_ref');
    $table->index(['attachable_type', 'attachable_id']);

    $table->timestamps();                           // created_at, updated_at  ── trio
    $table->softDeletes();                          // deleted_at              ── last
});
```

---

## 6. Soft deletes (Rule 8)

Add `softDeletes()` to all plain mutable entities.

**Do not** soft-delete immutable history rows (§7) or seeded lookup tables (§4).

A table may legitimately carry **both** an `archived_at` (a domain *state*, Rule 4) and a
`deleted_at` (soft delete). They are different concepts — archiving is a user-visible state, soft
deleting is removal that stays recoverable. Do not collapse one into the other.

---

## 7. The immutable-history carve-out (Rule 9)

Append-only rows are **never updated and never deleted** — that is the entire point of an audit
trail. They break Rules 6 and 8 on purpose.

| Row kind | Temporal columns | No `updated_at` | No `deleted_at` |
|---|---|---|---|
| Event / audit-log rows | `occurred_at` only (`$timestamps = false`) | ✓ | ✓ |
| Immutable version rows (a new version = a new row) | `created_at` only | ✓ | ✓ |

```php
// an append-only event log — its own temporal column, NO framework timestamps
Schema::create('events', function (Blueprint $table) {
    $table->id();
    $table->unsignedInteger('subject_id');
    $table->string('subject_type')->nullable();
    $table->unsignedInteger('subject_version_id')->nullable(); // snapshot pointer
    $table->dateTime('occurred_at');                           // sole temporal column
    $table->index('subject_id');
});
// Model: public $timestamps = false;
```

```php
// an immutable version row — created_at ONLY (editing writes a NEW row, never an UPDATE)
Schema::create('page_versions', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    $table->text('body')->nullable();
    $table->timestamp('created_at')->nullable();   // no updated_at, no deleted_at
});
// Model: public const UPDATED_AT = null;  (and no SoftDeletes trait)
```

If you are unsure whether a table is immutable history, **ask** — the answer determines Rules 6
and 8 for that table and is expensive to reverse later.

---

## 8. New-table checklist

Run this before finalizing any migration:

1. PK = `$table->id()`.
2. Every reference = `unsignedInteger`, no constraint, no cascade.
3. Fixed vocabularies → a `_code` to a lookup table (never an enum).
4. State-that-happens → a `_at` datetime (not a boolean); booleans only for config toggles.
5. No JSON unless it's opaque config — and **confirmed with the user**.
6. Domain `_at` columns in logical position; **audit trio (`created_at`/`updated_at`/`deleted_at`) last.**
7. `timestamps()`; `softDeletes()` where it makes sense.
8. **Immutable history row?** → `created_at`/`occurred_at` only; no `updated_at`, no `deleted_at`.
9. Indexes on reference columns and on any polymorphic `(type, id)` pair you actually query.
10. Anything not covered here → **ask first.**

---

## 9. Reviewing an existing migration

When asked to review rather than write, report violations against the numbered rules above and
give the corrected line for each. Distinguish:

- **Violations in the change under review** — fix them.
- **Pre-existing violations in untouched code** — mention them, do not rewrite them unasked.
  Changing a shipped table's shape is a migration with data implications, which is the user's call.
