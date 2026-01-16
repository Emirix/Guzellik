# Proposal: Enhance UI Micro-Interactions

## Overview
This proposal addresses critical UI/UX gaps that prevent the application from achieving a "premium" feel. The current implementation lacks the subtle animations, visual feedback, and polish expected in modern mobile applications. By introducing micro-interactions, improved loading states, and refined visual hierarchies, we can significantly enhance user engagement and perceived quality.

## Why
The application's core functionality is solid, but it lacks the visual polish and micro-interactions that distinguish premium apps from basic implementations. Users expect modern mobile applications to feel responsive, alive, and thoughtfully designed. Without these enhancements:

1. **User Engagement Suffers**: Static interfaces feel dated and unresponsive, reducing time spent in-app
2. **Perceived Quality Drops**: Generic loading spinners and empty states signal a lack of attention to detail
3. **Brand Positioning Weakens**: The gap between design prototypes and implementation undermines the "premium beauty services" positioning
4. **Competitive Disadvantage**: Competing apps with better micro-interactions will feel more professional and trustworthy

This change directly addresses the "Clean, minimal, premium aesthetic" principle defined in `openspec/project.md` by aligning the implementation with the design vision in `design/mekan-detay.html`.

## Problem Statement
Analysis of the current implementation against design prototypes (`design/mekan-detay.html`) reveals several deficiencies:

1. **Static Visual Elements**: The "Open Now" status indicator uses a static dot instead of the designed pulsing animation, reducing visual interest and real-time feel.

2. **Generic Loading States**: Image placeholders and content loading use basic `CircularProgressIndicator` instead of skeleton/shimmer effects, creating a jarring user experience.

3. **Missing Haptic Feedback**: Primary action buttons (Follow, Contact) lack tactile response and visual scale animations on press.

4. **Weak Visual Hierarchy**: Expert cards don't properly emphasize featured specialists, and avatar styling for users without photos lacks depth.

5. **Bland Section Dividers**: Gray boxes between sections feel heavy; design calls for subtle shadows or dashed separators.

6. **Flat Map Preview**: The map preview button lacks the glassmorphic (frosted glass) effect shown in designs.

7. **Poor Empty States**: Missing content (no reviews, no experts) shows plain text instead of branded illustrations with actionable guidance.

## Proposed Changes

### 1. Micro-Animations
- Add pulsing animation to "Open Now" status dot in `WorkingHoursCardV2`
- Implement scale-down animation on button press for primary CTAs
- Add haptic feedback integration for key interactions

### 2. Shimmer Loading States
- Replace `CircularProgressIndicator` with shimmer skeletons in:
  - Gallery image loading (`VenueOverviewV2`, `PhotoGalleryViewer`)
  - Venue card loading in discovery/search screens
  - Expert avatar loading

### 3. Visual Hierarchy Enhancements
- Implement database-driven `is_featured` flag for expert highlighting
- Add gradient overlays to gender-based avatars for depth
- Enhance featured expert border with subtle glow effect

### 4. Refined Dividers & Spacing
- Replace solid gray dividers with subtle shadows or dashed lines
- Implement glassmorphic effect on map preview overlay button

### 5. Empty State Components
- Create branded empty state widgets with:
  - Custom illustrations matching app aesthetic
  - Contextual messaging and CTAs
  - Consistent styling across all empty states

## Expected Impact
- **User Engagement**: Micro-animations and haptic feedback create a more responsive, "alive" interface
- **Perceived Performance**: Shimmer loading reduces perceived wait time vs. spinners
- **Brand Consistency**: Aligns implementation with design prototypes, reinforcing premium positioning
- **User Confidence**: Better visual hierarchy and empty states guide users more effectively

## Verification Plan
1. **Visual QA**: Compare running app against `design/mekan-detay.html` for each modified component
2. **Performance Testing**: Ensure animations run at 60 FPS on mid-range devices
3. **Accessibility Check**: Verify animations can be disabled via system settings (reduce motion)
4. **User Testing**: A/B test key flows (venue discovery, detail viewing) with and without enhancements
