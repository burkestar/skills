# Configuration Reference

Fill in your own values below before relying on this skill for real work. Everything here
ships as a placeholder — no personal paths, credentials, or company details are checked in.
If any field is still a `{{PLACEHOLDER}}` when the skill runs, ask the user for the value
instead of guessing, and suggest they fill it in here for next time.

## Vault Path

`{{OBSIDIAN_VAULT_PATH}}` — e.g. `/Users/you/Documents/Obsidian/work/`

Required in Filesystem MCP allowed directories.

## Atlassian

- **Cloud ID**: `{{ATLASSIAN_CLOUD_ID}}`
- **URL**: `{{ATLASSIAN_BASE_URL}}` — e.g. `https://yourcompany.atlassian.net`

## Google Tasks MCP

- **Server**: `{{GOOGLE_TASKS_MCP_PATH}}`
- **CLI fallback**: `{{GOOGLE_TASKS_CLI_PATH}}`
- **OAuth config**: `{{GOOGLE_TASKS_OAUTH_DIR}}`
- **Task lists**: `{{TASK_LIST_NAMES}}` — e.g. Today, This week, Waiting for, Backlog, Learning

## User Preferences

- **Timezone**: `{{TIMEZONE}}`
- **JIRA linking**: Always hyperlink ticket keys to `{{ATLASSIAN_BASE_URL}}/browse/`
- **Content filtering**: Exclude declined calendar events, non-actionable system notices
- **Formatting**: Dataview-compatible YAML frontmatter, Obsidian callouts, wiki-links
