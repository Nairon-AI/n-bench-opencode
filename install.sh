#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${PROJECT:-$(pwd)}"

show_help() {
  cat <<EOF
N-bench OpenCode Installer

Usage: $0 [--project <path>]

Options:
  --project <path>  Target project directory (default: current directory)
  -h, --help        Show this help message

Examples:
  $0 --project ~/my-project
  PROJECT=~/my-project $0
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      TARGET="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  show_help
  exit 1
fi

install_to_project() {
  local dest="$TARGET/.opencode"
  mkdir -p "$dest"

  # Sync everything except config (preserve project-local settings)
  rsync -a --exclude "opencode.json" "$SCRIPT_DIR/.opencode/" "$dest/"

  # Copy default config only if none exists
  if [[ ! -f "$dest/opencode.json" && -f "$SCRIPT_DIR/.opencode/opencode.json" ]]; then
    cp "$SCRIPT_DIR/.opencode/opencode.json" "$dest/"
  fi

  echo "Installed N-bench to: $dest"
  echo ""
  echo "Next steps:"
  echo "  cd $TARGET"
  echo "  opencode"
  echo "  /nbench:setup"
}

install_to_project
