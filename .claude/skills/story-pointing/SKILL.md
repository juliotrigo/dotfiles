---
name: story-pointing
description: >
  How to estimate Jira story points (Fibonacci, 5 ≈ one day, including review, testing, QA
  and UAT) and which tickets must not be pointed. Use only when asked to point, estimate,
  size or re-point Jira stories, tasks or bugs. Not for general Jira editing.
---

# Story pointing

## Scale

- Fibonacci only: 1, 2, 3, 5, 8, 13, 21, 34, 55.
- **5 points ≈ one day's work** for one person. Rough equivalents: 3 ≈ half a day,
  8 ≈ 1.5 days, 13 ≈ 2.5 days, 21 ≈ 4 days, 34 ≈ 7 days, 55 ≈ 11 days.
- Points cover **everything needed to finish the ticket**, not just writing code:
  implementation, unit tests, code review rounds, manual testing and QA (e.g. drop tests on
  a dev environment), UAT when the change needs it, documentation the ticket asks for, and
  the overhead of cross-repo changes (extra PRs, releases, coordinated deploys).
- **In doubt between two numbers, use the bigger one.**
- Anything estimated at 34 or more is a candidate for splitting. Say so, but still point it
  unless told to split first.

## What not to point

- **Subtasks.** Only stories, tasks and bugs carry points.
- **Done items.** Never point or re-point them.
- **In-progress items.** Leave their existing points alone, even if they are clearly wrong
  in hindsight. Mention it if asked, but do not change the value.
- Epics, and plan rows that have no ticket.

## How to do it

1. List the candidate tickets (e.g. the epic's children) with their status and current
   points, and drop everything excluded above.
2. **Read every ticket in full** before estimating — summary, acceptance criteria, notes
   and tech notes. Do not estimate from the title or from memory of an older version.
3. For each ticket, account for: which repos it touches, whether a library release is
   involved, test effort, how hard it is to reproduce and QA, and whether UAT is needed.
4. **Propose before writing.** Show a table with ticket, current points, proposed points
   and a one-line reason, plus the total. Call out large jumps from existing values and
   anything worth splitting. Wait for approval.
5. Apply only the approved values, then re-query the tickets to confirm they were saved.

## Jira field

The Story Points field ID differs per Jira site. Find it first: fetch one ticket with the
full view and look under custom fields.
