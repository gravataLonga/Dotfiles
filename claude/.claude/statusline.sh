#!/bin/bash
# Claude Code status line: model, directory, git branch, context, prompt cache, 5h limit.
# Claude Code pipes the session state as JSON on stdin and shows what this prints.

command -v jq >/dev/null || { echo "statusline: jq is not installed"; exit 0; }

IFS=$'\x1f' read -r model effort cwd ctx cache_seen cache_warm cache_expires cache_tokens limit < <(
  jq -r '[
    .model.display_name,
    .effort.level?,
    (.workspace.current_dir // .cwd),
    .context_window.used_percentage,
    .prompt_cache.caching_observed,
    .prompt_cache.warm,
    .prompt_cache.expires_at,
    .prompt_cache.recache_tokens_if_cold,
    .rate_limits.five_hour.used_percentage
  ] | map(if type == "number" then floor else . // "" end | tostring) | join("\u001f")'
)

reset=$'\033[0m' dim=$'\033[2m' bold=$'\033[1m'
red=$'\033[31m' green=$'\033[32m' yellow=$'\033[33m'
blue=$'\033[34m' magenta=$'\033[35m' cyan=$'\033[36m'

# Green, yellow or red as a percentage gets close to its limit.
level_color() {
  if   (( $1 >= 85 )); then printf '%s' "$red"
  elif (( $1 >= 60 )); then printf '%s' "$yellow"
  else                      printf '%s' "$green"
  fi
}

# 1234 -> 1k, 1234567 -> 1.2M
human() {
  if   (( $1 >= 1000000 )); then printf '%d.%dM' $(( $1 / 1000000 )) $(( $1 % 1000000 / 100000 ))
  elif (( $1 >= 1000 ));    then printf '%dk' $(( ($1 + 500) / 1000 ))
  else                           printf '%d' "$1"
  fi
}

segments=()

segments+=("${bold}${cyan}${model:-?}${reset}${effort:+ ${dim}${effort}${reset}}")

dir=$cwd
case "$dir" in "$HOME"*) dir="~${dir#$HOME}" ;; esac
segments+=("${blue}${dir}${reset}")

# Branch (or short sha when detached), * for uncommitted changes, ↑↓ against upstream.
if git_status=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  branch=$(awk '
    /^# branch.head / { head = $3 }
    /^# branch.oid /  { oid = substr($3, 1, 7) }
    /^# branch.ab /   { ahead = substr($3, 2) + 0; behind = substr($4, 2) + 0 }
    !/^#/             { dirty = 1 }
    END {
      if (head == "(detached)") head = oid
      printf "%s%s", head, dirty ? "*" : ""
      if (ahead)  printf " ↑%d", ahead
      if (behind) printf " ↓%d", behind
    }' <<<"$git_status")
  segments+=("${magenta}${branch}${reset}")
fi

# Context window as a 10-cell bar, plus the exact percentage.
ctx=${ctx:-0}
cells=$(( (ctx + 5) / 10 ))
full="" empty=""
for (( i = 0; i < 10; i++ )); do
  if (( i < cells )); then full+="█"; else empty+="░"; fi
done
ctx_color=$(level_color "$ctx")
segments+=("${dim}ctx${reset} ${ctx_color}${full}${reset}${dim}${empty}${reset} ${ctx_color}${ctx}%${reset}")

# Prompt cache: the tokens it holds (what a rebuild would cost) and the time until it
# expires. The countdown is worked out here so it keeps moving while the session idles.
if [ -z "$cache_seen" ]; then
  segments+=("${dim}cache –${reset}")
else
  left=$(( ${cache_expires:-0} - $(date +%s) ))
  if [ -z "$cache_warm" ] || (( left <= 0 )); then
    state="${red}cold${reset}"
  elif (( left < 60 )); then
    state="${yellow}<1m${reset}"
  elif (( left < 600 )); then
    state="${yellow}$(( left / 60 ))m${reset}"
  else
    state="${green}$(( left / 60 ))m${reset}"
  fi
  segments+=("${dim}cache${reset} $(human "${cache_tokens:-0}") ${state}")
fi

if [ -n "$limit" ]; then
  segments+=("${dim}5h${reset} $(level_color "$limit")${limit}%${reset}")
fi

sep=" ${dim}│${reset} "
line=""
for segment in "${segments[@]}"; do
  line+="${line:+$sep}${segment}"
done
printf '%s\n' "$line"
