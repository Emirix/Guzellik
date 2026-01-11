# Proposal: Build Admin Panel

## What
Build a standalone React-based admin panel named "Güzellik Haritam" for managing venue (business) data in the system. The panel will allow administrators to create and edit venues with full control over all venue attributes including basic information, location, working hours, services, specialists, photos, and subscription details.

## Why
Currently, venue management is done through the mobile app's business owner interface, which is limited and not suitable for administrative tasks. A dedicated admin panel is needed to:
- Efficiently onboard new businesses to the platform
- Manage and edit all venue information from a single interface
- Handle bulk operations and data management tasks
- Provide better UX for administrative tasks with drag-and-drop photo management
- Enable customer support to assist venue owners with their profiles

## What Changes
This change introduces a new standalone React application in the `panel/` directory that:
- Provides a comprehensive venue management interface
- Integrates with existing Supabase backend (same instance)
- Supports full CRUD operations on venues and related entities
- Implements drag-and-drop photo upload and ordering
- Maintains design consistency with the existing admin design system

## How
1. **Project Setup**: Initialize a Vite + React + JavaScript project in `panel/` directory with Tailwind CSS
2. **Design System**: Implement the existing admin design language (primary color: #ec3c68, Manrope font, glass-card aesthetics)
3. **Supabase Integration**: Configure Supabase client to connect to the existing database
4. **Venue Management**: Build comprehensive forms for creating and editing venues with all fields from the `venues` table
5. **Related Entities**: Implement management for working hours, services, specialists, and photos
6. **Photo Management**: Implement drag-and-drop upload with ordering capabilities using Supabase Storage
7. **No Authentication**: Skip authentication implementation for initial version (to be added later)

## Scope
**In Scope:**
- React project setup with Vite
- Venue creation and editing UI
- All venue fields management (name, description, address, phone, WhatsApp, location, working hours)
- Services management interface
- Specialists management interface
- Photo upload with drag-and-drop and ordering
- Supabase integration for data and storage
- Subscription information display and basic editing

**Out of Scope:**
- Authentication and authorization (will be added in future iteration)
- User management
- Analytics and reporting
- Bulk import/export features
- Advanced search and filtering (basic search only)
- Mobile responsiveness (desktop-first approach)

## Dependencies
- Existing Supabase instance and database schema
- `venues`, `venue_photos`, `specialists`, `venue_services`, `service_categories` tables
- Supabase Storage bucket for venue photos
- Design reference from `design/yonetim-index.html`

## Risks
- **No Authentication**: Initial version will have no auth, making it accessible to anyone with the URL (acceptable for development/internal use)
- **Schema Changes**: Any future changes to the `venues` table structure will require panel updates
- **Photo Upload Performance**: Large photo uploads may impact UX without proper optimization
- **Data Validation**: Client-side validation only; relies on database constraints for data integrity
