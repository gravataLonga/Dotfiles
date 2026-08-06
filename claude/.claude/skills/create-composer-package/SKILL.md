---
name: create-composer-package
description: Scaffold a new Composer (PHP) library following PSR standards, security-first defaults, and modern testing setup. Use when the user asks to create, bootstrap, scaffold, or initialize a Composer package, PHP library, or vendor package; or asks for "composer.json best practices", "how do I publish a Composer package", PSR-4 setup, or wants to convert existing PHP code into a distributable package. Covers composer.json metadata, autoload split, dependency hygiene, .gitattributes/dist hygiene, secret handling, PSR HTTP/Log abstractions, PHPUnit strict configuration, semantic versioning, and Packagist vs VCS distribution.
disable-model-invocation: true
---

# Create a Composer Package (PHP)

A guide for scaffolding a high-quality, secure, distributable Composer package. Follow the steps in order. Each step has a **Verify** check — do not move on until it passes.

## 0. Clarify before scaffolding

Before writing any file, confirm with the user:

1. **Vendor and package name** — `vendor/package` (lowercase, dashes). e.g. `acme/payments-client`.
2. **Root namespace** — PSR-4 root. e.g. `Acme\PaymentsClient`.
3. **Package type** — `library` (default), `symfony-bundle`, `magento2-module`, `composer-plugin`, etc.
4. **Minimum PHP version** — be honest. `^8.2`, `^8.3`, `^8.4`. Don't claim `^7.4` "just in case" — it forces you to avoid modern features and increases attack surface from unpatched runtimes.
5. **Distribution target** — Packagist (public), private Packagist, Satis, or VCS repository (`type: vcs`)?
6. **License** — `MIT`, `Apache-2.0`, `BSD-3-Clause`, `proprietary`. Required for Packagist.

If the user is unsure, recommend defaults and call them out: `library` / current stable PHP / `MIT` / Packagist.

---

## 1. Directory layout

Use this structure. **Do not** put source in the package root.

```
.
├── .github/workflows/ci.yml      # if using GitHub
├── .gitattributes                # MUST exist — controls `composer install` payload
├── .gitignore
├── composer.json
├── phpunit.xml                   # or phpunit.xml.dist
├── phpstan.neon.dist             # optional but recommended
├── README.md
├── CHANGELOG.md                  # Keep-a-Changelog format
├── LICENSE
├── src/                          # production code only
│   └── <RootNamespace>/...
└── tests/                        # PHPUnit tests, excluded from dist
    └── ...
```

**Why no `src/` files in root:** keeps autoload deterministic, makes `.gitattributes export-ignore` simpler, and matches every modern PSR-4 package on Packagist.

---

## 2. `composer.json`

Use this template, replacing placeholders. Order of keys matters for readability — keep this order.

```json
{
    "name": "vendor/package-name",
    "description": "One-sentence description, no trailing period, no marketing fluff.",
    "type": "library",
    "license": "MIT",
    "keywords": ["concise", "search", "terms"],
    "homepage": "https://github.com/vendor/package-name",
    "authors": [
        {
            "name": "Author Name",
            "email": "author@example.com",
            "role": "Maintainer"
        }
    ],
    "support": {
        "issues": "https://github.com/vendor/package-name/issues",
        "source": "https://github.com/vendor/package-name"
    },
    "require": {
        "php": "^8.3",
        "ext-json": "*"
    },
    "require-dev": {
        "phpunit/phpunit": "^11.0",
        "phpstan/phpstan": "^1.11",
        "friendsofphp/php-cs-fixer": "^3.0"
    },
    "autoload": {
        "psr-4": {
            "Vendor\\PackageName\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Vendor\\PackageName\\Tests\\": "tests/"
        }
    },
    "scripts": {
        "test": "phpunit",
        "stan": "phpstan analyse",
        "cs": "php-cs-fixer fix --dry-run --diff",
        "cs-fix": "php-cs-fixer fix"
    },
    "config": {
        "sort-packages": true,
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "allow-plugins": {}
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
```

### Rules

- **Always** declare `php` and required `ext-*` constraints in `require`. Skipping ext constraints breaks consumers at runtime, not install time.
- **`require` vs `require-dev`:** any package only used by `tests/`, `phpunit.xml`, or CI tooling goes in `require-dev`. Common mistake: putting `phpunit`, `mockery`, `faker`, code-formatters in `require`. This forces every downstream consumer to install them.
- **Depend on interfaces, not implementations.** Require `psr/http-client` (interface) in `require`; put `guzzlehttp/guzzle` (implementation) in `require-dev` for tests. Let consumers pick the impl.
- **Version constraints:** use caret `^X.Y` for stable libs. Avoid `*` or `>=X` — they let breaking changes silently slip in and make `composer.lock` resolution non-reproducible.
- **`allow-plugins`:** Composer 2.2+ requires explicit allowlisting. Set `{}` initially; add entries only as needed and only for plugins you've audited.
- **No `minimum-stability: dev`** unless you have a concrete reason. It opens the door to unstable transitive deps.

**Verify:** `composer validate --strict` returns no errors and no warnings.

---

## 3. `.gitattributes` — dist hygiene (security + size)

When a user runs `composer require you/pkg`, Composer downloads the *dist* archive built from your git repo. By default that includes tests, CI configs, fixtures, and dotfiles — bloating installs and **leaking internal paths, test credentials, and tooling versions**.

Create `.gitattributes`:

```gitattributes
# https://git-scm.com/docs/gitattributes
/.github          export-ignore
/.gitattributes   export-ignore
/.gitignore       export-ignore
/.editorconfig    export-ignore
/tests            export-ignore
/docs             export-ignore
/phpunit.xml      export-ignore
/phpunit.xml.dist export-ignore
/phpstan.neon     export-ignore
/phpstan.neon.dist export-ignore
/.php-cs-fixer.php export-ignore
/.php-cs-fixer.dist.php export-ignore
/Makefile         export-ignore
/CHANGELOG.md     export-ignore
```

Keep `README.md` and `LICENSE` in the dist — consumers and license scanners need them.

**Verify:** run `git archive --format=tar HEAD | tar -t` and confirm tests/dotfiles are absent.

---

## 4. `.gitignore`

```gitignore
/vendor/
/composer.lock
/.phpunit.cache/
/.phpunit.result.cache
/.php-cs-fixer.cache
/.phpstan.cache/
/.idea/
/.vscode/
.DS_Store
```

**Libraries should NOT commit `composer.lock`.** Lock files are for applications (reproducible deploys). For libraries, committing `composer.lock` only locks *your* dev env, not consumers' — and CI should test against the *resolved* range so you catch breakage in your declared constraints.

(Applications and end products are the opposite — they MUST commit `composer.lock`.)

---

## 5. PHP code conventions

Apply these defaults to every `.php` file under `src/`:

1. **`declare(strict_types=1);`** as the first statement after `<?php`.
2. **`final class`** by default. Open for extension only when you've designed for it (template methods, documented hooks). Inheritance is a public API contract — hard to remove later.
3. **Constructor property promotion** with explicit visibility (`private`, `protected`, `public`).
4. **Readonly properties / readonly classes** (PHP 8.2+) for value objects. Prefer immutability — return modified clones via `withFoo()` instead of mutating.
5. **Type every parameter and return.** Use union/intersection/nullable types. Avoid `mixed` and untyped arrays — prefer DTOs, enums, or `array<string, Foo>` PHPDoc when arrays are necessary.
6. **No `static` state.** Statics are global mutable state — they break tests, prevent multiple instances, and complicate concurrency.
7. **Throw typed exceptions.** Define a package-level `MyPackageException` interface (marker) and named exceptions extending `\RuntimeException` or `\InvalidArgumentException` that implement it. Consumers can then `catch (MyPackageException $e)` to catch only your errors.
8. **Depend on PSR interfaces, not concrete libs.** Common ones:
   - PSR-3 `psr/log` — `LoggerInterface` for logging
   - PSR-7/17/18 `psr/http-message`, `psr/http-factory`, `psr/http-client` — HTTP
   - PSR-11 `psr/container` — DI containers
   - PSR-16 `psr/simple-cache` — caching
9. **Constructor injection only.** No service locators, no `Container::get()` inside classes.

---

## 6. Security — required practices

Composer packages are a **supply-chain attack surface**. Apply all of these.

### 6.1 Secret handling

- **Mark credential parameters with `#[\SensitiveParameter]`** (PHP 8.2+). This redacts them from stack traces.
  ```php
  public function __construct(
      private string $endpoint,
      #[\SensitiveParameter] private string $apiKey,
      #[\SensitiveParameter] private string $apiSecret,
  ) {}
  ```
- **Override `__serialize` / `jsonSerialize` / `__toString` / `__debugInfo`** on classes that hold secrets so dumps and serialization redact them.
  ```php
  public function __serialize(): array {
      return [...$publicFields, 'apiSecret' => '***'];
  }
  ```
- **Redact secrets in logs.** When logging request payloads, replace credentials with `*****` before passing to the logger. Never assume the consumer's log sink is private.
- **No hardcoded credentials.** Not in source, not in tests, not in fixtures. Use env vars and skip tests cleanly when not set:
  ```php
  protected function setUp(): void {
      if (!getenv('ACME_API_KEY')) {
          $this->markTestSkipped('Integration credentials not configured');
      }
  }
  ```

### 6.2 Input validation

- Validate constructor inputs at the boundary. Throw `InvalidArgumentException` (or your typed equivalent) immediately on bad input — don't let it propagate to surprise the caller later.
- For URLs: `filter_var($url, FILTER_VALIDATE_URL)`.
- For XML: pass `LIBXML_NONET` and avoid loading external entities. If parsing untrusted XML, disable entity loading explicitly (PHP 8+ has `LIBXML_NOENT` off by default, but be explicit). Never use `simplexml_load_string` on untrusted input without `LIBXML_NONET`.
- Avoid `unserialize()` on untrusted data — it's a known RCE vector. Use JSON. If you must accept serialized PHP, pass `['allowed_classes' => false]` or an explicit allowlist.

### 6.3 Dependency hygiene

- **Run `composer audit` in CI.** This checks installed deps against the [FriendsOfPHP security advisories DB](https://github.com/FriendsOfPHP/security-advisories) and fails on known CVEs. Add to every CI workflow.
- **Pin `allow-plugins` explicitly.** Composer plugins can run arbitrary code at install time. Only enable plugins you trust.
- **Use `composer require --dev` (not `composer require`)** for testing/linting tools. Mistakes here ship junk to every consumer.
- **Review `composer outdated --direct`** before each release. Stale transitive deps may carry vulns.
- **Avoid abandoned packages.** Composer warns on these — treat the warning as a release blocker.

### 6.4 Cryptography

- Use `random_bytes()` / `random_int()` for any security-sensitive randomness. **Never** `rand()`, `mt_rand()`, or `uniqid()`.
- Use `hash_equals()` for comparing secrets/tokens (timing-safe).
- Use `password_hash()` / `password_verify()` for password storage — never roll your own.
- For symmetric encryption use `sodium_*` (libsodium, bundled in PHP 7.2+). Don't use `mcrypt` (removed) or hand-rolled OpenSSL.

### 6.5 Network calls

- **Always set timeouts** on HTTP clients (connect + total). Default Guzzle has no total timeout — a hung peer hangs your caller forever.
- **Verify TLS.** Never set `verify => false` in shipped code. If a consumer needs to disable it for testing, they can configure their own client (this is why you depend on `psr/http-client`, not Guzzle directly).
- **Don't follow redirects blindly** for authenticated requests — a malicious redirect can leak credentials to attacker-controlled hosts.

---

## 7. Testing setup (PHPUnit)

`phpunit.xml.dist` — strict by default. Strict configs catch bugs at CI time instead of production.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         cacheDirectory=".phpunit.cache"
         executionOrder="depends,defects"
         requireCoverageMetadata="true"
         beStrictAboutCoverageMetadata="true"
         beStrictAboutOutputDuringTests="true"
         displayDetailsOnPhpunitDeprecations="true"
         failOnPhpunitDeprecation="true"
         failOnRisky="true"
         failOnWarning="true"
         colors="true">
    <testsuites>
        <testsuite name="default">
            <directory>tests</directory>
        </testsuite>
    </testsuites>
    <source ignoreIndirectDeprecations="true" restrictNotices="true" restrictWarnings="true">
        <include>
            <directory>src</directory>
        </include>
    </source>
</phpunit>
```

**Test conventions:**
- One test class per production class. `tests/` mirrors `src/` structure.
- Use `#[CoversClass(Foo::class)]` attribute on each test class.
- Provide an `AbstractTestCase` only if multiple tests genuinely share setup. Don't preemptively abstract.
- Use real instances of value objects in tests; mock only at I/O boundaries (HTTP client, DB, filesystem, clock).

**Verify:** `vendor/bin/phpunit` runs green with 0 risky, 0 warnings, 0 deprecations.

---

## 8. Static analysis & style

Strongly recommend adding:

- **PHPStan** at level 8 or 9, or **Psalm** at level 1 — catches type errors `phpunit` can't.
- **PHP-CS-Fixer** or **PHP_CodeSniffer** with PSR-12 ruleset — consistent style.

```yaml
# phpstan.neon.dist
parameters:
    level: 9
    paths:
        - src
    treatPhpDocTypesAsCertain: false
```

Wire them into `composer.json` scripts so contributors run them with one command.

---

## 9. CI (GitHub Actions example)

`.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        php: ['8.3', '8.4']
        dependencies: ['lowest', 'highest']
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          coverage: xdebug
      - run: composer validate --strict
      - run: composer update --prefer-${{ matrix.dependencies }} --no-progress
      - run: composer audit
      - run: vendor/bin/phpunit
      - run: vendor/bin/phpstan analyse
```

**Why matrix:** test the *full range* of your declared `php` constraint and your declared dep range (`lowest` catches "I added a `^8.1` feature but my constraint says `^8.0`" type bugs).

---

## 10. Versioning & release

- **Semantic Versioning** strictly. `MAJOR.MINOR.PATCH`.
  - MAJOR: backwards-incompatible. Any public API removal, signature change, behavior change.
  - MINOR: new backwards-compatible features.
  - PATCH: bug fixes only.
- **Public API surface** = anything not marked `@internal` in PHPDoc *and* not in a namespace named `Internal`. Document the boundary.
- **Tag releases with `v` prefix or without** — be consistent. Composer accepts both. Pick one.
- **Maintain `CHANGELOG.md`** using [Keep a Changelog](https://keepachangelog.com/) format. Update it *in the same PR* as the change, not at release time.
- **Use `branch-alias`** in `composer.json` only if you support multiple major versions in parallel.

---

## 11. Distribution

### Public — Packagist
1. Push to a public GitHub/GitLab repo.
2. Submit the repo URL at https://packagist.org/packages/submit.
3. Enable the GitHub webhook (Packagist guides you through it) so new tags publish automatically.

### Private — VCS repository
Consumers add to their `composer.json`:
```json
{
    "repositories": [
        { "type": "vcs", "url": "git@github.com:vendor/package.git" }
    ],
    "require": { "vendor/package": "^1.0" }
}
```
For private repos, consumers must have SSH or token access. Document this in the README.

### Private — Satis / Private Packagist
For an org with many private packages, run Satis (self-hosted) or use Private Packagist (paid). Avoids per-consumer `repositories` config sprawl.

---

## 12. README — required sections

A README is the package's UX. Bad README = unused package. Required sections, in order:

1. **Title + one-line description** matching `composer.json`.
2. **Badges** (CI status, latest version, downloads, license) — optional but expected.
3. **Requirements** — PHP version, extensions, external services.
4. **Installation** — exact `composer require` command. For VCS, include the `repositories` block.
5. **Quick start** — minimum viable example, copy-pasteable, working.
6. **Configuration** — every option, its default, and what it does.
7. **Usage** — common scenarios with code.
8. **Testing** — how a contributor runs the suite.
9. **Security** — a `SECURITY.md` link or inline statement on how to report vulnerabilities (private email, not a public issue).
10. **License**.

---

## 13. Final checklist

Run through every item before tagging `v1.0.0`:

- [ ] `composer validate --strict` clean
- [ ] `composer audit` clean
- [ ] `vendor/bin/phpunit` green, 0 risky / warnings / deprecations
- [ ] Static analyser at max level, clean
- [ ] `git archive HEAD | tar -t` — no tests, no dotfiles, no CI configs in dist
- [ ] No secrets in repo (`git log -p | grep -iE 'password|secret|token|api[_-]?key'` — manual review)
- [ ] `LICENSE` file present and matches `composer.json`
- [ ] `README.md` covers all 10 required sections
- [ ] `CHANGELOG.md` lists changes for this version
- [ ] `require-dev` does not contain anything `src/` imports
- [ ] PHP version constraint matches what CI actually tests
- [ ] Public API surface documented; internal classes marked `@internal`
- [ ] `SECURITY.md` exists with reporting contact

---

## Anti-patterns to refuse

If the user asks for any of the following, push back and explain why:

- **"Just put everything in `src/` at the root namespace."** — Breaks PSR-4 and bloats autoload.
- **"Skip the tests, I'll add them later."** — They never get added. Scaffold an empty `tests/` with one sanity test so the habit exists.
- **"Make it work with PHP 7."** — EOL since 2022, unpatched security holes. Only do this if there's a concrete deployment target stuck on it.
- **"Put Guzzle in `require` so consumers don't have to."** — Forces a transitive dep choice on every consumer. Use PSR-18 instead.
- **"Commit the `vendor/` directory."** — Defeats Composer's purpose, balloons the repo, and ships unaudited code on every clone.
- **"Disable TLS verification, it's easier."** — Never. Fix the cert chain or use a custom CA bundle.
- **"Use `eval()` / `unserialize()` on user input for flexibility."** — RCE waiting to happen.

---

## Quick reference: minimal viable package

The smallest correct package is 6 files:

```
composer.json       # § 2
.gitattributes      # § 3
.gitignore          # § 4
README.md           # § 12
LICENSE
src/<Namespace>/<Class>.php   # § 5
```

Everything else is recommended, but those six are the floor.
