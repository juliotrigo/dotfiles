# Jira

## Writing epic descriptions — keep them evergreen

An epic description should rarely need updates as work progresses. If it requires regular updates, the wrong content is in it. Specifically:

- **Don't include "Already shipped" / "In progress" / "Done" sections** that list individual items by status. They rot the moment something changes.
- **Don't reference current Jira ticket statuses** (e.g., "CVF-XXXX, Selected for Development", "in review", "blocked"). Statuses belong on tickets, not in narrative.
- **Don't use temporal framing** like "today the saga deadlocks" or "after Story X ships" — these become stale.

Instead:

- Capture the **structural scope**: the weaknesses, categories, repo split, dependencies between items. These don't change as items ship.
- Phrase **acceptance criteria as outcomes**, not status references ("X is no longer a class of failure" / "Y is observable in Sentry" — not "ticket Z is shipped").
- **Defer status to a source-of-truth doc** — but only if it lives somewhere all readers can access (Confluence, public wiki, committed repo file), not a local working file. If no shared doc exists, defer status to child tickets — they're always reachable from the epic.
- **Cross-cutting concerns** describe relationships between items, not the current state of any one of them.

The same principle applies to story descriptions to a lesser degree — but stories are short-lived enough that some status references are acceptable. Epics live longer and need to stay evergreen.

## Writing story descriptions

Structure stories with these sections in this order:

1. **Summary** — Short paragraph explaining what the story is and why it matters in user-visible or system-observable terms. No implementation details: that includes internal sagas, actions, selectors, reducer flags, class names — not just file paths. If a concept exists only inside the codebase, paraphrase it ("the local connection becoming ready" vs. an internal action constant). Concrete user-relevant quantities (e.g. "30 seconds") and widely-recognised terms (e.g. "ICE restart" for a WebRTC-aware audience) are fine.
2. **Acceptance criteria** — High-level, outcome-oriented bullets describing what "done" looks like to a reader who isn't going to implement it. Same principle as Summary: outcomes are observable from outside the codebase, not from inside it. "Saga X waits for Action Y" is solution-space — replace with the observable outcome ("viewers see other participants' state within ~1s of joining"). Move solution detail to tech notes.
3. **Notes** (optional) — Non-implementation context that doesn't belong in the Summary but matters to a reader: background and history, rationale, prior decisions, caveats, open risks to resolve, and cross-references to related issues. The audience is anyone reading to understand the story (including non-implementers), not specifically the implementer.
4. **Tech notes** (optional) — Implementation details: package lists, config snippets, tables, file paths, verification steps. Anything a reviewer or implementer would need to do the work.

The Notes/Tech notes split is by audience and content type, not importance. Notes is the "why / what's the context / what to watch out for" — readable without intending to build it. Tech notes is the "how to build and verify it" — file paths, endpoints, config, test methods. If a single section would mix both, split it: background and risks go to Notes, the concrete build/verify detail goes to Tech notes. Either section can be omitted when there's nothing concrete to add.

Tech notes are optional. Include them only when they carry information that is not easily discoverable from the codebase or the story itself — e.g. a non-obvious constraint, a specific config snippet, a known root cause, a reference to an existing implementation that's not the obvious one, or verification steps that aren't routine. Do not include reproduction steps already implied by the AC, generic file paths an implementer would find on their own, or "compare X with Y" hints — that's noise. If you don't have something concretely useful to add, omit the section.

## Markdown formatting via the Atlassian MCP plugin

- Do not use `- [ ]` task-list syntax. Jira's markdown converter escapes the brackets into literal `\[ \]` text instead of rendering interactive checkboxes. Use plain `-` bullets for acceptance criteria. (True Jira checkboxes need ADF, not markdown.)
- Do not hard-wrap paragraphs. Jira treats each newline inside a paragraph as a hard line break (emitted as `  \n`), which produces mid-sentence line breaks in the rendered UI. Write paragraphs as a single long line and let Jira wrap at render time. Lists, tables, and headings still need newlines between them.
- Don't include local-only paths in the description (e.g., paths to plan files in your working directory). If a plan or spec is relevant to other readers, link it from a location they can access; otherwise, inline the relevant info in tech notes.
- Reference other Jira issues as Markdown links, not plain text. Write `[PROJ-1234](https://your-site.atlassian.net/browse/PROJ-1234)`, not a bare `PROJ-1234`. This applies to every issue ID mentioned in a description (parent epics, related stories, dependencies). Plain text issue keys are not auto-linked by the MCP markdown converter, so they render as dead text.
