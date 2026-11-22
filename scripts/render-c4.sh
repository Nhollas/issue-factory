#!/usr/bin/env bash
set -euo pipefail

out="$(cd "$(dirname "${BASH_SOURCE[0]}")/../docs/architecture" && pwd)"
workspace="$out/workspace.dsl"

structurizr-cli validate -w "$workspace"

rm -f "$out"/*.puml "$out"/*.svg

structurizr-cli export -w "$workspace" -f plantuml/c4plantuml -o "$out" >/dev/null

for f in "$out"/structurizr-*.puml; do
  mv "$f" "$out/$(basename "$f" | sed 's/^structurizr-//')"
done

plantuml -tsvg -nometadata "$out"/*.puml

for f in "$out"/*.svg; do
  printf '%s  %s bytes\n' "$(basename "$f")" "$(wc -c <"$f" | tr -d ' ')"
done
