# Pre-commit hooks

Uses the [pre-commit](https://pre-commit.com) framework. Base + gitleaks + Trivy blocks always apply; keep only the language block(s) that match this repo and delete the rest.

Install once per clone: `pre-commit install --hook-type pre-commit --hook-type pre-push`, then run `pre-commit autoupdate` immediately to move every `rev:` below off its placeholder pin to the current release.

**Python projects use [uv](https://docs.astral.sh/uv/) for all dependency management** - `uv add`/`uv add --dev`, `uv sync`, `uv run` - never bare `pip install`, poetry, or pipenv. `uv sync` creates `.venv` from `pyproject.toml` + `uv.lock`; the local hooks below run `uv run <tool>` so they always execute inside that synced environment. Add the tools they need as dev dependencies: `uv add --dev pytest pytest-cov pip-audit`.

```yaml
repos:
  # --- always ---
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0  # placeholder - run `pre-commit autoupdate`
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-added-large-files
      - id: check-yaml
      - id: check-json

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4  # placeholder - run `pre-commit autoupdate`
    hooks:
      - id: gitleaks

  - repo: local
    hooks:
      - id: trivy-fs
        name: trivy (vuln + misconfig)
        language: system
        entry: >-
          trivy fs --scanners vuln,misconfig --severity HIGH,CRITICAL
          --exit-code 1 --skip-dirs node_modules,vendor,target,dist,.venv .
        pass_filenames: false
        always_run: true

      - id: semgrep
        name: semgrep
        language: system
        entry: semgrep --config auto --error
        pass_filenames: false
        always_run: true

  # --- python - delete if not used ---
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9  # placeholder - run `pre-commit autoupdate`
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: local
    hooks:
      - id: pip-audit
        name: pip-audit
        language: system
        entry: uv run pip-audit
        files: '(pyproject\.toml|uv\.lock)$'
        pass_filenames: false

      - id: pytest-coverage
        name: pytest with 90% coverage gate
        language: system
        entry: uv run pytest -q --cov=. --cov-report=term-missing --cov-fail-under=90
        pass_filenames: false
        stages: [pre-commit]  # move to `stages: [pre-push]` if this slows down commits

  # --- go - delete if not used ---
  - repo: local
    hooks:
      - id: gofmt
        name: gofmt
        language: system
        entry: bash -c 'unformatted=$(gofmt -l .); if [ -n "$unformatted" ]; then echo "$unformatted"; exit 1; fi'
        pass_filenames: false

      - id: go-vet
        name: go vet
        language: system
        entry: go vet ./...
        pass_filenames: false

      - id: govulncheck
        name: govulncheck
        language: system
        entry: govulncheck ./...
        pass_filenames: false

      - id: go-test-coverage
        name: go test with 90% coverage gate
        language: system
        entry: >-
          bash -c 'go test ./... -coverprofile=coverage.out
          && go tool cover -func=coverage.out | tail -1
          | awk "{if (substr(\$3,1,length(\$3)-1)+0 < 90) exit 1}"'
        pass_filenames: false
        stages: [pre-commit]  # move to `stages: [pre-push]` if this slows down commits

  # --- rust - delete if not used ---
  - repo: local
    hooks:
      - id: rustfmt
        name: rustfmt
        language: system
        entry: cargo fmt -- --check
        pass_filenames: false

      - id: clippy
        name: clippy
        language: system
        entry: cargo clippy --all-targets --all-features -- -D warnings
        pass_filenames: false

      - id: cargo-audit
        name: cargo audit
        language: system
        entry: cargo audit
        pass_filenames: false

      - id: cargo-tarpaulin-coverage
        name: cargo test with 90% coverage gate
        language: system
        entry: cargo tarpaulin --fail-under 90
        pass_filenames: false
        stages: [pre-commit]  # move to `stages: [pre-push]` if this slows down commits

  # --- typescript - delete if not used ---
  - repo: local
    hooks:
      - id: biome
        name: biome (lint + format check)
        language: system
        entry: npx @biomejs/biome check .
        pass_filenames: false

      - id: osv-scanner
        name: osv-scanner
        language: system
        entry: osv-scanner -r .
        pass_filenames: false

      - id: vitest-coverage
        name: vitest with 90% coverage gate
        language: system
        entry: npx vitest run --coverage --coverage.thresholds.lines=90
        pass_filenames: false
        stages: [pre-commit]  # move to `stages: [pre-push]` if this slows down commits
```

## Why local hooks for most tools

`ruff-pre-commit` and `gitleaks` ship their own maintained `.pre-commit-hooks.yaml`, so they're pinned to upstream repos. Everything else (gofmt, rustfmt, clippy, biome, semgrep, the *-audit / *-vuln scanners, and the test+coverage runners) is wired as a `local` hook that shells out to the toolchain already installed for the project - `uv run <tool>` for Python, the native toolchain command for the others. This avoids depending on third-party pre-commit-repo mirrors of varying quality, and it means the hook always uses whatever compiler/interpreter version the project itself is pinned to.

## The 5-minute budget

The whole suite (lint + format + static analysis + secrets + tests + coverage) must finish in under 5 minutes. If the test+coverage hook is what blows the budget once the project grows, move it from `stages: [pre-commit]` to `stages: [pre-push]` (shown as a comment on each coverage hook above) so day-to-day commits stay fast and the full gate still runs before code leaves the machine.
