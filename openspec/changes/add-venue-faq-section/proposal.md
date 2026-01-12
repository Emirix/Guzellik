# Proposal: Add Venue FAQ Section

## Summary
Implement a dynamic "Frequently Asked Questions" (SSS - Sıkça Sorulan Sorular) section in the venue details profile. This section will display questions and answers fetched dynamically from the `faq` field in the `Venue` model, providing users with quick answers to common queries about a venue.

## Motivation
Users often have common questions about venues (e.g., parking, specific services, cancellation policies). Providing a dedicated FAQ section improves user experience by delivering this information proactively and reduces the need for direct inquiries.

## What Changes
### Frontend (Flutter)
- Update `VenueOverviewV2` to include a new FAQ section.
- Create a new widget `FaqSectionV2` to display a list of expandable FAQ items.
- Ensure the section is only visible if the venue has FAQ data.
- Maintain premium aesthetic consistency with existing sections (About, Experts, Reviews).

### Database
- No changes required as the `faq` field already exists in the `venues` table (as a JSONB array of objects with `question` and `answer` keys).

### Data Model
- No changes required as the `Venue` model already includes the `faq` field.

## Design Decisions
- **Expandable Items**: Use an accordion-style (expansion tile) pattern for FAQ items to keep the UI clean while allowing users to access detailed answers.
- **Dynamic Visibility**: The section will be hidden if `venue.faq` is empty or null.
- **Section Order**: Place the FAQ section after the Reviews section in the `VenueOverviewV2` scrollable list.
