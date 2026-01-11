# Tasks: Add Venue FAQ Section

1. [x] Create `FaqSectionV2` widget in `lib/presentation/widgets/venue/v2/faq_section_v2.dart`.
    - Include `FaqItemV2` sub-widget.
    - Implement expansion logic.
    - Apply premium styling.
2. [x] Update `VenueOverviewV2` in `lib/presentation/widgets/venue/v2/venue_overview_v2.dart`.
    - Import `FaqSectionV2`.
    - Add `FaqSectionV2` to the `ListView` after the reviews section.
    - Pass `venue.faq` to the widget.
3. [x] Verify implementation.
    - Run the app and check a venue with FAQ data.
    - Ensure the section is hidden for venues without FAQ.
    - Verify expansion animation and styling.
