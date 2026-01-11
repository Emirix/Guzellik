# Design: Landing Page

## Architecture
The landing page will be a standalone React component within the `panel` Vite project. It will bypass the `MainLayout` used by admin routes to ensure a clean, full-screen marketing experience.

## UI/UX Design
### Visual Theme
- **Primary Color**: `#ec3c68` (Pink) - Used for buttons, icons, and accents.
- **Accent Color**: `#d4af37` (Gold) - Used for trust badges and secondary highlighting.
- **Background**: White/Cream (`#fcfcfc`) for a clean and trustworthy look.
- **Typography**: `Manrope` (as configured in `index.css`).

### Sections
1. **Nav**: Sticky transparent-to-solid navbar with links to features and a "Login/Admin" button.
2. **Hero**: 
   - Left: Compelling headline "Güzelliğin Dijital Adresi" and description.
   - Right: Premium mobile app mockup (generated) with floating trust elements.
3. **Stats**: Quick counters showing scale (e.g., 1000+ Salon, 81 İl, 50k+ Randevu).
4. **Features**: 
   - Discovery (Map-based).
   - Trust (Verified salons).
   - Communication (Direct chat/follow).
   - Notifications (Instant updates).
5. **How It Works**: Simple steps for users and businesses.
6. **Footer**: Social links, contact info, and copyright.

## Responsiveness
- **Desktop**: 2-column hero, 4-column features grid.
- **Tablet**: 2-column features grid.
- **Mobile**: Single-column layout, hamburger menu, stack hero vertically.

## Assets
- Use `generate_image` to create a high-quality mockup showing the Flutter app UI on a modern smartphone.
- Iconography: FontAwesome 6 (already included in `tasarim.html`, will ensure it's available in the project).
