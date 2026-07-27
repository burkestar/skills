---
name: architecture-diagram
description: "Build and verify an interactive single-file HTML architecture blueprint for one or more repos — investigate with parallel agents, render boxes/arrows/drawers with a guided step tour, fact-check adversarially, deploy via GitHub Pages. Trigger when the user asks for an architecture diagram/blueprint/system map of repos."
user-invocable: true
argument-hint: "[repo|path ...]"
---

# Architecture Blueprint

Produce a single-file, zero-dependency interactive HTML architecture blueprint (boxes, arrows, click-drawers, guided step tour) and prove it correct before claiming done. Canonical reference output: `assets/template.html`.

## Phase 1 — Investigate

1. **FIRST**: `git fetch && git pull` (or `git fetch origin main`) in **every** involved repo. Never diagram stale code.
2. Launch **parallel read-only Explore agents**: one per repo, plus **one per integration seam** (e.g. "how does repo A call repo B — endpoints, auth, payloads"). Send all Agent calls in a single message so they run concurrently.
3. Demand **file:line evidence** for every claim in each agent's report. Reject "probably"/"typically" answers — re-task the agent.
4. Collect: components, ports, endpoints, auth chains, data stores, async loops, planned/on-hold work, and the end-to-end request lifecycle as numbered steps.

## Phase 2 — Build

Copy `assets/template.html` from this skill dir to `<workdir>/<name>-architecture.html` and edit its data section (everything lives in one `<script>`; no external deps, works from `file://`). Data model:

- `C` — color map, one key per repo + `ext` (platform/infra grey), `seam` (rose `#fb5d76`), `plan` (fuchsia `#e879f9`), `line`. `STAGE_W`/`STAGE_H` set canvas size; `#stage` is the absolutely-positioned canvas.
- `panels` — repo container boxes `{t,s,x,y,w,h,c}`; renders `.ptitle`/`.psub` pills on the border. `subheads` — small italic annotations `{x,y,text}`.
- Bands (bottom strips, rendered as `.notes` cards): `process` `{id,x,y,w,title,items:[{step,c,t}]}` — the numbered end-to-end strip; each `step` index makes the item a clickable `.item.step[data-step]` that jumps the tour. `notes` — same shape minus `step`, for cross-cutting facts. `repos` — one item per repo via the `gl('org/repo','role')` helper (renders a `.ghlink`), titled "Code repositories". Give every band an `id` (`sec-process`/`sec-notes`/`sec-repos`) so the header's section-nav can jump to it, and list all bands in the `[process,notes,repos].forEach(...)` render loop (it applies `if(card.id)d.id=card.id`). Bump `STAGE_H` to fit the added band and re-run the overlap audit.
- `N` — nodes `{id,c,x,y,w,h,t,s}` + flags `sm:1` (small/secondary), `ghost:1` (dashed planned box). Renders `.node[data-id]` with `.nt`/`.ns` text.
- `A` — arrows `{f,t,k,l,lo:[dx,dy]}` where `k` ∈ `internal|seam|call|reg|poll|plan`; optional `sides:['right','left']` to force anchor sides, `route:'<name>'` for hand-drawn polyline routes (add cases in the `A.forEach` router), `lx` for leftloop x, `bidir:1` for double arrowheads. `l` renders a `.wlabel` (`.seam` variant) offset by `lo`.
- `D` — drawers keyed by **node id**: `{r:<repoKey>, gh?:'org/repo', t, role, b:<html>}` with `<div class="sec"><h3>…</h3>…</div>` sections. The drawer header (`#drepo`) shows a **GitHub repo link**: `ghRepo(d)` uses `d.gh` when set, else auto-derives from `REPO_URL[d.r]` — so every box in a mapped repo links its repo for free; set `gh:` only to override (a cross-repo `ext` box, e.g. `gh:'acme/edge-gateway'`). Helpers: `P('path/file.py')` renders a file path (auto-linked via `linkPaths`), `L(repo,'path'[,label])` GitHub-linked path, `NP(id,label)` cross-nav pill (`[data-node]`) that opens another drawer. Put **key doc/repo links in the drawer body** too (Confluence, PRs, design docs) — the details pane is where they belong.
- `process`/tour glue: `STEPS` — the guided tour, one entry per numbered step `{g:'①', c, title, role, nodes:[ids], arrows:['f->t',…], b:<html>}`. `nodes` must be N ids; `arrows` must match A entries as `'f->t'` keys. Tour controls: `#tplay #tprev #tnext #texit #tinfo`; drawer: `#drawer #dtitle #dbody #scrim`.
- Header chrome: `.htop` holds the `<h1>` plus a top-right `#hcollapse` button that toggles `header.collapsed` (hides `.hbody` — the verbose sub/legend — keeping the title + nav). Below the legend, `<nav class="secnav" id="secnav">` renders `data-jump` buttons (`top` + each band `id`) that smooth-scroll `#viewport` to the section. `sizeViewport()` sets `#viewport` height from the live `header.offsetHeight` (on load, on collapse, on resize) so a taller/shorter header never clips the canvas — keep this instead of a hard-coded `calc(100vh - …)`.
- `repoMeta` `{key:[displayName,color]}` and `REPO_URL` `{key:githubUrl}` power the drawer repo badge and file links; `REPO_URL` also seeds the auto-derived drawer repo link (see `D`/`ghRepo`).

Conventions (non-negotiable):
- **One color per repo**; rose = cross-service seams; fuchsia (`--plan`) = planned / on-hold **ghosts**.
- Numbered glyphs `⓪①②…` appear **exactly once on the canvas** (as arrow labels) and **once in the process strip**. No duplicates.
- **Depth goes in drawers, never on the canvas.** Canvas text is titles + one-line subtitles only.

## Phase 3 — Verify (non-negotiable before claiming done)

```bash
cd <workdir>
cp <skill_dir>/assets/diag.html .          # must be same-origin with the target
python3 -m http.server 8799 &
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

1. **Overlap + clipping audit** — must report `"ok":true` (zero overlaps > 3px among `.node/.wlabel/.ptitle/.psub/.subhead/.blabel/.notes`, zero clipped node text):
```bash
"$CHROME" --headless --disable-gpu --virtual-time-budget=5000 --dump-dom \
  "http://localhost:8799/diag.html?t=<name>-architecture.html" | grep -o 'RESULT::[^<]*'
```
Fix every reported pair (move nodes, adjust `lo` label offsets, widen boxes), re-run until clean.

2. **Syntax** — extract and check the script:
```bash
awk '/<script>/{f=1;next}/<\/script>/{f=0}f' <name>-architecture.html > /tmp/bp.js && node --check /tmp/bp.js
```

3. **STEPS refs** — every `STEPS[].nodes` entry exists in `N`, every `STEPS[].arrows` `'f->t'` key matches an `A` entry. Write a throwaway node script (regex-extract ids/pairs from /tmp/bp.js) — zero unknown refs.

4. **Path audit** — extract every `P('…')` / `L('repo','…')` path and `test -f` it against the actual repo checkouts on disk. A drawer path that 404s is a fact-check failure.

5. **Look at it** — screenshot regions and actually READ the images with the Read tool:
```bash
"$CHROME" --headless --disable-gpu --window-size=2100,1450 \
  --screenshot=/tmp/bp.png "http://localhost:8799/<name>-architecture.html"
```

6. **Interactions** — write a throwaway iframe harness (same pattern as diag.html; see the diag3 example flow): click `#tplay`, `#tnext` ×3, a `#dbody [data-node]` cross-nav pill, a `.item.step[data-step]` strip item, `#texit`, and dispatch `mouseenter`/`mouseleave` on a `.node`; assert dim/highlight counts (`.node.dim`, `.node.hl`, `svg path.dim`) and `#dtitle` text at each step; emit `document.title='RESULT::'+JSON` and read via `--dump-dom`.

## Phase 4 — Fact-check

Launch **parallel ADVERSARIAL agents** (one per repo slice + one for seams). Instruction: "Here are the claims this diagram makes about <repo>: <extracted claims>. Try to **REFUTE** each one with file:line evidence from the repo. Report every claim that is wrong, stale, or overstated." Fix all findings in the HTML, then **re-run Phase 3 in full**.

## Phase 5 — Deploy

1. Put the blueprint in `docs/` of the target repo + a `docs/index.html` landing page linking every blueprint.
2. Enable GitHub Pages from `main:/docs`:
```bash
gh api -X POST repos/<owner>/<repo>/pages -f build_type=legacy \
  -f "source[branch]=main" -f "source[path]=/docs"   # PUT if already enabled
```
3. The human writes/approves commits — stage with `git add` and stop. Never push unless the user explicitly says push.
