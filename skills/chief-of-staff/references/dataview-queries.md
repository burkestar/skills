# Dataview Queries for Chief of Staff Vault

These are useful Dataview queries the user can add to their Obsidian vault to get dashboards
from the Chief of Staff notes. Include relevant ones as suggestions when creating notes.

## All Open Action Items Across Notes

```dataview
TASK
FROM #chief-of-staff
WHERE !completed
SORT file.name DESC
```

## Recent Daily Briefings

```dataview
TABLE confidence, sources
FROM "Daily Briefings"
WHERE type = "daily-briefing"
SORT date DESC
LIMIT 7
```

## Active Projects by Health

```dataview
TABLE status, confidence, last_updated
FROM "Projects"
WHERE type = "project-status" AND status = "current"
SORT last_updated DESC
```

## Recent Decisions

```dataview
TABLE topic, date, sources
FROM "Decisions"
WHERE type = "decision-log"
SORT date DESC
LIMIT 10
```

## People I've Interacted With Recently

```dataview
TABLE person, last_updated
FROM "People"
WHERE type = "people-dossier"
SORT last_updated DESC
LIMIT 10
```

## Stale Notes (Not Updated in 30+ Days)

```dataview
TABLE type, last_updated
FROM #chief-of-staff
WHERE status = "current" AND date(last_updated) < date(today) - dur(30 days)
SORT last_updated ASC
```

## Upcoming Meeting Preps

```dataview
TABLE meeting_title, attendees, date
FROM "Meetings"
WHERE type = "meeting-prep" AND date >= date(today)
SORT date ASC
```

## Items Waiting on Others

```dataview
TASK
FROM "Weekly Plans"
WHERE contains(text, "Waiting") AND !completed
SORT file.name DESC
```
