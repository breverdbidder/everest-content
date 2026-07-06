---
priority: low
status: resolved_by_memory_override
owner: ariel
blocker: Settings>Profile is user-editable only (no Claude tool exists)
dependency: none
minutes: 1
tags: [preferences, hygiene]
---
# userPreferences — two-line correction (authorized Jul 6 2026, applied via memory override)

Memory rule #16 already treats these as corrected in every session. If/when you want the
physical file to match, replace the two stale lines in Settings > Profile > user preferences:

REPLACE: "**DEFAULT MODEL: Claude Sonnet 4.5** (1M token context window)" and its 3 bullet lines
WITH:    "MODEL: whatever is selected in the UI — Claude never suggests model switches."

REPLACE: "- 20 minutes/day oversight maximum"
WITH:    "- ~10 hours/day active product-owner oversight; deep review of every deliverable."
