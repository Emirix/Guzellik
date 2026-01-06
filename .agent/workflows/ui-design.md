---
description: Steps for implementing UI designs based on provided design files
---

1. **Check Design Assets**:
   - List the contents of the `design/` folder to find relevant mockups, HTML templates, or style guides.
   - Use `list_dir` and `view_file` to analyze the design files.

2. **Analyze Design Requirements**:
   - Identify primary and secondary colors.
   - Note typography (font sizes, weights, families).
   - Extract spacing, padding, and layout patterns.
   - Look for specific UI components (buttons, cards, headers) and their states (hover, active).

3. **Map to Flutter Widgets**:
   - Plan how to translate the design into Flutter widgets (`Container`, `Row`, `Column`, `CustomPainter`, etc.).
   - Identify if any new global styles or themes should be added to `lib/core/theme/`.

4. **Iterative Implementation**:
   - Implement the core structure first.
   - Apply styling and details based on the design files.
   - If using `generate_image`, use it for assets but rely on the design folder for the overall structure.

5. **Validation**:
   - Compare the final implementation with the original design files to ensure 1:1 matching.
