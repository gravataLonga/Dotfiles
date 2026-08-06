---
name: recording-pattern
description: The Recording pattern — a Recording/Event/recordable versioning model where every edit writes a new immutable domain row and re-points a stable Recording id, giving full version history and an audit log without soft deletes or JSON blobs. Covers the schema (recordings, events, recordable tables), the three-step write dance, hierarchy via parent_id, restoring past versions, the record() query scope, and how to add a new recordable model.
disable-model-invocation: true
---

# Recording Pattern

## Overview

This pattern separates **what a record is** (domain data) from **where it lives in the system** (metadata and hierarchy). Every edit creates a new data row instead of mutating the existing one, giving full audit history without soft-deletes or JSON blobs.

| Model | Role |
|---|---|
| `Recording` | Metadata hub — owns hierarchy, authorship, and the pointer to the current data row |
| Recordable (e.g. `Bucket`) | Domain data — immutable rows, one per version |
| `Event` | Audit log — one timestamped row per create or update |

The Recording's ID is **stable forever**. Its `recordable_id` pointer moves each time the record is edited.

---

## Recordables in Second Brain (current set — revisit per entity)

The pattern is generic; **which** entities adopt it is a per-entity product decision, **not a frozen
rule** — an entity can start plain and be promoted to a recordable later. Current set:

| Recordable | Why history matters here |
|---|---|
| `Page` | Notion-style documents — version history + restore is core. |
| `Memory` | Structured records / vault — field-change history; see [DATABASE-CONVENTIONS.md](./DATABASE-CONVENTIONS.md) §9 (A3). |
| `Collection` | PARA buckets / GTD projects — track outcome/status/review changes over the project's life; hierarchy via `Recording.parent_id`. |
| `Proposal` | Approval-gated suggestions — audit of payload + decision across its lifecycle. |

Everything else is **plain Eloquent today** (`Capture`, `Task`, `Context`, `Tag`, `Bookmark`,
`Highlight`, `Setting`, `ApiToken`, …) — but nothing here is locked; revisit as needs emerge.

**Choose recordable when:** past versions are worth keeping/restoring; edits are meaningful audit
events; a stable identity must survive edits (tags/links/hierarchy point at it); or parent/child nesting
helps. **Stay plain when:** the entity is transient or high-churn (e.g. raw `Capture` inbox items), its
own datetime columns already capture the audit you need, or it's a simple lookup. The cost of recordable
is the three-step write dance, row growth, and querying via `Recording::record()` instead of directly.

---

## Database Schema

### `recordings`

| Column | Type | Notes |
|---|---|---|
| `id` | bigint PK | Stable identity — never changes |
| `recordable_type` | string (nullable) | Fully-qualified class name, e.g. `App\Models\Bucket` |
| `recordable_id` | bigint (nullable) | FK to the current row in the recordable's table |
| `parent_id` | bigint (nullable) | Self-referential FK for hierarchy (e.g. Movement → Bucket) |
| `user_id` | bigint (nullable) | The owning user |
| `created_by` | bigint (nullable) | Set automatically on create via model boot |
| `updated_by` | bigint (nullable) | Set automatically on every save via model boot |
| `created_at` / `updated_at` | timestamps | |

```php
Schema::create('recordings', function (Blueprint $table) {
    $table->id();
    $table->nullableMorphs('recordable');
    $table->foreignId('parent_id')->nullable();
    $table->foreignId('user_id')->nullable();
    $table->foreignId('created_by')->nullable();
    $table->foreignId('updated_by')->nullable();
    $table->timestamps();
});
```

### `events`

| Column | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `recording_id` | bigint | FK → `recordings.id` |
| `recordable_type` | string (nullable) | Snapshot of the recordable class at this event |
| `recordable_id` | bigint (nullable) | Snapshot of the recordable row at this event |
| `occurred_at` | timestamp | When the operation happened |

> `events` has **no Laravel timestamps** (`$timestamps = false`). All temporal context comes from `occurred_at`.

```php
Schema::create('events', function (Blueprint $table) {
    $table->id();
    $table->foreignId('recording_id');
    $table->nullableMorphs('recordable');
    $table->timestamp('occurred_at');
});
```

### Example recordable: `buckets`

| Column | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `name` | string | |
| `description` | text (nullable) | |
| `icon` | string (nullable) | |
| `colour` | string(7) (nullable) | Hex colour, e.g. `#44dd00` |
| `goal_amount` | decimal(12,2) unsigned (nullable) | |
| `goal_date` | date (nullable) | |
| `created_at` / `updated_at` | timestamps | |

---

## Models

### `Recording`

```php
class Recording extends Model
{
    protected $fillable = ['parent_id', 'user_id'];

    public static function booted(): void
    {
        static::creating(fn (Model $model) => $model->created_by = $model->updated_by = auth()->id());
        static::updating(fn (Model $model) => $model->updated_by = auth()->id());
    }

    // Current data row (polymorphic)
    public function recordable(): MorphTo

    // Child recordings (e.g. Movements under a Bucket)
    public function children(): HasMany  // self-referential via parent_id

    // Full audit log for this recording
    public function events(): HasMany

    #[Scope]
    protected function record(Builder $builder, string $recordable, ?int $parentId = null): void
    {
        $builder->whereMorphedTo('recordable', $recordable)
            ->with('recordable')
            ->when($parentId, fn ($q) => $q->where('parent_id', $parentId));
    }

    // Delegates attribute access to the wrapped entity
    public function attr(string $key, mixed $default = null): mixed
    // $recording->attr('name')
    // $recording->attr('goal_amount', 0)  // with fallback

    public function isRecordable(string $recordableClass): bool
}
```

### `Event`

```php
class Event extends Model
{
    public $timestamps = false;

    protected $fillable = ['recording_id', 'occurred_at'];
    protected $casts = ['occurred_at' => 'datetime'];

    public function recording(): BelongsTo  // → Recording
    public function recordable(): MorphTo   // → the entity snapshot at this event
}
```

### `Bucket` (example recordable)

```php
class Bucket extends Model
{
    protected $fillable = ['name', 'description', 'icon', 'colour', 'goal_amount', 'goal_date'];

    // The single Recording currently pointing to this row
    public function recording(): MorphOne

    // All Events that have ever pointed to this row
    public function events(): MorphMany
}
```

---

## How It Works

### Creating a record

Three steps always required:

```php
// 1. Create the domain data row
$bucket = Bucket::create([
    'name'        => $name,
    'description' => $description,
    'goal_amount' => $goalAmount,
    'goal_date'   => $goalDate,
]);

// 2. Create its Recording
$recording = $bucket->recording()->create();

// 3. Log the Event
$bucket->events()->create([
    'recording_id' => $recording->id,
    'occurred_at'  => now(),
]);
```

After this:
- `recordings.recordable_type` = `App\Models\Bucket`, `recordable_id` = the bucket's id
- `events.recordable_type` = `App\Models\Bucket`, `recordable_id` = same bucket id

### Updating a record (immutable edit)

**Never** call `$bucket->update()`. Create a new row and re-point the Recording:

```php
// 1. Create a new data row with the updated values
$newBucket = Bucket::create(['name' => $newName, 'goal_amount' => $newGoal]);

// 2. Re-point the existing Recording
$recording->recordable()->associate($newBucket)->save();

// 3. Log the update Event
$newBucket->events()->create([
    'recording_id' => $recording->id,
    'occurred_at'  => now(),
]);
```

The old `Bucket` row remains in the database forever as audit history.

### Creating a child recording (hierarchy)

Child recordings set `parent_id` to the parent Recording's `id`:

```php
$movement = Movement::create(['amount' => $amount, 'notes' => $notes]);

$movement->recording()->create([
    'parent_id' => $bucketRecording->id,
]);
```

### Restoring a past version

Use the Event's snapshot pointer to roll the Recording back:

```php
$recording->recordable_id = $event->recordable_id;
$recording->save();
$recording->refresh(); // reload the recordable relation in-place
```

---

## Querying

Use the `record` scope — never filter on `recordable_type` manually:

```php
// All current Bucket recordings
Recording::record(Bucket::class)->get();

// All child recordings (e.g. Movements) under a specific Bucket recording
Recording::record(Movement::class, $bucketRecording->id)->get();
```

The scope eager-loads `recordable` automatically.

### Aggregating child totals

```php
Recording::record(Bucket::class)
    ->leftJoin('recordings as child_recordings', function ($join) {
        $join->on('child_recordings.parent_id', '=', 'recordings.id')
             ->where('child_recordings.recordable_type', Movement::class);
    })
    ->leftJoin('movements', 'movements.id', '=', 'child_recordings.recordable_id')
    ->select('recordings.*')
    ->selectRaw('COALESCE(SUM(movements.amount), 0) as total_amount')
    ->groupBy('recordings.id')
    ->with('recordable')
    ->get();
```

### Querying the audit log

```php
Event::where('recording_id', $recording->id)
    ->with('recordable')
    ->orderBy('occurred_at', 'desc')
    ->get();

// Or via the relationship
$recording->events()->with('recordable')->orderByDesc('occurred_at')->get();
```

---

## Rules Summary

1. **Recordables are immutable** — create a new row for every edit, never update or delete.
2. **Recording is the source of truth** for what a logical record currently points to.
3. **Always log an Event** after every create or update.
4. **Use `Recording::record(ClassName::class)`** to query — never filter `recordable_type` manually.
5. **Use `parent_id` on Recording** (not on the recordable) to express hierarchy.
6. **Pass a `::class` constant** to `record()` and `isRecordable()`, never a plain string.
7. **Use `refresh()`** after restoring a past version — it reloads relations in-place on the same instance.

---

## Adding a New Recordable Model

1. Create the model and migration (domain columns only — no `parent_id`, no `user_id`).
2. Add the two relationships to the model:

```php
public function recording(): MorphOne
{
    return $this->morphOne(Recording::class, 'recordable');
}

public function events(): MorphMany
{
    return $this->morphMany(Event::class, 'recordable');
}
```

3. Follow the three-step pattern (recordable → recording → event) everywhere the model is persisted.

---

## Relationship Map

```
recordings
 ├── id (stable identity)
 ├── recordable_type / recordable_id  →  Bucket (or any recordable)
 ├── parent_id  →  recordings.id (e.g. Movement's recording → Bucket's recording)
 └── user_id, created_by, updated_by, timestamps

events
 ├── recording_id  →  recordings.id
 ├── recordable_type / recordable_id  →  Bucket row at the time of the event
 └── occurred_at

buckets / movements / ...
 └── recording()  morphOne  →  recordings
 └── events()     morphMany →  events
```

---

## Why This Pattern

| Concern | How the pattern addresses it |
|---|---|
| **Stable identity across edits** | Recording ID never changes; only `recordable_id` is updated |
| **Full version history** | Every edit creates a new domain row + an Event; old versions remain queryable |
| **Parent-child composition** | `parent_id` on Recording links children to their parent without any FK on the domain models |
| **Generic aggregation** | The `record()` scope works identically for any recordable type |
| **Authorship audit** | `created_by` / `updated_by` are set automatically via model boot hooks |

---

## Differences Between Projects

The two reference implementations diverge in several ways relevant to a new project:

| Detail | `our-richer-life-old` | `our-rich-life` (canonical) |
|---|---|---|
| UI layer | Livewire components | Controllers |
| `recordings` morphs | `morphs()` — NOT NULL | `nullableMorphs()` — nullable |
| `recordings` soft deletes | Yes — `deleted_by`, `deleted_at` via `metadata()` macro | No |
| `Recording.events()` | Not defined | `HasMany(Event::class)` ✓ |
| `Bucket.events()` | `MorphOne` (single-result, incorrect) | `MorphMany` ✓ |
| `Bucket` columns | `name`, `goal` (int, Money cast) | `name`, `description`, `icon`, `colour`, `goal_amount`, `goal_date` |
| `Bucket.timestamps` | `false` | Default (`true`) |
| Recovery method | `$recording->fresh(['recordable'])` — **bug**: return value not captured | `$recording->refresh()` ✓ |
| Snapshot movements | Implemented | Not yet implemented |

The canonical implementation above reflects `our-rich-life`.
