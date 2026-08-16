# PHPUnit
p() {
    if [[ -f artisan ]]; then
        php artisan test
    else
        ./vendor/bin/phpunit
    fi
}

pt() {
    if ! [[ -f "./vendor/bin/phpunit" ]]; then
        echo "phpunit not found. Ensure run composer install and require phpunit in your project."
        exit 1;
    fi
    ./vendor/bin/phpunit
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
        echo "Usage: ga [branch name]"
        return 1
    fi

    local branch=$1
    local base="$(basename "$PWD")"
    local source_env="$PWD/.env"

    # Never name this one `path`: in zsh that is the array tied to $PATH, and a
    # local one leaves the function with nothing on its PATH but this folder.
    local worktree_path="../${base}--${branch}"

    /usr/bin/git worktree add -b "$branch" "$worktree_path"
    cd "$worktree_path" || return 1

    local dir="$(basename "$PWD")"

    if [[ -f composer.json ]]; then
        echo ">>> Running composer install..."
        /opt/homebrew/bin/php /usr/local/bin/composer install
    fi

    # The .env of the worktree we came from, when there is one: it already has
    # the credentials .env.example only names. APP_URL and the database are
    # fixed further down, everything else is meant to be shared.
    if [[ -f $source_env ]]; then
        echo ">>> Copying .env from ${base}..."
        /bin/cp "$source_env" .env
    elif [[ -f .env.example ]]; then
        echo ">>> Copying .env.example to .env..."
        /bin/cp .env.example .env
    fi

    if [[ -f artisan ]]; then
        echo ">>> Running php artisan key:generate..."
        /opt/homebrew/bin/php artisan key:generate

        echo ">>> Linking storage..."
        /opt/homebrew/bin/php artisan storage:link
    fi

    # Valet serves this directory under its own .test host, but the copied
    # .env still points at the site we branched from. Signed URLs and the links
    # that go out by e-mail break quietly until this matches.
    if [[ -f .env ]] && command -v valet > /dev/null; then
        echo ">>> Pointing APP_URL to http://${dir}.test..."
        /usr/bin/sed -i '' "s|^APP_URL=.*|APP_URL=http://${dir}.test|" .env
    fi

    # A worktree sharing the database of the one it came from is a worktree
    # whose first migration breaks the other branch. One database each.
    local has_own_database=0

    if [[ -f .env ]] && /usr/bin/grep -q '^DB_CONNECTION=sqlite' .env; then
        local sqlite_file="$(/usr/bin/sed -n 's/^DB_DATABASE=//p' .env)"

        # Without DB_DATABASE, Laravel falls back to database_path(), which
        # already resolves inside this worktree. With it, the path is usually
        # absolute and still names the file of the worktree we copied from.
        if [[ -n $sqlite_file ]]; then
            sqlite_file="${PWD}/database/$(basename "$sqlite_file")"
            /usr/bin/sed -i '' "s|^DB_DATABASE=.*|DB_DATABASE=${sqlite_file}|" .env
        else
            sqlite_file="database/database.sqlite"
        fi

        echo ">>> Creating the SQLite database..."
        /usr/bin/touch "$sqlite_file"
        has_own_database=1
    elif [[ -f .env ]] && /usr/bin/grep -q '^DB_CONNECTION=mysql' .env && command -v mysql > /dev/null; then
        local db="${dir//[^a-zA-Z0-9_]/_}"
        local db_user="$(/usr/bin/sed -n 's/^DB_USERNAME=//p' .env)"
        local db_pass="$(/usr/bin/sed -n 's/^DB_PASSWORD=//p' .env)"
        local db_host="$(/usr/bin/sed -n 's/^DB_HOST=//p' .env)"
        local db_port="$(/usr/bin/sed -n 's/^DB_PORT=//p' .env)"

        echo ">>> Creating the MySQL database ${db}..."
        if [[ -n $db_pass ]]; then
            mysql -h "${db_host:-127.0.0.1}" -P "${db_port:-3306}" -u "${db_user:-root}" -p"$db_pass" -e "CREATE DATABASE IF NOT EXISTS \`${db}\`"
        else
            mysql -h "${db_host:-127.0.0.1}" -P "${db_port:-3306}" -u "${db_user:-root}" -e "CREATE DATABASE IF NOT EXISTS \`${db}\`"
        fi

        if /usr/bin/grep -q '^DB_DATABASE=' .env; then
            /usr/bin/sed -i '' "s|^DB_DATABASE=.*|DB_DATABASE=${db}|" .env
        else
            echo "DB_DATABASE=${db}" >> .env
        fi

        has_own_database=1
    fi

    # Without a database of its own, migrating would run over the one the .env
    # was copied from. Better to stop and say so.
    if [[ -f artisan ]] && (( has_own_database )); then
        echo ">>> Running migrations..."
        /opt/homebrew/bin/php artisan migrate --seed
    elif [[ -f artisan ]]; then
        echo ">>> Skipping migrations: no separate database, .env still points at the original one."
    fi

    if [[ -f package.json ]]; then
        # npm arrives through nvm, which is not loaded in every shell.
        if ! command -v npm > /dev/null && [[ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; then
            source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
        fi

        echo ">>> Running npm install..."
        npm install

        echo ">>> Building assets..."
        npm run build
    fi
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

cl() { IS_SANDBOX=1 claude --continue --dangerously-skip-permissions "$@"; }

