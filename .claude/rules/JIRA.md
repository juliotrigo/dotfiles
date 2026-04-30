# Jira

## Writing story descriptions

Structure stories with these sections in this order:

1. **Summary** — Short paragraph explaining what the story is and why it matters. No implementation details.
2. **Acceptance criteria** — High-level, outcome-oriented bullets describing what "done" looks like to a reader who isn't going to implement it. Avoid technical specifics (package names, config keys, file paths) — those belong in tech notes.
3. **Tech notes** (optional) — Implementation details: package lists, config snippets, tables, file paths, verification steps. Anything a reviewer or implementer would need to do the work.

Tech notes are optional. Include them only when they carry information that is not easily discoverable from the codebase or the story itself — e.g. a non-obvious constraint, a specific config snippet, a known root cause, a reference to an existing implementation that's not the obvious one, or verification steps that aren't routine. Do not include reproduction steps already implied by the AC, generic file paths an implementer would find on their own, or "compare X with Y" hints — that's noise. If you don't have something concretely useful to add, omit the section.

## Markdown formatting via the Atlassian MCP plugin

- Do not use `- [ ]` task-list syntax. Jira's markdown converter escapes the brackets into literal `\[ \]` text instead of rendering interactive checkboxes. Use plain `-` bullets for acceptance criteria. (True Jira checkboxes need ADF, not markdown.)
- Do not hard-wrap paragraphs. Jira treats each newline inside a paragraph as a hard line break (emitted as `  \n`), which produces mid-sentence line breaks in the rendered UI. Write paragraphs as a single long line and let Jira wrap at render time. Lists, tables, and headings still need newlines between them.
- Don't include local-only paths in the description (e.g., paths to plan files in your working directory). If a plan or spec is relevant to other readers, link it from a location they can access; otherwise, inline the relevant info in tech notes.
