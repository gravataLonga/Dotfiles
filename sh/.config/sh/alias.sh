
# Folders
alias Sites="cd $HOME/Sites"

# PHP Aliases
alias ar="php artisan"
alias c="composer"

# PHPUNIT
# p e pf são funções em functions.sh
alias dep="vendor/bin/dep"
alias pstop="./vendor/bin/phpunit --stop-on-defect"

# EDIT PHP INIT
alias pini74-xdebug="sudo nano /opt/homebrew/etc/php/7.4/conf.d/20-xdebug.ini"

# PHP Version Binaries
alias php74="/opt/homebrew/Cellar/php@7.4/7.4.33_9/bin/php"
alias php81="/opt/homebrew/Cellar/php@8.1/8.1.32_1/bin/php"
alias php82="/opt/homebrew/Cellar/php@8.2/8.2.28_1/bin/php"
alias php83="/opt/homebrew/Cellar/php@8.3/8.3.30/bin/php"
alias php84="/opt/homebrew/Cellar/php@8.4/8.4.20/bin/php"

# Git
alias wip="git add . && git commit -m 'Work in progress'"
alias nope="git reset --hard && git clean -f -d && git checkout HEAD"

# SSH
alias connect_ccsdev="ssh jfontes@ccsdev -L 3307:127.0.0.1:3306 -N &"

# Dev & Workflow
alias ealias="phpstorm $HOME/.config/sh"

# Tailscake
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
