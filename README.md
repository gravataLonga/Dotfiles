# Stow Files  

```shell
stow <folder>/
```

# Restow all files in one go... 

```shell
stow -R -v --no-folding */  
```
> Note: With -n it will simulate without real change. `--no-folding` will link files a not folder, for me this is importante.

# Package: zsh

The `.zshrc` here assumes three things exist on the machine. None of them live in
this repo, so a fresh machine gets a colourless prompt and errors on every login
until you install them:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install fzf
git clone https://github.com/JannoTjarks/catppuccin-zsh.git \
  ~/.oh-my-zsh/custom/themes/catppuccin-zsh
ln -s catppuccin-zsh/catppuccin.zsh-theme \
  ~/.oh-my-zsh/custom/themes/catppuccin.zsh-theme
```

Symptoms when each is missing:

| Missing | Error on login |
| --- | --- |
| catppuccin theme | `[oh-my-zsh] theme 'catppuccin' not found` |
| fzf | `.zshrc:NNN: command not found: fzf` |

The theme is a **clone plus a symlink**, so updating it is `git pull` in
`~/.oh-my-zsh/custom/themes/catppuccin-zsh`. It has to be that shape:

- oh-my-zsh only looks for `$ZSH_CUSTOM/themes/<name>.zsh-theme` — one level, no
  subfolders — so the clone alone is never found. Hence the symlink.
- The theme loads its palette with `source ${0:A:h}/catppuccin-flavors/...`. The
  `:A` modifier resolves symlinks, so `$0` lands in the clone and finds the
  flavors folder next to the real file. With `:a` (no resolution) this layout
  would break — that's the detail the whole thing rests on.
- `custom/` is in oh-my-zsh's own `.gitignore`, so the nested clone is invisible
  to it and an omz update won't touch or wipe the theme.

And `source <(fzf --zsh)` needs **fzf >= 0.48** — the `--zsh` flag doesn't exist
before that, and older distro packages still ship the standalone
`key-bindings.zsh` / `completion.zsh` files instead.

Machine-specific aliases go in `~/.config/sh/local.sh`, which `sh/.config/sh/alias.sh`
sources if present. It is deliberately not in this repo — that's the escape hatch
for things that shouldn't follow you to another machine.

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
