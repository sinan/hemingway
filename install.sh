#!/usr/bin/env sh
# Puts the hemingway rules into the files your agents read at the start of every session.
#
#   ./install.sh                 claude, codex and gemini (the three home-directory files)
#   ./install.sh claude          one or more of: claude codex gemini cursor
#   ./install.sh cursor          copies rules/hemingway.mdc into ./.cursor/rules/ of the current directory
#   ./install.sh --remove        takes the block back out (combine with targets)
#
# The block sits between two HTML comment markers, so running this twice replaces it
# instead of adding a second copy.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RULES="$HERE/hemingway.md"
BEGIN='<!-- hemingway:start -->'
END='<!-- hemingway:end -->'
REMOVE=0
TARGETS=

for a in "$@"; do
  case "$a" in
    --remove) REMOVE=1 ;;
    claude|codex|gemini|cursor) TARGETS="$TARGETS $a" ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown target: $a (use claude, codex, gemini, cursor, --remove)" >&2; exit 1 ;;
  esac
done
[ -n "$TARGETS" ] || TARGETS="claude codex gemini"

trim_trailing_blank_lines() {
  content=$(cat "$1")
  if [ -n "$content" ]; then
    printf '%s\n' "$content" > "$1"
  else
    : > "$1"
  fi
}

strip_block() {
  [ -f "$1" ] || return 0
  grep -qF "$BEGIN" "$1" || return 0
  awk -v b="$BEGIN" -v e="$END" 'index($0, b) { skip = 1 } !skip { print } index($0, e) { skip = 0 }' "$1" > "$1.tmp"
  mv "$1.tmp" "$1"
  trim_trailing_blank_lines "$1"
}

add_block() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
  strip_block "$1"
  trim_trailing_blank_lines "$1"
  {
    if [ -s "$1" ]; then printf '\n'; fi
    printf '%s\n' "$BEGIN"
    cat "$RULES"
    printf '%s\n' "$END"
  } >> "$1"
}

for t in $TARGETS; do
  case "$t" in
    claude) f="$HOME/.claude/CLAUDE.md" ;;
    codex)  f="${CODEX_HOME:-$HOME/.codex}/AGENTS.md" ;;
    gemini) f="$HOME/.gemini/GEMINI.md" ;;
    cursor)
      if [ "$REMOVE" -eq 1 ]; then
        rm -f .cursor/rules/hemingway.mdc
        echo "cursor: removed .cursor/rules/hemingway.mdc"
      else
        mkdir -p .cursor/rules
        cp "$HERE/rules/hemingway.mdc" .cursor/rules/hemingway.mdc
        echo "cursor: wrote .cursor/rules/hemingway.mdc for this project"
        echo "        for every project, paste hemingway.md into Cursor Settings > Rules > User Rules"
      fi
      continue
      ;;
  esac
  if [ "$REMOVE" -eq 1 ]; then
    strip_block "$f"
    echo "$t: removed the block from $f"
  else
    add_block "$f"
    echo "$t: wrote the block to $f"
  fi
done
