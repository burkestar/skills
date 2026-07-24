---
name: personal-repo-bootstrap
description: Bootstrap a brand-new GitHub repository in the burkestar org for Dustin's personal projects, side projects, and startup consulting/advisory work. Covers repo visibility and settings, branch protection rulesets, CODEOWNERS, Dependabot, pre-commit linting/formatting/static analysis/secret scanning per language (Python, Go, Rust, TypeScript), CI workflows, release automation with categorized changelogs, signed container/Helm publishing, the standard docs set (AGENTS.md, CLAUDE.md, docs/ARCHITECTURE.md, docs/REQUIREMENTS.md, docs/DEVELOPMENT.md, docs/STANDARDS.md, docs/USAGE.md, docs/OPS.md), and publishing those docs to GitHub Pages via MkDocs Material on every merge to main. Trigger on "new repo", "bootstrap a repo", "set up a new GitHub project", "create a burkestar repo", "start a new personal/side project", "publish docs to GitHub Pages". Do NOT use this skill for work repositories - work has different standards, tooling, and ownership. Only use it for personal projects under the burkestar org.
---

# Personal Repo Bootstrap (burkestar org)

This skill is for Dustin's own repos - personal projects, side projects, consulting/advisory work under the `burkestar` GitHub org. **Never apply it at work.** If it's unclear whether a repo is personal or work, ask before proceeding.

## Guiding principles

Apply these whenever a choice isn't already pinned down by the steps below (e.g. picking a queue, a cache, a scanner not already named here):

- **Best-of-breed, open source, well maintained.** Prefer tools with active maintainers and real adoption over novelty or convenience. Every tool named in this skill (ruff, biome, gitleaks, Trivy, semgrep, release-please, cosign) was chosen on that basis - hold any new addition to the same bar.
- **uv for all Python package management.** `uv add`/`uv add --dev`, `uv sync`, `uv run` - never bare `pip install`, poetry, or pipenv. Applies to the project itself and to the docs site (`references/docs-site.md`). See `references/pre-commit.md`.
- **Frugal by default.** Prefer hosted services with generous free tiers (see `references/webapp-stack.md`) and design for a small resource footprint - fewer moving parts, lower idle cost, no infrastructure paid for "just in case."
- **Don't scaffold AI/LLM tooling speculatively.** Evals, memory, observability, and MCP tooling are real costs (dependencies, accounts, cognitive overhead) - add them only once the project actually needs them. See `references/ai-tooling.md`.

## Before starting, ask if not already known

1. **Repo name** - convert whatever the user gives you to lowercase-with-hyphens (e.g. "My Cool App" → `my-cool-app`).
2. **Primary language(s)** - python, go, rust, typescript, or a mix. This determines which pre-commit hooks, CI setup steps, and release-please `release-type` to use.
3. **Is it a web app that will be deployed?** If yes, pull in `references/webapp-stack.md` for the default hosting/infra stack.
4. **Does it publish a container image or Helm chart?** If yes, include the signed-publish steps from `references/release-automation.md`.

## Steps

Work through these in order. Each links to a reference file with the concrete commands, JSON, and YAML to use - read the reference before acting, don't improvise the config from memory.

1. **Create and configure the repo** - private visibility, kebab-case name, wiki/projects disabled, squash-merge only, Issues left **on** (that's where task tracking lives - see below). See `references/repo-settings.md` § Repo creation.
2. **Protect `main`** - a ruleset requiring signed commits, 1 codeowner-approved review, passing status checks, and blocking force-push/deletion for everyone except org admins. See `references/repo-settings.md` § Branch protection ruleset, including the self-approval caveat for a solo maintainer.
3. **Add CODEOWNERS and Dependabot** - `burkestar` as default owner; Dependabot opens version-bump PRs and requests `burkestar` as reviewer. See `references/repo-settings.md` § CODEOWNERS and § Dependabot.
4. **Add pre-commit hooks** - formatter + linter + static analysis per language, plus gitleaks and Trivy. See `references/pre-commit.md`. Only keep the language block(s) that match this repo; delete the rest.
5. **Add GitHub Actions workflows** - CI (runs pre-commit on every push), a PR-triggered secret-scan check, and a daily scheduled TruffleHog scan. See `references/workflows.md`. Pin every `uses:` to a full commit SHA using `scripts/pin-actions.sh` - never leave a bare tag.
6. **Wire up release automation** - release-please for version bumping + a changelog split into Features / Bug Fixes / Improvements / Breaking Changes, plus a publish workflow for release artifacts (and signed container/Helm publishing if applicable). See `references/release-automation.md`.
7. **Scaffold the docs set** - AGENTS.md, CLAUDE.md (points at AGENTS.md), docs/{ARCHITECTURE,REQUIREMENTS,DEVELOPMENT,STANDARDS,USAGE,OPS}.md, an empty `docs/plans/` folder, and the minimal PR template. See `references/docs-templates.md`. AGENTS.md tells agents working in this repo to track tasks as GitHub Issues (not a TODO file) and to write plan-mode plans to `docs/plans/<descriptive-kebab-case-name>.md` - this repo's convention overrides the global default of `.claude/plans/`.
8. **Publish the docs to GitHub Pages** - MkDocs with the Material theme builds `docs/` (excluding `docs/plans/`, which stays internal) into a site, deployed automatically on every push to `main`. See `references/docs-site.md`, including the private-repo/GitHub-Pro caveat.
9. **Require signed commits locally** - the ruleset from step 2 already rejects unsigned commits on `main`; also set `git config commit.gpgsign true` (or the SSH-signing equivalent) in the fresh clone so commits don't get rejected at push time.
10. **Apache 2.0 license** - already handled by `gh repo create --license apache-2.0` in step 1; don't hand-roll the LICENSE file.
11. **If it's a web app**, append the default deployment stack from `references/webapp-stack.md` to `docs/ARCHITECTURE.md`'s tech stack table.
12. **AI/LLM tooling (evals, memory, observability, MCP) - only if the project actually needs it.** Don't add DeepEval/promptfoo, supermemory, Langfuse, or MCP servers during bootstrap. See `references/ai-tooling.md` for what each is for and the signal that means it's time to add one.

## Verify before calling it done

- [ ] `gh repo view <repo>` shows private, wiki off, projects off, issues on, squash-only.
- [ ] The ruleset on `main` is active (`gh api repos/burkestar/<repo>/rulesets`) and blocks a test force-push from a non-admin context.
- [ ] `pre-commit run --all-files` passes locally.
- [ ] CI, secret-scan, and the daily TruffleHog workflow all appear under Actions and are green (or scheduled).
- [ ] Every workflow `uses:` line is a full SHA with a version comment, not a bare tag.
- [ ] release-please config + manifest are present and reference the right `release-type` for the language.
- [ ] AGENTS.md, CLAUDE.md, and all six docs/ files exist; CLAUDE.md just points at AGENTS.md; `docs/plans/` exists.
- [ ] The `docs` workflow is green on Actions and the Pages site is reachable; `docs/plans/` is not published.
- [ ] CODEOWNERS and dependabot.yml exist and name `burkestar`.
- [ ] No eval/memory/observability/MCP dependency was added unless the project actually needed one.
- [ ] Any Python (project code or the docs site) uses `pyproject.toml` + `uv.lock` and `uv run` - no bare `pip install`, poetry, or pipenv, and Dependabot targets the `uv` ecosystem, not `pip`.
