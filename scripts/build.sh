#!/usr/bin/env sh
# Regenerates every file that carries the rule text from hemingway.md.
#   scripts/build.sh          write the derived files
#   scripts/build.sh --check  exit 1 if any derived file is out of date
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SRC="$ROOT/hemingway.md"
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/output-styles" "$TMP/rules" "$TMP/skills/hemingway"

# Claude Code output style. Forced on while the plugin is enabled.
{
cat <<'HEAD'
---
name: Hemingway
description: Short, plain replies with a closing line that names what was left out
keep-coding-instructions: true
force-for-plugin: true
---

HEAD
cat "$SRC"
} > "$TMP/output-styles/hemingway.md"

# Cursor rule. Always applied once installed.
{
cat <<'HEAD'
---
description: Hemingway style replies with a closing "Below the surface" line
alwaysApply: true
---

HEAD
cat "$SRC"
} > "$TMP/rules/hemingway.mdc"

# The style as a skill, for tools that install skills.
{
cat <<'HEAD'
---
name: hemingway
description: Reply in Hemingway style with an iceberg line. Short sentences, plain words, the answer first, and a closing "Below the surface:" line that names what was left out. Use when the user says "hemingway", "hemingway mode", "be brief", "plain English", "too long", "shorter", or complains about walls of text or jargon.
license: MIT
metadata:
  author: sinan
  version: "0.1"
---

HEAD
cat "$SRC"
} > "$TMP/skills/hemingway/SKILL.md"

# The rule block in the README.
awk -v src="$SRC" '
  /<!-- rules:start -->/ {
    print
    print "```text"
    while ((getline line < src) > 0) print line
    close(src)
    print "```"
    skip = 1
    next
  }
  /<!-- rules:end -->/ { skip = 0 }
  !skip { print }
' "$ROOT/README.md" > "$TMP/README.md"

FAIL=0
for f in output-styles/hemingway.md rules/hemingway.mdc skills/hemingway/SKILL.md README.md; do
  if [ "$CHECK" -eq 1 ]; then
    if cmp -s "$TMP/$f" "$ROOT/$f"; then
      echo "ok        $f"
    else
      echo "stale     $f"
      FAIL=1
    fi
  else
    cp "$TMP/$f" "$ROOT/$f"
    echo "wrote     $f"
  fi
done
exit "$FAIL"
