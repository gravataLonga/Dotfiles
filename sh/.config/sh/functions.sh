# PHPUnit
p() {
    if [[ -f artisan ]]; then
        php artisan test
    else
        ./vendor/bin/phpunit
    fi
}

pf() {
    if [[ -z $1 ]]; then
        echo "Usage: pf [method|class|file]"
        exit 1
    fi
    ./vendor/bin/phpunit --filter $1
}

nd() {
    mkdir -p "$1" && cd -P -- "$1"
}

phpstorm() {
    open -na "PhpStorm.app" --args "$@"
}

nvimconfig() {
    cd $HOME/.config/nvim/
    nvim .
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

# Create an worktree from within active worktree directory
ga() {
    if [[ -z $1 ]]; then
        echo "Usage: gw [branch name]"
        exit 1
    fi

    local branch=$1
    local base="$(basename "$PWD")"
    local path="../${base}--${branch}"

    /usr/bin/git worktree add -b "$branch" "$path"
    cd "$path"
}

# Remove worktree and branch from within active worktree directory
gd() {
    if gum confirm "Remove worktree and branch?"; then
        local cwd base branch root

        cwd="$(pwd)"
        worktree="$(basename "$cwd")"

        # split on first --
        root="${worktree%%--*}"
        branch="${worktree#*--}"

        # Protect against accidentially nuking a non-worktree directory
        if [[ $root != $worktree ]]; then
            cd "../$root"
            /usr/bin/git worktree remove "$worktree" --force
            /usr/bin/git branch -D "$branch"
        fi
    fi
}