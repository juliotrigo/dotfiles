You are extracting Figma specifications for a feature. Follow this process:

**Task:** Extract specifications for feature at `docs/agents/plans/{{arg1}}/`

**Steps:**

1. **Read and understand context.md**
   - Path: `docs/agents/plans/{{arg1}}/context.md`
   - Identify all Figma URLs
   - Parse out node IDs from URLs (format: `node-id=1234:5678`)
   - **Before extracting, understand:**
     - Component structure (what parts make up each component - e.g., main button + dropdown)
     - Variant naming conventions (e.g., "Menu/Hover" = dropdown hovered, not main button)
     - Expected output format (what data points to capture)
     - Known differences between similar components (e.g., "Audio has no green state")
   - If any of the above are unclear, ask the user before proceeding

2. **Extract specifications for each component**

   **IMPORTANT:** You MUST call ALL FOUR tools (a-d) for EACH Figma URL. Do not skip any tool or only extract "representative samples" - extract specs for every component/variant listed.

   **IMPORTANT:** Extract BOTH leaf components AND their parent containers. Parent frames define layout relationships (gaps, alignment) that are essential to the design.

   For each Figma URL found:

   a. **Run get_metadata:** (structure & dimensions)
   ```
   mcp__figma__get_metadata(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="typescript",
     clientFrameworks="react-native"
   )
   ```
   This returns: `<frame id="..." name="..." x="0" y="0" width="1194" height="56" />`
   Use for: Node IDs, names, x/y positions, width/height, component hierarchy

   b. **Run get_design_context:** (layout & composition)
   ```
   mcp__figma__get_design_context(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="typescript",
     clientFrameworks="react-native"
   )
   ```
   This returns: React component with Tailwind classes like `px-[24px] py-[12px]`
   Use for: Layout structure, padding values, **gaps between children**, how elements compose together

   c. **Run get_variable_defs:** (design tokens)
   ```
   mcp__figma__get_variable_defs(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="typescript",
     clientFrameworks="react-native"
   )
   ```
   This returns: `{"Blues/Soho Blue -3": "#b6d7ed", "Padding/base": "16", ...}`
   Use for: Actual color hex values, typography specs, spacing/padding values, design token names

   d. **Run get_screenshot:** (visual verification)
   ```
   mcp__figma__get_screenshot(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]"
   )
   ```
   This returns: Visual screenshot of the component
   Use for: Verifying extracted values match visual appearance, catching discrepancies

   e. **Extract values:**
   - Height/Width/Position from get_metadata
   - Layout composition, padding, **and gaps** from get_design_context
   - Colors (hex), typography, spacing VALUES from get_variable_defs
   - Visual confirmation from get_screenshot

3. **Populate specification tables**
   Update or create the "component_specifications.md" document in the same path:

   **Required sections:**
   - **Layout Structure:** Gaps/spacing between major sections (Header → Content → Footer)
   - **Component Specs:** Individual component dimensions, colors, padding
   - Fill in "Figma" rows with extracted values
   - Mark verification status as "✅ MCP verified"
   - Document any values that couldn't be extracted (mark as "⚠️ Needs verification")

   **Layout Structure example:**
   | Between | Gap |
   |---------|-----|
   | Header → Thumbnails | 0px |
   | Thumbnails → Content | 0px |
   | Content → Footer | 10px |

4. **Handle uncertainties**
   If any measurements are unclear or missing:
   - Mark as "⚠️ Needs Auto-Layout verification"
   - Ask user to provide screenshot of Figma Auto-Layout panel

5. **Report completion**
   Summarize:
   - How many components were processed
   - What measurements were successfully extracted
   - Layout relationships documented
   - Any that need manual verification

**Example usage:** `/extract-specs feature-name`

**Important notes:**
- Always extract from individual component URLs, not full page URLs
- **Always extract parent container specs** for layout context (gaps, alignment between children)
- **get_metadata**: Most reliable for dimensions and positions (x, y, width, height)
- **get_design_context**: Essential for layout composition; look for `gap-[Npx]` between siblings
- **get_variable_defs**: Essential for actual color hex values and typography specs
- **get_screenshot**: Essential for visual verification; catches discrepancies between extracted values and actual appearance
- Border-box model: height includes padding
- All four tools can be called in parallel for efficiency
- If context.md describes component structure or variant naming, read it carefully before extracting

**Verification guidelines:**
- **Never trust existing documentation** - Always verify with fresh Figma data, even if component_specifications.md already has values marked as "verified"
- **get_variable_defs returns ALL tokens** - It lists every color/token in the component but doesn't indicate which element uses which. Use screenshots to confirm which token applies to which element.
- **Compare states side-by-side** - When extracting Hover vs Active states, compare screenshots directly. Relative brightness differences (white vs gray) are easier to spot than absolute hex values.
- **Flag incomplete state coverage** - If Figma provides Hover but not Active (or vice versa), mark with ⚠️ and note whether to infer from patterns or ask the designer
