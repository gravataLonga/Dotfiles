
# Folders
alias Sites="cd $HOME/Sites"

# PHP Aliases
alias ar="php artisan"
alias c="composer"

# PHPUnit runner: p, pf and pstop are now the p() function in functions.sh
alias dep="vendor/bin/dep"

# Git
alias wip="git add . && git commit -m 'Work in progress'"
alias nope="git reset --hard && git clean -f -d && git checkout HEAD"

# macOS-only aliases and functions (Homebrew PHP binaries, Tailscale.app, PhpStorm/tmux-workspace helpers)
[[ "$(uname)" == "Darwin" ]] && [ -f $HOME/.config/sh/macos.sh ] && source $HOME/.config/sh/macos.sh

# Machine-specific, outside of git
[ -f $HOME/.config/sh/local.sh ] && source $HOME/.config/sh/local.sh
