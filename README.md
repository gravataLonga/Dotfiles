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

# Package: bin

Scripts in `~/.local/bin`, which `zsh/.zshrc` already puts on `PATH`.

```shell
mkdir -p ~/.local/bin && stow -R -v --no-folding bin
```

The `mkdir` matters: stow links at the highest level that doesn't exist yet, so
without it stow symlinks all of `~/.local` into this repo.

## mac-cleanup

Reclaims disk space from developer caches and stale app versions. **Dry run by
default** — nothing is deleted without `--apply`.

```shell
mac-cleanup              # list what would be freed
mac-cleanup --all        # same, including the optional groups
mac-cleanup --apply      # delete the safe group, with a confirmation
mac-cleanup --all --apply -y
```

The safe group only touches things that regenerate themselves: npm, Go, Gradle,
Homebrew, CocoaPods, Composer, Playwright and Electron caches, the simulator
dyld cache, JetBrains indexes belonging to uninstalled versions, and any iOS
simulator runtime that is not the newest. It finds the active Fusion 360 version
through the symlink in `webdeploy/production` and removes the rest.

The optional groups only run with their own flag or `--all`, because they either
mean re-downloading something big or losing app data: `--ollama`,
`--android-images`, `--claude-vm`, `--bambu-beta`, `--jetbrains-config`,
`--gradle-modules`, `--sim-devices`.

Three safeguards. Deletion is confined to a fixed list of prefixes
(`SAFE_PREFIXES`). Caches belonging to a running app are skipped rather than
pulled out from under it. And `force_rm` restores the write bit before retrying
a failed delete — content-addressed caches like dotslash leave their
directories read-only on purpose, which stops `rm` even though the files are
yours and sudo is not the answer.
