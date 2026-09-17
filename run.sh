#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

GODOT=""
for cmd in godot godot4 godot-4.7 Godot; do
  if command -v "$cmd" >/dev/null 2>&1; then
    GODOT="$cmd"
    break
  fi
done

if [ -z "$GODOT" ]; then
  for path in "$HOME/.local/bin/godot" "/usr/local/bin/godot" "/opt/Godot/Godot"; do
    if [ -x "$path" ]; then
      GODOT="$path"
      break
    fi
  done
fi

if [ -z "$GODOT" ]; then
  echo "Errore: Godot 4.7 non trovato. Installalo o aggiungilo al PATH." >&2
  exit 1
fi

exec "$GODOT" --path . "$@"
