#!/usr/bin/env bash
# PreToolUse/Bash hook: refuse any commit or PR that carries Claude attribution.
# Backstop for the `attribution` setting, which stops Claude Code from appending
# the trailers itself. This catches a message typed by hand into -m or a heredoc.
#
# Scans the raw stdin payload rather than parsing JSON: this machine has no jq,
# and the marker strings contain no quotes/newlines/backslashes, so JSON escaping
# leaves them intact. Keeps the hook dependency-free.
set -uo pipefail

lc=$(cat | tr '[:upper:]' '[:lower:]')

# 1. Is an attribution marker present at all? Cheapest check, so do it first.
case "$lc" in
  *"co-authored-by: claude"*|*"co-authored-by:claude"*|\
  *"generated with claude code"*|*"generated with [claude code]"*|\
  *"noreply@anthropic.com"*|*"claude.com/claude-code"*) ;;
  *) exit 0 ;;
esac

# 2. Does a command segment actually INVOKE git/gh, or is the text merely
#    mentioned (writing a file that documents this policy, grepping for it)?
#    Split on shell separators plus the literal \n escapes from the JSON, then
#    require some segment to START with git/gh. A prose line describing a commit
#    does not start with git, so documenting the rule stays allowed.
#    The JSON wrapper prefixes the command, so break at "command":" too --
#    otherwise the command text never begins a segment.
segments=$(printf '%s' "$lc" | sed -e 's/"command":"/\
/g' -e 's/\\n/\
/g' | tr ';|&' '\n')

invokes_git=0
while IFS= read -r seg; do
  seg="${seg#"${seg%%[![:space:]]*}"}"   # strip leading whitespace
  case "$seg" in
    git\ *commit*|gh\ *pr\ create*) invokes_git=1; break ;;
  esac
done <<EOF
$segments
EOF

[ "$invokes_git" -eq 1 ] || exit 0

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked: this command carries Claude attribution (Co-Authored-By / Generated with Claude Code). Policy for this repo (see CLAUDE.md) is that Claude never appears in commit history. Remove the attribution trailer from the message and retry."}}
JSON
exit 0
