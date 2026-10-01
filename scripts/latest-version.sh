#!/usr/bin/env bash
# Prints the newest stable upstream release tag (X.Y.Z or vX.Y.Z; pre-releases are ignored).
set -euo pipefail
upstream="${UPSTREAM_REPO:-https://framagit.org/kaihuri/mobilizon.git}"

git ls-remote --tags --refs "$upstream" \
  | sed 's|.*refs/tags/||' \
  | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' \
  | sort -V \
  | tail -n1
