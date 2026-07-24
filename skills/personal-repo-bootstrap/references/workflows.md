# GitHub Actions workflows

Every `uses:` below must resolve to a full commit SHA with a trailing version comment before this is committed - never leave a bare tag like `@v4`. Check each action's GitHub releases page for its current tag first (the versions below are examples, not guaranteed current), then resolve with `scripts/pin-actions.sh`, e.g.:

```bash
scripts/pin-actions.sh \
  actions/checkout@v4.2.2 \
  astral-sh/setup-uv@v5.2.1 \
  actions/setup-go@v5.2.0 \
  actions/setup-node@v4.1.0 \
  pre-commit/action@v3.0.1 \
  gitleaks/gitleaks-action@v2.3.6 \
  trufflesecurity/trufflehog@v3.83.7
```

Each line prints `owner/repo@<sha> # <tag>` - paste that over the matching `@<PLACEHOLDER_SHA> # ...` below. Dependabot (configured in `references/repo-settings.md`) recognizes the `@<sha> # vX.Y.Z` format and keeps these current afterward.

## `.github/workflows/ci.yml`

Runs pre-commit (lint, format, static analysis, secrets, tests, coverage) on every push and PR. Keep only the `setup-*`/toolchain steps for languages this repo actually uses.

```yaml
name: ci

on:
  push:
    branches: ["**"]
  pull_request:

permissions:
  contents: read

jobs:
  ci:
    name: ci
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@<CHECKOUT_SHA> # v4.2.2
        with:
          fetch-depth: 0

      - uses: astral-sh/setup-uv@<SETUP_UV_SHA> # v5.2.1         # python only
        with:
          enable-cache: true

      - name: install python deps
        run: uv sync --all-extras --dev                          # python only

      - uses: actions/setup-go@<SETUP_GO_SHA> # v5.2.0           # go only
        with:
          go-version-file: go.mod

      - uses: dtolnay/rust-toolchain@<RUST_TOOLCHAIN_SHA> # stable  # rust only
        with:
          toolchain: stable
          components: clippy, rustfmt

      - uses: actions/setup-node@<SETUP_NODE_SHA> # v4.1.0       # typescript only
        with:
          node-version: "22"

      - uses: pre-commit/action@<PRE_COMMIT_ACTION_SHA> # v3.0.1
```

`astral-sh/setup-uv` replaces `actions/setup-python` for Python repos - `uv sync` installs the interpreter version pinned in `pyproject.toml`/`.python-version` itself, so a separate Python setup step is redundant. This is also what the local `uv run pip-audit` / `uv run pytest` pre-commit hooks (`references/pre-commit.md`) depend on being synced before `pre-commit/action` runs them.

## `.github/workflows/secret-scan.yml`

PR-triggered gitleaks check (separate from the pre-commit gitleaks hook, so a PR still gets scanned even if someone bypasses local hooks).

```yaml
name: secret-scan

on:
  pull_request:

permissions:
  contents: read

jobs:
  secret-scan:
    name: secret-scan
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@<CHECKOUT_SHA> # v4.2.2
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@<GITLEAKS_ACTION_SHA> # v2.3.6
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## `.github/workflows/trufflehog-scheduled.yml`

Daily deep scan, independent of gitleaks - different detection engine and verified-credential checking.

```yaml
name: trufflehog-scheduled

on:
  schedule:
    - cron: "17 6 * * *"   # daily, off the hour
  workflow_dispatch:

permissions:
  contents: read

jobs:
  trufflehog:
    name: trufflehog
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@<CHECKOUT_SHA> # v4.2.2
        with:
          fetch-depth: 0
      - uses: trufflesecurity/trufflehog@<TRUFFLEHOG_ACTION_SHA> # v3.83.7
        with:
          extra_args: --results=verified,unknown
```

Release and publish workflows live in `references/release-automation.md`.
