# Publishing docs/ to GitHub Pages with MkDocs Material

[MkDocs](https://www.mkdocs.org) + the [Material theme](https://squidfunk.github.io/mkdocs-material/) is the pick here: lightweight (pure Markdown in, static HTML out, no JS framework to maintain), best-of-breed (the de facto standard for OSS docs sites, actively maintained), and its default theme is exactly the "beautiful, minimal" bar - clean typography, light/dark toggle, instant search, mobile-friendly - with no extra design work. Its default `docs_dir` is literally `docs/`, so it publishes the existing docs set with no restructuring.

**Private-repo caveat:** repos from this skill default to private (`references/repo-settings.md`). GitHub Pages from a private repository requires GitHub Pro on a personal account (org-owned private repos need Team/Enterprise). Confirm your plan covers this, or flip the repo to public, before expecting the site to actually be reachable - the workflow will still go green even if Pages can't serve because the plan doesn't support it.

## `mkdocs.yml` (repo root)

```yaml
site_name: <Project Name>
site_description: <one-line description>
site_url: https://burkestar.github.io/<repo-name>/
repo_url: https://github.com/burkestar/<repo-name>
repo_name: burkestar/<repo-name>

docs_dir: docs

# keep plan-mode working docs out of the published site
exclude_docs: |
  plans/

nav:
  - Home: index.md
  - Usage: USAGE.md
  - Architecture: ARCHITECTURE.md
  - Requirements: REQUIREMENTS.md
  - Development: DEVELOPMENT.md
  - Standards: STANDARDS.md
  - Operations: OPS.md

theme:
  name: material
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.top
    - search.suggest
    - content.code.copy

markdown_extensions:
  - admonition
  - toc:
      permalink: true
  - pymdownx.highlight
  - pymdownx.superfences
```

## `docs/index.md`

MkDocs needs a homepage; nothing in the existing doc set is meant to be one, so add a short landing page:

```markdown
# <Project Name>

<One or two sentences - what this is and who it's for.>

- [Usage guide](USAGE.md) - key features and how to use it
- [Architecture](ARCHITECTURE.md) - design principles, components, tech stack
- [Requirements](REQUIREMENTS.md) - product and functional requirements
- [Development](DEVELOPMENT.md) - setup, run, test, deploy, release
- [Standards](STANDARDS.md) - platform rules (MUST/SHOULD/MAY)
- [Operations](OPS.md) - observability and troubleshooting
```

## `docs/pyproject.toml`

The docs site is its own small [uv](https://docs.astral.sh/uv/) project, self-contained under `docs/` regardless of the repo's primary language - consistent with using uv for all Python dependency management (`references/pre-commit.md`).

```toml
[project]
name = "docs"
version = "0.0.0"
requires-python = ">=3.12"
dependencies = [
    "mkdocs-material",
]
```

Then lock it:

```bash
cd docs && uv lock && cd ..
```

That generates `docs/uv.lock`, pinned to whatever's actually current - don't hand-write version numbers. Dependabot (added below) keeps it current after that.

## `.github/workflows/docs.yml`

Builds and deploys on every push to `main` that touches the docs - i.e. automatically on merge. Pin every `uses:` to a full SHA with `scripts/pin-actions.sh` (check current tags first, these are examples):

```bash
scripts/pin-actions.sh \
  actions/checkout@v4.2.2 \
  astral-sh/setup-uv@v5.2.1 \
  actions/configure-pages@v5.0.0 \
  actions/upload-pages-artifact@v3.0.1 \
  actions/deploy-pages@v4.0.5
```

```yaml
name: docs

on:
  push:
    branches: [main]
    paths:
      - "docs/**"
      - "mkdocs.yml"
      - ".github/workflows/docs.yml"
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@<CHECKOUT_SHA> # v4.2.2

      - uses: astral-sh/setup-uv@<SETUP_UV_SHA> # v5.2.1
        with:
          enable-cache: true

      - name: install mkdocs
        run: uv sync --project docs

      - name: build
        run: uv run --project docs mkdocs build --strict

      - uses: actions/configure-pages@<CONFIGURE_PAGES_SHA> # v5.0.0

      - uses: actions/upload-pages-artifact@<UPLOAD_PAGES_ARTIFACT_SHA> # v3.0.1
        with:
          path: site

  deploy:
    needs: build
    runs-on: ubuntu-latest
    timeout-minutes: 5
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@<DEPLOY_PAGES_SHA> # v4.0.5
        id: deployment
```

`mkdocs build --strict` fails the build on broken internal links or nav references instead of silently shipping a broken site - cheap correctness check.

## Enable Pages once, from the CLI

`actions/configure-pages` will create the Pages config on first run if it doesn't exist, but it's more predictable to set it explicitly up front so the first workflow run doesn't fail waiting on Pages to be enabled:

```bash
gh api --method POST "repos/${REPO}/pages" -f "build_type=workflow" \
  || gh api --method PUT "repos/${REPO}/pages" -f "build_type=workflow"
```

(`POST` creates it; if it already exists that 422s and the `PUT` updates it to build via Actions instead of a legacy branch.)

## Dependabot

`references/repo-settings.md`'s `dependabot.yml` already includes a `uv` ecosystem block for `/docs` (matching `docs/pyproject.toml` + `docs/uv.lock`), kept unconditionally - unlike the per-language blocks - since the docs site is always Python/MkDocs regardless of the project's primary language.
