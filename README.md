# Dustin's Skills

Reusable [Claude Code](https://docs.claude.com/en/docs/claude-code) skills, packaged as a plugin so I can install them anywhere with two commands instead of copying folders around.

## Install

Inside Claude Code, run:

```
/plugin marketplace add burkestar/skills
/plugin install dustin-skills@burkestar
```

The first command registers this repo as a marketplace. The second installs the plugin and every skill in it. That's the whole setup. There is no single-command shortcut in Claude Code today - it's always add-marketplace then install.

To update later:

```
/plugin marketplace update burkestar
```

To remove it:

```
/plugin uninstall dustin-skills@burkestar
```

## What's in here

| Skill | What it does |
| --- | --- |
| `architecture-diagram` | Build and verify an interactive single-file HTML architecture blueprint for one or more repos - investigate with parallel agents, render boxes/arrows/drawers with a guided step tour, fact-check adversarially, deploy via GitHub Pages. |
| `chief-of-staff` | Pull Gmail, Calendar, Drive, Google Tasks, JIRA, Confluence, and Slack into an Obsidian vault as structured markdown - daily briefings, weekly summaries, meeting prep, project status, decision logs, people dossiers. Personal workflow; fill in `references/configuration.md` before use. |
| `dustin-writing-style` | Write in Dustin Burke's voice - direct, opinionated, concrete, plainspoken. Triggers on emails, Slack, docs, commits, PRs, and anything going out under his name. |
| `personal-repo-bootstrap` | Bootstrap a new GitHub repo under the burkestar org for personal projects - repo settings, branch protection, pre-commit hooks, CI/CD, release automation, the standard docs set, and a GitHub Pages docs site. Not for work repos. |
| `staff-engineer` | Review code like a skeptical staff engineer via a subagent - checks correctness, simplicity, surgical scope, and architecture, and refuses to rubber-stamp. Use after finishing a non-trivial change or for a second opinion. |

## How it's structured

```
.
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest
│   └── marketplace.json     # lets this repo serve as its own marketplace
└── skills/
    ├── architecture-diagram/
    │   ├── SKILL.md
    │   └── assets/
    ├── chief-of-staff/
    │   ├── SKILL.md
    │   └── references/
    ├── dustin-writing-style/
    │   ├── SKILL.md
    │   └── references/
    ├── personal-repo-bootstrap/
    │   ├── SKILL.md
    │   ├── references/
    │   └── scripts/
    └── staff-engineer/
        └── SKILL.md
```

The repo is both the marketplace and the plugin. `marketplace.json` points its one plugin at the repo root (`./`), and skills are auto-discovered from `skills/`. Adding a skill is just dropping a new folder into `skills/` - no manifest edits.

## Adding a skill

See [AGENTS.md](./AGENTS.md) for the checklist and conventions.
