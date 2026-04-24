---
description: Extract specifications for a feature from Figma
---

# Extract Figma Specifications

You are extracting Figma specifications for a feature. Follow this process:

**Task:** Extract specifications for feature at `docs/agents/plans/{{arg1}}/`

**Steps:**

1. **Read and understand context.md**
   - Path: `docs/agents/plans/{{arg1}}/context.md`
   - Identify ALL Figma URLs (typically contain `figma.com` and a `node-id` parameter)
   - Parse out node IDs from URLs (format: `node-id=1234:5678`)
   - **Before extracting, understand:**
     - Component structure (what parts make up each component - e.g., main button + dropdown)
     - Variant naming conventions (e.g., "Menu/Hover" = dropdown hovered, not main button)
     - Known differences between similar components (e.g., "Button A has no disabled state")
   - If any of the above are unclear, ask the user before proceeding

2. **Extract specifications for each component**

   **IMPORTANT:** You MUST call ALL FOUR tools (a-d) for EACH Figma URL. Do not skip any tool or only extract "representative samples" - extract specs for every component/variant listed.

   **IMPORTANT:** Extract BOTH leaf components AND their parent containers. Parent frames define layout relationships (gaps, alignment) that are essential to the design. Use `get_metadata` on a node to see its parent hierarchy, then extract specs for parent frames that define layout (e.g., frames with gaps, padding, or alignment).

   For each Figma URL found:

   a. **Run `get_metadata`:** (structure & dimensions)
   ```
   mcp__figma__get_metadata(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="[determine from project]",
     clientFrameworks="[determine from project]"
   )
   ```
   This returns: `<frame id="..." name="..." x="0" y="0" width="200" height="48" />`
   Use for: Node IDs, names, x/y positions, width/height, component hierarchy (most reliable source for dimensions)

   b. **Run `get_design_context`:** (layout & composition)
   ```
   mcp__figma__get_design_context(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="[determine from project]",
     clientFrameworks="[determine from project]"
   )
   ```
   This returns: Code snippet with layout classes (e.g., `px-[24px] py-[12px]`)
   Use for: Layout structure, padding values, **gaps between children** (look for `gap-[Npx]`), how elements compose together

   c. **Run `get_variable_defs`:** (design tokens)
   ```
   mcp__figma__get_variable_defs(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="[determine from project]",
     clientFrameworks="[determine from project]"
   )
   ```
   This returns: `{"color/primary": "#3b82f6", "spacing/base": "16", ...}`
   Use for: Actual color hex values, typography specs, spacing/padding values, design token names

   d. **Run `get_screenshot`:** (visual verification)
   ```
   mcp__figma__get_screenshot(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]"
   )
   ```
   This returns: Visual screenshot of the component
   Use for: Verifying extracted values match visual appearance, catching discrepancies

   **After running all tools, extract these values:**
   - Height/Width/Position from `get_metadata`
   - Layout composition, padding, **and gaps** from `get_design_context`
   - Colors (hex), typography, spacing values from `get_variable_defs`
   - Visual confirmation from `get_screenshot`

3. **Populate specification tables**
   Update (if exists) or create `docs/agents/plans/{{arg1}}/components_specs.md`, **always replacing values with freshly extracted Figma data** — never assume existing values are correct, even if marked as "✅ MCP verified". This means re-running ALL FOUR tools for EVERY Figma URL listed in the context document, even if you believe you already have the data from earlier in the conversation. The purpose of this command is to produce a verified-from-source specs document — skipping extractions because "the data hasn't changed" defeats that purpose. If the file already exists, compare freshly extracted values against existing ones and note any discrepancies in the completion report (step 5).

   **Critical review (REQUIRED):** After extracting all data, cross-reference values across extraction levels before writing the specs. For example, compare parent component tokens against child sub-node tokens — they may differ (e.g., a menu item's `get_variable_defs` may show one icon colour, but extracting the icon sub-node separately may reveal a different token). When values conflict between levels, trust the sub-node token values as the source of truth for individual element properties (e.g., exact colours), and use screenshots for layout and visibility (what's shown vs hidden, positioning, element presence). Screenshots can be misleading for subtle colour differences — e.g., `#C4C8CC` grey vs `#48AAC6` blue on a dark background may look similar at small sizes. Document the discrepancy and explain which value applies to the actual implementation and why. Mark all discrepancies with ⚠️ in the specs document — even resolved ones — so they remain visible to whoever reads the specs later.

   **Required sections:**
   - **Layout Structure:** Gaps/spacing between major sections (e.g., Header → Content → Footer)
   - **Component Specs:** Individual component dimensions, colors, padding

   **For each section:**
   - Document extracted values in tables
   - Mark verification status as "✅ MCP verified"
   - Document any values that couldn't be extracted (mark as "⚠️ Needs verification")

   **Layout Structure example:**
   | Between | Gap |
   |---------|-----|
   | Section A → Section B | 0px |
   | Section B → Section C | 10px |

4. **Handle uncertainties**
   If any measurements are unclear or missing:
   - Mark as "⚠️ Needs Auto-Layout verification"
   - Note what specific information is missing (with ⚠️) so the user can verify in Figma

5. **Report completion**
   Summarize:
   - How many components were processed
   - What measurements were successfully extracted
   - Layout relationships documented
   - Any values that changed from a previous extraction (old value → new value)
   - Any that need manual verification

**Example usage:** `/extract-specs feature-name`

**Important notes:**
- **Always extract parent container specs** for layout context (gaps, alignment between children)
- Border-box model: height includes padding
- All four tools can be called in parallel for efficiency

**Verification guidelines:**
- **Never trust existing documentation** - Always verify with fresh Figma data, even if components_specs.md already has values marked as "verified"
- **Verify ALL related tables together** - When verifying one table (e.g., Button/Hover states), verify ALL sibling tables in that section too (e.g., Button/Active, Button/Disabled). Don't leave some tables unverified.
- **`get_variable_defs` returns ALL tokens** - It lists every color/token in the component but doesn't indicate which element uses which. Use screenshots to confirm which token applies to which element.
- **Compare states side-by-side** - When extracting Hover vs Active states, compare screenshots directly. Visual differences are easier to spot than comparing hex values.
- **Flag incomplete state coverage** - If Figma provides Hover but not Active (or vice versa), mark with ⚠️ and note whether to infer from patterns or ask the designer
- **Instance vs component dimensions** - `get_design_context` shows the base component's dimensions (e.g., `w-[350px]`), but `get_metadata` shows the actual instance dimensions (e.g., `width="248"`). Always use `get_metadata` for the real size of a specific instance in a design - base component dimensions may differ from how the component is actually used.
- **Generic templates with multiple component types** - When a Figma node contains multiple similar-looking component variants (e.g., "Menu Header" vs "Dropdown Header" with different backgrounds), the extracted data shows all variants but won't indicate which one applies to your specific use case. Mark with ⚠️ and note the ambiguity in the report. Ask for explicit component-to-element mapping or additional links to the specific component definitions in the design system before assuming which variant applies.
- **Hidden layers in component variants** - `get_design_context` returns the full component tree, including elements that may be hidden or have visibility toggled off in certain variants. Do NOT assume all children shown in the code are visible. Always cross-check against the screenshot for each variant to confirm which elements are actually rendered. When a component has multiple variants (e.g., camera on vs off, expanded vs collapsed), compare screenshots side by side to identify which elements appear or disappear between variants.
- **Icon identification** - When the design includes icon components (e.g., Figma names like `Icons/something`), do NOT just describe them generically (e.g., "a screen icon"). Instead, search the project's icon library (e.g., `node_modules/@fortawesome/*/`) for icons whose names match the Figma icon name, then record the exact library identifier in the spec (e.g., `faPresentationScreen`). Similar-looking icons are indistinguishable at small sizes — a generic description like "screen icon" is ambiguous and leads to the wrong icon being used. If multiple candidates match, list them all and mark with ⚠️ for visual comparison during implementation.
- **SVG path extraction from asset URLs** - `get_design_context` renders ALL vectors (including SVG icons) as `<img src={assetUrl} />` references. Do NOT assume these are raster images. The asset URLs (e.g., `https://www.figma.com/api/mcp/asset/...`) frequently return actual SVG markup with exact `<path d="...">` data. Before marking any icon or vector as "needs manual export from Figma," **fetch the asset URL with WebFetch** to check if it returns SVG content. Only mark as needing manual export if the URL returns a raster image (PNG/JPG). Record the extracted `<path d="...">` values and their `viewBox` dimensions in the specs document so they can be used directly in implementation.
