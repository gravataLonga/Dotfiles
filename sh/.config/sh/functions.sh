# PHPUnit runner: `p` alone runs the suite, `p Name` filters, flags pass through.
# Uses `php artisan test` when artisan exists, `vendor/bin/phpunit` otherwise.
# Usage:
#   p                                  run the full suite
#   p UserTest                         filter by class/method (shorthand for --filter)
#   p --stop-on-defect                 stop at the first failure
#   p --filter Foo --stop-on-defect    flags combine and pass straight through
p() {
    if [[ -n $1 && $1 != -* ]]; then
        set -- --filter "$1" "${@:2}"
    fi

    if [[ -f artisan ]]; then
        php artisan test "$@"
    elif [[ -f ./vendor/bin/phpunit ]]; then
        ./vendor/bin/phpunit "$@"
    else
        echo "No artisan or vendor/bin/phpunit found in $(pwd)." >&2
        return 1
    fi
}

nd() {
    mkdir -p "$1" && cd -P -- "$1"
}

nvimconfig() {
    cd $HOME/.config/nvim/
    nvim .
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

    # Git takes the slash in feature/list-athletes as part of the name, the
    # filesystem takes it as a folder. Without this the worktree lands in
    # ../base--feature/list-athletes.
    local slug="${branch//\//-}"

    # Never name this one `path`: in zsh that is the array tied to $PATH, and a
    # local one leaves the function with nothing on its PATH but this folder.
    local worktree_path="../${base}--${slug}"

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

        # The folder name has the slashes of the branch replaced by dashes, so
        # it no longer spells the branch. Only git knows the real name.
        branch="$(/usr/bin/git rev-parse --abbrev-ref HEAD 2> /dev/null)"

        # Protect against accidentially nuking a non-worktree directory
        if [[ $root != $worktree ]]; then
            cd "../$root"
            /usr/bin/git worktree remove "$worktree" --force

            # Detached HEAD reports itself as HEAD: there is no branch to drop.
            if [[ -n $branch && $branch != HEAD ]]; then
                /usr/bin/git branch -D "$branch"
            fi
        fi
    fi
}

cl() { IS_SANDBOX=1 claude --continue --dangerously-skip-permissions "$@"; }

