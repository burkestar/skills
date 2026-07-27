# Chief of Staff Note Templates

Use these templates as the starting structure for each task type. Adapt as needed based on
available data, but keep the frontmatter keys consistent for Dataview queries.

---

## Daily Briefing Template

```markdown
---
type: daily-briefing
date: {{DATE}}
sources: [{{SOURCES}}]
tags: [chief-of-staff, daily]
status: current
confidence: high | medium | low
last_updated: {{TIMESTAMP}}
---

# {{DATE}}

## BLUF
- First priority — what and why
- Second priority — what and why
- (Optional) Key meeting requiring prep: **Meeting name** — review [linked doc](url)

## Action Items

### Today
- [ ] Task from Google Tasks
- [ ] [PROJ-123]({{ATLASSIAN_BASE_URL}}/browse/PROJ-123) — Summary (Major)

### This Week
- [ ] Task from Google Tasks
- [ ] Implied action from email/Slack

### Waiting For
- [ ] (Person) Item description

### Overdue
- [ ] Item ⚠️ overdue (due YYYY-MM-DD)

## Highlights
- **Decision/question** — context and who's involved. Source: Slack/email/Confluence
- **Request directed at you** — what's needed, from whom. Source: email

> [!warning] Urgent item
> Description with deadline

> [!info] FYI context
> Useful background for today's meetings
```

---

## Weekly Summary Template

```markdown
---
type: weekly-summary
date: {{DATE}}
week: {{ISO_WEEK}}
sources: [{{SOURCES}}]
tags: [chief-of-staff, weekly]
status: current
confidence: high | medium | low
last_updated: {{TIMESTAMP}}
---

# Weekly Summary — Week {{ISO_WEEK}}

## Summary
> The week in 3 sentences.

## Key Decisions Made
1. Decision — context and source
2. Decision — context and source

## Projects Progress
### Project Name
- What moved forward
- What's blocked
- Key links: [PROJ-123]({{ATLASSIAN_BASE_URL}}/browse/PROJ-123)

## Meetings of Note
- **Meeting title** (date) — key takeaway

## Next Week Preview
- Key meetings coming up
- Deadlines approaching

## Action Items Carried Forward
- [ ] Item from this week still open
```

---

## Meeting Prep Template

```markdown
---
type: meeting-prep
date: {{DATE}}
meeting_title: {{TITLE}}
attendees: [{{ATTENDEES}}]
sources: [{{SOURCES}}]
tags: [chief-of-staff, meeting-prep]
status: current
last_updated: {{TIMESTAMP}}
---

# Meeting Prep — {{TITLE}}

## Meeting Details
- **When**: {{DATETIME}}
- **Where**: {{LOCATION_OR_LINK}}
- **Attendees**: {{ATTENDEES}}
- **Agenda**: {{AGENDA_IF_AVAILABLE}}

## Context on Attendees
### {{Person Name}}
- Role / relationship
- Recent interactions (email, Slack, JIRA)
- Open items with this person

## Relevant Background
### From JIRA
- Key issues related to meeting topic

### From Confluence
- Related docs and their key points

### From Slack
- Recent conversations related to agenda

## Suggested Talking Points
1. Point — rationale

## Open Questions to Raise
- Question 1

## Pre-Meeting Action Items
- [ ] Review {{document}}
```

---

## Project Status Template

```markdown
---
type: project-status
project: {{PROJECT_NAME}}
date: {{DATE}}
sources: [{{SOURCES}}]
tags: [chief-of-staff, project, {{PROJECT_TAG}}]
status: current
confidence: high | medium | low
last_updated: {{TIMESTAMP}}
---

# Project Status — {{PROJECT_NAME}}

## Summary
> Current state in 2-3 sentences.

## Health: 🟢 On Track | 🟡 At Risk | 🔴 Blocked

## Recent Activity
### JIRA
- Issue movements, new issues, closures

### Confluence
- Docs updated, new pages created

### Slack
- Key discussions in project channels

## Risks & Blockers
> [!warning] Blocker description
> Impact and suggested resolution

## Decisions Needed
1. Decision topic — context, who needs to decide

## Next Milestones
- [ ] Milestone 1 — target date

## Action Items
- [ ] Item — owner, deadline
```

---

## People Dossier Template

```markdown
---
type: people-dossier
person: {{FULL_NAME}}
date: {{DATE}}
sources: [{{SOURCES}}]
tags: [chief-of-staff, people]
status: current
last_updated: {{TIMESTAMP}}
---

# {{FULL_NAME}}

## Quick Reference
- **Role**: {{ROLE}}
- **Team/Org**: {{TEAM}}
- **Last interaction**: {{DATE}}

## Recent Interactions
### Email
- Thread summaries

### Slack
- Recent DMs or mentions

### Meetings
- Recent meetings together

### JIRA
- Shared issues or reviews

## Open Items Between You
- [ ] Item — status

## Notes
Free-form notes from past interactions.
```

---

## Decision Log Template

```markdown
---
type: decision-log
date: {{DATE}}
topic: {{TOPIC}}
sources: [{{SOURCES}}]
tags: [chief-of-staff, decision]
status: current
last_updated: {{TIMESTAMP}}
---

# Decision — {{TOPIC}}

## Summary
> What was decided, in one sentence.

## Context
Why this decision was needed.

## Decision
The specific decision made.

## Rationale
Key factors that drove the decision.

## Source Evidence
- Email: thread summary and link
- Slack: message link
- JIRA: issue link

## Follow-Up Actions
- [ ] Action — owner, deadline
```

---

## Action Items Template

```markdown
---
type: action-items
date: {{DATE}}
sources: [{{SOURCES}}]
tags: [chief-of-staff, action-items]
status: current
last_updated: {{TIMESTAMP}}
---

# Action Items — {{DATE}}

## Summary
> N open items across N sources.

## Critical / Urgent
> [!warning]
> - [ ] Item — source, deadline, context

## This Week
- [ ] Item — source, owner, deadline

## Waiting On Others
- [ ] Item — who, since when, context

## Someday / Low Priority
- [ ] Item — source, context

## Completed Recently
- [x] Item — completed {{DATE}}
```
