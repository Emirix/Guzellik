# Design: Venue FAQ Section

## Overview
The FAQ section will be integrated into the `VenueOverviewV2` widget. It will follow the established design patterns of the "redesign-v2" effort, characterized by clean lines, premium typography, and subtle micro-interactions.

## UI Components

### 1. FaqSectionV2 (New Widget)
- **Container**: Padding symmetrical with other sections (20px horizontal).
- **Title**: "Sıkça Sorulan Sorular" using the standard section header style (Size 18, Bold, AppColors.gray900).
- **List**: A `ListView.separated` or a `Column` with spacing between items.
- **Item**: `FaqItemV2` widget.

### 2. FaqItemV2 (New Widget)
- **Structure**: A container with a light border or subtle background.
- **Header**: The question text (Bold) and an expand/collapse icon.
- **Content**: The answer text (Regular, AppColors.gray600), visible only when expanded.
- **Animation**: Smooth expansion/collapse animation.

## Data Integration
- **Source**: `venue.faq` which is a `List<dynamic>`.
- **Parsing**: Since it's `dynamic`, each item will be cast to `Map<String, dynamic>` to extract `question` and `answer`.

## Styling
- **Colors**: Use `AppColors.gray900` for questions, `AppColors.gray600` for answers, and `AppColors.primary` for icons.
- **Spacing**: 12px between title and list; 12px between items.
- **Border**: Use `AppColors.gray100` or `AppColors.nude` for separators.
