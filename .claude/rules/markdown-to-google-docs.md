# Markdown to Google Docs

When asked to convert a Markdown document to Google Docs, the goal is to produce a doc that matches the user's styling preferences as closely as possible — not to hand off a half-finished file for the user to clean up.

## Target styling

The Google Doc the user wants:

- **Body text:** Lato font, Medium weight.
- **Headings/titles:** Lato font, Bold weight.
- **Colours:** keep whatever colours come from the conversion — don't override to black or anything else.
- **Inline code** (from Markdown backticks): monospace font, **same font size as the body text** (not smaller).
- **Headings stay as headings** (don't flatten to bold paragraphs).

## Workflow

1. **Convert with pandoc** (installed via Homebrew) using the reference template at `~/.claude/templates/google-docs-reference.docx`. The template is configured with: Normal style → Lato Medium; Heading 1/2/3 → Lato + bold + the default pandoc accent-blue colour; Verbatim Char (inline code) → Roboto Mono with no size override (so it inherits body size).
   ```
   pandoc <input>.md --reference-doc ~/.claude/templates/google-docs-reference.docx -o /tmp/<output>.docx
   ```
   **Use the space-separated form** of `--reference-doc` (not `--reference-doc=~/...`). With the `=` form the shell doesn't expand `~`, so pandoc receives a literal tilde and fails with "File not found." If you need the `=` form, use `"$HOME/..."` instead.

   If the template needs further adjustment (e.g. Google Docs imports a font as a different weight than expected), edit `word/styles.xml` inside the .docx and re-zip. The template was built by editing pandoc's default reference doc (`pandoc --print-default-data-file reference.docx`) — that's the starting point for any rebuild.
2. **Move the .docx into the repo's `tmp/` folder** before handing off, if the repo has a gitignored `tmp/`. Otherwise leave it in `/tmp/`. The point is to keep the binary out of `git status`.
3. **Hand-off path for the user:**
   - Upload the .docx to Google Drive
   - Right-click → Open with → Google Docs
   - **File → Save as Google Docs** — this is the step that creates a native Google Doc; just opening the .docx in Google Docs is not the same thing.
   - Delete the .docx originals afterwards
4. **Spot-check** the converted doc against the .md source and against the styling targets above before the user shares it.

## Known issues with default pandoc output

These have NOT come through correctly in past conversions with the default invocation. They are the items a `--reference-doc` template (or alternative converter) should fix:

- **Inline code** comes through with a monospace font (good) but at a smaller font size than the body text (not wanted). The reference doc's `Source Code` / `Verbatim Char` style should set the size to match body text.
- **Tables** don't render cleanly in Google Docs after the .docx import. A reference doc may not be enough — investigate whether a pandoc table flag, a different converter (e.g. an MD-to-Google-Docs tool), or post-conversion rebuild in Google Docs is the cleanest fix.

## Things that DO come through correctly with default pandoc

No special handling needed for these:

- **Internal links** (e.g. `[CVF-9842](https://...)`).
- **Headings, bold, lists, paragraph text.**

## Heading bookmarks (default behaviour, kept on purpose)

Pandoc emits a bookmark per heading in the .docx output by default (via its `auto_identifiers` extension), and these bookmarks survive into the Google Doc — visible as a small bookmark icon next to each heading on hover. **This is intentional, not a bug to suppress.** They enable Google Docs' "Copy link to this section" feature and any markdown internal links of the form `[text](#section-id)`.

If a specific conversion has cosmetic concerns about the bookmarks AND you've verified the source has no internal heading links or explicit `{#id}` heading attributes, you can opt out per-doc with `pandoc -f markdown-auto_identifiers ...`. **Don't make this the default** — it silently breaks any future internal heading links.

## When taking on a conversion task

The template at `~/.claude/templates/google-docs-reference.docx` exists and is the default starting point. If it doesn't match the styling needs for a given conversion (different fonts, weights, sizes, colours), rebuilding or extending it is in scope as part of the task — agree the new styling with the user first, then update `word/styles.xml` inside the template and re-zip. Don't fall back to the default pandoc invocation just to ship faster: the manual cleanup it imposes on the user is exactly what the template exists to avoid.
