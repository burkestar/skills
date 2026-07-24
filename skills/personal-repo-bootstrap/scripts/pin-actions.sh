#!/usr/bin/env bash
# Resolve GitHub Actions tags to full commit SHAs for pinning in workflow files.
#
# Usage:
#   scripts/pin-actions.sh owner/repo@tag [owner/repo@tag ...]
#
# Prints one line per input in the form: owner/repo@<sha> # <tag>
# Paste that over the corresponding `uses:` line in the workflow.
#
# Requires: gh CLI, authenticated (`gh auth status`).

set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: $0 owner/repo@tag [owner/repo@tag ...]" >&2
  exit 1
fi

for spec in "$@"; do
  repo="${spec%@*}"
  tag="${spec#*@}"
  sha=$(gh api "repos/${repo}/commits/${tag}" --jq .sha)
  echo "${repo}@${sha} # ${tag}"
done
