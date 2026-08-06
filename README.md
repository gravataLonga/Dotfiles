# Stow Files  

```shell
stow <folder>/
```

# Restow all files in one go... 

```shell
stow -R -v --no-folding */  
```
> Note: With -n it will simulate without real change. `--no-folding` will link files a not folder, for me this is importante.

# Package: claude

Claude Code skills. On any machine, one line:

```shell
mkdir -p ~/.claude/skills && stow -R -v claude
```

The `mkdir` is the whole trick, so don't drop it. Stow links at the highest level
that doesn't exist yet, so plain `stow claude` on a fresh machine (no `~/.claude`)
symlinks `~/.claude` **itself** into this repo, and every session, history and
cache file Claude Code writes ends up in your dotfiles. Creating the two
directories first pins the links one level deeper — `~/.claude/skills/<name>`
-> this repo — which keeps `~/.claude` writable, lets a machine keep its own
unshared skills, and picks up extra files inside a skill without a restow.

Skills must be **flat**: `~/.claude/skills/<name>/SKILL.md`, filename exactly
`SKILL.md`. Subfolders are silently never loaded (`skills/productivity/handoff/`
loads nothing). The directory name is the command you type (`commit/` ->
`/commit`); frontmatter `name` is only a display label, so keep it equal to the
directory name.
