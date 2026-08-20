# macOS-only aliases and functions: Homebrew PHP binaries, Tailscale.app,
# PhpStorm launcher, tmux-workspace helper. Sourced only on Darwin, from alias.sh.

# EDIT PHP INIT
alias pini74-xdebug="sudo nano /opt/homebrew/etc/php/7.4/conf.d/20-xdebug.ini"

# PHP Version Binaries
alias php74="/opt/homebrew/Cellar/php@7.4/7.4.33_9/bin/php"
alias php81="/opt/homebrew/Cellar/php@8.1/8.1.32_1/bin/php"
alias php82="/opt/homebrew/Cellar/php@8.2/8.2.28_1/bin/php"
alias php83="/opt/homebrew/Cellar/php@8.3/8.3.30/bin/php"
alias php84="/opt/homebrew/Cellar/php@8.4/8.4.20/bin/php"

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Dev & Workflow
alias ealias="phpstorm $HOME/.config/sh"

phpstorm() {
    open -na "PhpStorm.app" --args "$@"
}

workspace() {
    # if 0 parameters are passed then we pass to fzf
    if [[ $# -eq 0 ]]; then
        local start=$(ls "/Users/jfontes/.config/tmux-workspace" | fzf)
        local tmuxWorkspace="/Users/jfontes/.config/tmux-workspace/$start"
        sh $tmuxWorkspace
        return 0
    fi
    # List all workspace exists
    if [[ $1 != "" && $1 == "ls" ]]; then
        ls -la "/Users/jfontes/.config/tmux-workspace"
        return 0
    fi
    # Create a new workspace
    if [[ $1 != "" && $1 == "create" && $2 != "" ]]; then
        local path="/Users/jfontes/.config/tmux-workspace/$2"
        if [[ -f $path ]]; then
            echo "Workspace already exists!"
            return 1
        fi
        /usr/bin/touch $path
        /opt/homebrew/bin/nvim $path
        return 0
    fi
    local workspace="/Users/jfontes/.config/tmux-workspace/$@"
    if ! [ -f $workspace ]; then
        echo "Workspace not found $workspace"
        return 1
    fi
    sh $workspace
}
