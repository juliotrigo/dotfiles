You are extracting Figma specifications for a feature. Follow this process:

**Task:** Extract specifications for feature at `docs/agents/plans/{{arg1}}/`

**Steps:**

1. **Read context.md**
   - Path: `docs/agents/plans/{{arg1}}/context.md`
   - Identify all Figma URLs
   - Parse out node IDs from URLs (format: `node-id=1234:5678`)

2. **Extract specifications for each component**
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
   Use for: Layout structure, padding values, how elements compose together

   c. **Run get_variable_defs:** (design tokens)
   ```
   mcp__figma__get_variable_defs(
     fileKey="[extract from URL]",
     nodeId="[extract from URL]",
     clientLanguages="typescript",
     clientFrameworks="react-native"
   )
   ```
   This returns: `{"Blues/Soho Blue -3": "#b6d7ed", "Padding/base": "16", "iOS/Header 3": "Font(family: \"Roboto\", size: 16, weight: 400, lineHeight: 100)"}`
   Use for: Actual color hex values, typography specs, spacing/padding values, design token names

   d. **Extract values:**
   - Height/Width/Position from get_metadata
   - Layout composition and padding from get_design_context
   - Colors (hex), typography, spacing VALUES from get_variable_defs

3. **Populate specification tables**
   Update or create the "Component Specifications" section in context.md:
   - Fill in "Figma" rows with extracted values
   - Mark verification status as "✅ MCP `get_metadata` verified"
   - Document any values that couldn't be extracted (mark as "⚠️ Needs verification")

4. **Handle uncertainties**
   If any measurements are unclear or missing:
   - Mark as "⚠️ Needs Auto-Layout verification"
   - Ask user to provide screenshot of Figma Auto-Layout panel

5. **Report completion**
   Summarize:
   - How many components were processed
   - What measurements were successfully extracted
   - Any that need manual verification

**Example usage:** `/extract-specs header`

**Important notes:**
- Always extract from individual component URLs, not full page URLs
- **get_metadata**: Most reliable for dimensions and positions (x, y, width, height)
- **get_design_context**: Best for understanding layout composition; may show `size-full` instead of explicit heights (that's expected)
- **get_variable_defs**: Essential for actual color hex values and typography specs; gives clean token→value mapping
- Border-box model: height includes padding
- All three tools can be called in parallel for efficiency
