# Release automation: version bumps, changelog, signed publishing

Uses [release-please](https://github.com/googleapis/release-please) driven by Conventional Commits (`feat:`, `fix:`, `feat!:`/`BREAKING CHANGE:`, etc.). It opens a standing "release PR" that bumps the version and updates `CHANGELOG.md`; merging that PR tags the release. A second workflow reacts to the tag to build and publish artifacts.

## `release-please-config.json`

Set `release-type` to match the repo's language: `python`, `go`, `rust`, or `node` (falls back to `simple` for anything else / mixed repos, which tags and changelogs but doesn't bump a manifest file).

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "simple",
  "packages": {
    ".": {
      "changelog-sections": [
        { "type": "feat", "section": "Features" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "perf", "section": "Improvements" },
        { "type": "refactor", "section": "Improvements" },
        { "type": "deps", "section": "Improvements" },
        { "type": "docs", "section": "Improvements", "hidden": true },
        { "type": "chore", "section": "Improvements", "hidden": true },
        { "type": "test", "section": "Improvements", "hidden": true }
      ]
    }
  }
}
```

Breaking changes need no explicit section entry - release-please automatically pulls any commit marked with `!` (e.g. `feat!:`) or a `BREAKING CHANGE:` footer into its own "⚠ BREAKING CHANGES" section at the top of the changelog, regardless of type. That covers all four categories the changelog needs: Features, Bug Fixes, Improvements, Breaking Changes.

## `.release-please-manifest.json`

```json
{ ".": "0.1.0" }
```

## `.github/workflows/release-please.yml`

```yaml
name: release-please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    outputs:
      release_created: ${{ steps.release.outputs.release_created }}
      tag_name: ${{ steps.release.outputs.tag_name }}
    steps:
      - uses: googleapis/release-please-action@<RELEASE_PLEASE_ACTION_SHA> # v4.1.3
        id: release
```

## `.github/workflows/publish.yml`

Triggers on the version tag release-please creates when its PR is merged. Keep only the sections that apply - most repos won't need the container/Helm block.

```yaml
name: publish

on:
  push:
    tags:
      - "v*.*.*"

permissions:
  contents: write
  packages: write
  id-token: write   # required for cosign keyless signing via OIDC

jobs:
  publish:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@<CHECKOUT_SHA> # v4.2.2

      # --- build language-specific release artifacts here (wheels, binaries, etc.) ---

      - uses: softprops/action-gh-release@<GH_RELEASE_ACTION_SHA> # v2.1.0
        with:
          generate_release_notes: false   # release-please already wrote the changelog-based notes
          files: |
            dist/*

      # --- only if this repo publishes a container image ---
      - uses: docker/login-action@<DOCKER_LOGIN_SHA> # v3.3.0
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@<DOCKER_BUILD_PUSH_SHA> # v6.9.0
        id: build
        with:
          push: true
          tags: ghcr.io/burkestar/<repo-name>:${{ github.ref_name }}

      - uses: sigstore/cosign-installer@<COSIGN_INSTALLER_SHA> # v3.7.0

      - name: sign image (keyless, OIDC)
        run: cosign sign --yes "ghcr.io/burkestar/<repo-name>@${{ steps.build.outputs.digest }}"

      # --- only if this repo publishes a Helm chart ---
      - name: package and push chart
        run: |
          helm package charts/<chart-name>
          helm push <chart-name>-*.tgz oci://ghcr.io/burkestar/charts
      - name: sign chart
        run: |
          digest=$(oras manifest fetch --descriptor "ghcr.io/burkestar/charts/<chart-name>:${{ github.ref_name }}" | jq -r .digest)
          cosign sign --yes "ghcr.io/burkestar/charts/<chart-name>@${digest}"
```

GHCR is free for public images; this repo is private by default per `references/repo-settings.md`, so confirm GHCR visibility/billing expectations for private images before relying on it. Cosign keyless signing needs no stored key - it uses the workflow's OIDC token against Sigstore's Fulcio/Rekor, which is why `id-token: write` is required.
