#!/usr/bin/env bash
# write_role_files.sh <slug>
#
# Reads the role-onboarder's generation output from stdin and writes each
# delimited block to .claude/catch-me/roles/<slug>/<filename>. Also updates
# .claude/catch-me/active-role.json to point at this slug.
#
# Expected stdin format (blocks can appear in any order):
#
#   ===== BEGIN meta.json =====
#   { ... }
#   ===== END meta.json =====
#   ===== BEGIN persona.md =====
#   ...
#   ===== END persona.md =====
#   ... (lexicon, signaling, anti-patterns, monday, project-playbook)
#
# Run from the project root.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <slug>" >&2
  exit 2
fi

SLUG="$1"

if [[ ! "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: slug must be kebab-case (got: '$SLUG')" >&2
  exit 2
fi

PROJECT_ROOT="$(pwd)"
ROLES_DIR="$PROJECT_ROOT/.claude/catch-me/roles"
ROLE_DIR="$ROLES_DIR/$SLUG"
ACTIVE_FILE="$PROJECT_ROOT/.claude/catch-me/active-role.json"
REQUIRED_FILES=(meta.json persona.md lexicon.md signaling.md anti-patterns.md monday.md project-playbook.md)

mkdir -p "$ROLE_DIR"

# Write to a tempdir first so a parse failure can't leave a partial role behind.
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# Split stdin into one file per block using awk.
awk -v outdir="$TMPDIR" '
  /^===== BEGIN [^ ]+ =====$/ {
    fname = $3
    path = outdir "/" fname
    capturing = 1
    next
  }
  /^===== END [^ ]+ =====$/ {
    capturing = 0
    close(path)
    next
  }
  capturing == 1 {
    print > path
  }
' <&0

# Verify all required files were produced.
missing=()
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$TMPDIR/$f" ]]; then
    missing+=("$f")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "error: generation output missing blocks: ${missing[*]}" >&2
  exit 1
fi

# Move all files into the role directory atomically (per-file).
for f in "${REQUIRED_FILES[@]}"; do
  mv "$TMPDIR/$f" "$ROLE_DIR/$f"
done

# Update active-role pointer.
ACTIVATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat > "$ACTIVE_FILE" <<EOF
{
  "slug": "$SLUG",
  "activated_at": "$ACTIVATED_AT"
}
EOF

echo "wrote: $ROLE_DIR"
echo "active-role: $SLUG"
