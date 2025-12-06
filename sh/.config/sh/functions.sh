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
