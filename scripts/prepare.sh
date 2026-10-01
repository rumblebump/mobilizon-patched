#!/usr/bin/env bash
# Checks out an upstream release tag into a directory and applies patches/*.patch in order.
# Usage: scripts/prepare.sh <tag> <dir>
set -euo pipefail
tag="$1"
dir="$2"
upstream="${UPSTREAM_REPO:-https://framagit.org/kaihuri/mobilizon.git}"
patches="$(cd "$(dirname "$0")/.." && pwd)/patches"

git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$tag" "$upstream" "$dir"

shopt -s nullglob
for patch in "$patches"/*.patch; do
  echo "Applying $(basename "$patch")"
  git -C "$dir" apply --whitespace=nowarn "$patch"
done
