# AGENTS.md

Instructions for adding and maintaining skills in this plugin. Read this before creating a new skill.

## The model

This repo is one Claude Code plugin (`dustin-skills`) that also serves as its own marketplace. Every skill lives in `skills/<skill-name>/` and is auto-discovered. You do not edit `plugin.json` or `marketplace.json` when adding a skill - the manifests describe the plugin, not the individual skills.

## Adding a new skill

1. Create the directory: `skills/<skill-name>/`. Use kebab-case. The directory name is the skill name and must match the `name:` in the frontmatter exactly.

2. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter:

   ```markdown
   ---
   name: my-skill
   description: One or two sentences. State what the skill does AND when to trigger it, in the third person. Pack it with the words and phrases that should activate it - Claude reads this to decide whether to load the skill.
   ---

   # My Skill

   The instructions Claude follows once the skill loads.
   ```

3. Put supporting files in a subdirectory, usually `references/`. Reference them from `SKILL.md` with relative paths (`references/work.md`), never absolute paths and never `${CLAUDE_PLUGIN_ROOT}`. Bundled skill files travel with the skill, so relative paths always resolve.

4. Keep `SKILL.md` focused. Push long examples, tables, and edge cases into `references/` files and pull them in only when needed. The point of the frontmatter is triggering; the point of the body is doing.

5. Update the three places that list skills by hand - none of these are auto-generated from `skills/`:

   - **`README.md`** - add a row to the "What's in here" table (keep it alphabetical) and add the new folder to the tree under "How it's structured".
   - **`docs/index.html`** - add a card in the `#skills` grid, alphabetically among the existing ones. Make it a clickable `<a class="card" href="...">` (see the `chief-of-staff` card for the pattern) linking straight to the skill's `SKILL.md` on GitHub: `https://github.com/burkestar/skills/blob/main/skills/<skill-name>/SKILL.md`. Bump the skill count in the meta description and the hero `<p class="sub">` text, and add a `.card:nth-child(N)` animation-delay rule if the grid grew.
   - **`.claude-plugin/plugin.json`** - bump `version` (semver: a new skill is a minor bump) and mention the skill in `description` if that list is still accurate.

6. If the skill contains anything specific to one machine or one person's accounts (absolute paths, API instance URLs, cloud IDs, credentials), pull those into a `references/configuration.md` with `{{PLACEHOLDER}}` values instead of hardcoding them - see `skills/chief-of-staff/references/configuration.md` for the pattern. Instruct the skill to ask the user for real values when a placeholder is still unfilled.

## Rules that keep a skill correct

- **`name` must be unique** across the plugin and match the directory name.
- **`name` and `description` are the only required frontmatter fields.** Do not invent other frontmatter keys - unknown keys are ignored at best and confusing at worst.
- **The `description` is the trigger.** If a skill never fires when it should, the description is too vague. Name the artifacts, phrases, and situations explicitly.
- **No secrets, no machine-specific paths** in any skill file. These get published to a public repo and installed on other people's machines.
- **Relative paths only** inside a skill. `${CLAUDE_PLUGIN_ROOT}` is for hook and MCP command paths at the plugin root, not for skill reference files.

## Verifying a skill before you commit

1. Frontmatter parses and has both `name` and `description`:

   ```bash
   for f in skills/*/SKILL.md; do
     echo "== $f"
     awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$f" | grep -E '^(name|description):' || echo "MISSING FIELD"
   done
   ```

2. Directory name matches the `name:` field.
3. Every relative path referenced in `SKILL.md` actually exists.
4. Install the plugin locally and confirm the skill loads:

   ```
   /plugin marketplace add /path/to/this/repo
   /plugin install dustin-skills@burkestar
   ```

   Then start a session and check the skill shows up and triggers on a representative prompt.

## Releasing a change

Bump `version` in `.claude-plugin/plugin.json` (semver) when you add or meaningfully change a skill. Users pull the update with `/plugin marketplace update burkestar`.

## Adding this repo's own writing voice

Prose that ships in this repo (README, this file, skill docs) should follow the `dustin-writing-style` skill. That skill is right here in `skills/dustin-writing-style/` - use it.
