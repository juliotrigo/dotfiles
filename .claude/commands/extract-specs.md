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
   Update (if exists) or create `docs/agents/plans/{{arg1}}/component_specifications.md`:

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
   - Any that need manual verification

**Example usage:** `/extract-specs feature-name`

**Important notes:**
- **Always extract parent container specs** for layout context (gaps, alignment between children)
- Border-box model: height includes padding
- All four tools can be called in parallel for efficiency

**Verification guidelines:**
- **Never trust existing documentation** - Always verify with fresh Figma data, even if component_specifications.md already has values marked as "verified"
- **Verify ALL related tables together** - When verifying one table (e.g., Button/Hover states), verify ALL sibling tables in that section too (e.g., Button/Active, Button/Disabled). Don't leave some tables unverified.
- **`get_variable_defs` returns ALL tokens** - It lists every color/token in the component but doesn't indicate which element uses which. Use screenshots to confirm which token applies to which element.
- **Compare states side-by-side** - When extracting Hover vs Active states, compare screenshots directly. Visual differences are easier to spot than comparing hex values.
- **Flag incomplete state coverage** - If Figma provides Hover but not Active (or vice versa), mark with ⚠️ and note whether to infer from patterns or ask the designer
- **Instance vs component dimensions** - `get_design_context` shows the base component's dimensions (e.g., `w-[350px]`), but `get_metadata` shows the actual instance dimensions (e.g., `width="248"`). Always use `get_metadata` for the real size of a specific instance in a design - base component dimensions may differ from how the component is actually used.
- **Generic templates with multiple component types** - When a Figma node contains multiple similar-looking component variants (e.g., "Menu Header" vs "Dropdown Header" with different backgrounds), the extracted data shows all variants but won't indicate which one applies to your specific use case. Mark with ⚠️ and note the ambiguity in the report. Ask for explicit component-to-element mapping or additional links to the specific component definitions in the design system before assuming which variant applies.
