# Repo creation, branch protection, CODEOWNERS, Dependabot

## Repo creation

```bash
REPO="burkestar/<repo-name>"   # lowercase-with-hyphens

gh repo create "$REPO" --private --license apache-2.0 --clone
cd "<repo-name>"

gh repo edit "$REPO" \
  --enable-wiki=false \
  --enable-projects=false \
  --enable-issues=true \
  --enable-squash-merge=true \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge=true \
  --enable-auto-merge=false
```

Issues stay on deliberately - this is where task tracking lives (see `docs/DEVELOPMENT.md`), separate from the wiki and the (disabled) classic Projects board.

`gh repo create --license apache-2.0` populates `LICENSE` from GitHub's official template - don't hand-write it.

## Branch protection ruleset

GitHub's newer Rulesets API (not classic branch protection) is what lets "admins" bypass specific rules cleanly. Create `main-ruleset.json`:

```json
{
  "name": "main-branch-protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": { "include": ["refs/heads/main"], "exclude": [] }
  },
  "bypass_actors": [
    { "actor_type": "OrganizationAdmin", "bypass_mode": "always" }
  ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_signatures" },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": true,
        "required_status_checks": [
          { "context": "ci" },
          { "context": "secret-scan" }
        ]
      }
    }
  ]
}
```

Apply it:

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "repos/${REPO}/rulesets" \
  --input main-ruleset.json
```

**Ordering gotcha:** `required_status_checks` contexts must have run at least once before GitHub will let you require them. If this is a fresh repo, either push once with a no-op commit to let `ci` and `secret-scan` register first, or apply the ruleset without that rule and add it afterward via the GitHub UI (Settings → Rules → Rulesets).

**Why `OrganizationAdmin` / `always` and not per-rule:** bypass actors apply to the whole ruleset, not to individual rules, so a single bypass entry that only exempted force-pushes isn't possible without splitting into two rulesets. `always` (not `pull_request`) is required because force-push happens outside a PR context.

**Self-approval caveat for a solo maintainer:** CODEOWNERS below is just `@burkestar`. GitHub will not let you approve your own PR, so with `require_code_owner_review: true` and no bypass, a solo-authored PR could never merge. The `OrganizationAdmin` bypass above intentionally covers *all* rules in this ruleset (including the review requirement), not just force-push, so that you (as org admin) can still merge your own PRs. Everyone else - collaborators, bots, anyone without admin on the org - is fully bound by signed commits, 1 codeowner review, and passing checks, and can never force-push or delete `main`. If you later add a second real reviewer and want the review rule to actually bind you too, split this into two rulesets (one for `non_fast_forward`+`deletion` with the bypass, one for the rest without it).

## CODEOWNERS

`.github/CODEOWNERS`:

```
* @burkestar
```

## Dependabot

`.github/dependabot.yml` - keep the `github-actions` block always, plus only the ecosystem block(s) matching this repo's language(s):

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "burkestar"
    commit-message:
      prefix: "chore(deps)"

  - package-ecosystem: "uv"         # docs site (MkDocs) - always keep, independent of project language
    directory: "/docs"
    schedule:
      interval: "weekly"
    reviewers:
      - "burkestar"
    commit-message:
      prefix: "chore(deps)"

  - package-ecosystem: "uv"         # python - delete if not used
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "burkestar"
    commit-message:
      prefix: "chore(deps)"

  - package-ecosystem: "gomod"      # go - delete if not used
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "burkestar"
    commit-message:
      prefix: "chore(deps)"

  - package-ecosystem: "cargo"      # rust - delete if not used
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "burkestar"
    commit-message:
      prefix: "chore(deps)"

  - package-ecosystem: "npm"        # typescript - delete if not used
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "burkestar"
    commit-message:
      prefix: "chore(deps)"
```

The `github-actions` block is also what keeps SHA-pinned actions current: when workflow files pin `uses: owner/repo@<sha> # vX.Y.Z`, Dependabot recognizes that comment convention and opens a PR bumping both the SHA and the comment when a new version ships.

`uv` is Dependabot's native ecosystem for `pyproject.toml` + `uv.lock` projects - not `pip`, which won't resolve the lockfile.
