# Proposal: Add Landing Page

Introduce a modern, responsive landing page at the index route (`/`) to showcase the Flutter application, matching its premium aesthetic.

## Why
The current application immediately redirects to the admin panel (`/admin/venues`), lacking a public-facing introduction for potential users or owners.

## Solution
Create a new `LandingPage` component that provides a professional overview of the app's features, benefits, and trust signals. This page will use the existing design system (Pink/Gold/Nude palette) and follow a structure similar to `tasarim.html`.

## What Changes
### Frontend (Panel)
- Create `src/pages/LandingPage.jsx`.
- Update `src/App.jsx` to route `/` to `LandingPage` instead of a redirect.
- Ensure `LandingPage` does not use the `MainLayout` (sidebar) to provide a full-width experience.
- Add necessary assets or generated mockups to `src/assets`.

### Specs
- Add a new capability `landing-page` to define requirements for the index route.

## Impact
- **User Experience**: Improved first impression for visitors.
- **Brand Consistency**: Aligns the web presence with the mobile app's premium feel.
- **SEO**: Provides a landing spot for search engines with descriptive content.
