---
name: qa-notes
description: >
  How to write QA / manual-testing notes for a story at handoff: choosing the tests that
  matter, keeping instructions realistic and brief, pointing testers at logs, and listing
  known gaps so observations can be matched to them. Use when asked to write QA notes,
  testing notes or a test plan for QA.
---

# QA notes

The reader is a developer or QA engineer with limited time, ordinary hardware and no time
to read the code. Write for them.

## Before writing

- Read the story's acceptance criteria, the PR test plan, and what has already been
  verified (and how).
- Check the prerequisites for the build under test: latest changes deployed, deploy order
  between services, infrastructure the change depends on. Raise gaps with the user; they
  are not the tester's job.
- Collect the known gaps: open tickets for behaviour the tester may hit that the story
  does not fix.
- Find the observability specifics in the project's docs or memory: how log projects map
  to environments, query syntax gotchas, field names, time zone.

## Choosing tests

- List every important thing to test and stop there: each test covers a promise of the
  story, a real risk in the change, or a regression path through neighbouring flows. The
  number depends on the story.
- Order by importance, so a tester who runs out of time has run what matters.
- Do not name a test environment. The story is deployed wherever is free; refer to "the
  environment it is deployed to" and say how to find its logs from that.
- Assume the tester's hardware: one machine, one browser. Make every test work there. If
  extra hardware (a second machine, a colleague) makes a result easier to read, say so as
  an option and say how the expected result differs without it.
- Prefer the simplest way to reproduce (Wi-Fi off over packet filters). Only ask for a
  special tool when there is no alternative, and give the fallback.

## Writing each test

- One line of action with exact values (durations, clicks), then the expected result in
  user-visible terms, then the log that confirms it.
- Make the check unambiguous on the tester's setup (e.g. headphones when two participants
  share one machine, so room audio cannot pass for a working connection).
- Give generous but concrete time bounds ("within about a minute").
- Only state expectations that were verified or follow directly from the code. Say which
  are unverified, or leave them out. Never present an inference as an observed result.
- Say which alternative outcomes still count as a pass.

## Known gaps

- Link each to its ticket, and mark unconfirmed ones "report it if you see it".
- Describe each by the symptom the tester would see and by what is actually wrong
  underneath (e.g. which side of a connection failed), so a surprising observation can be
  matched to a gap instead of being reported as a failure of the story.

## Structure

What changed (1–2 sentences, user terms) · Setup · Tests (most important first) · Known
gaps · Logs (where, exact query, fields, time zone) · If something fails (what to capture
before reloading, where to attach it). No implementation detail. Follow the tracker's
formatting rules.

## Delivery

Default: a comment on the story. Show the draft to the user before posting.
