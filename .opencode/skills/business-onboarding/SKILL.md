---
name: business-onboarding
description: Manages the end-to-end registration and configuration process for new beauty businesses (venues) on the Guzellik platform. Use when adding new salons, clinics, or studios, including their profiles, services, staff, and subscription settings.
---

# Business Onboarding Skill

## When to use this skill
- Registering a new business (venue) manually or via data provided by the user.
- Setting up a business account for a specific user (UID).
- Configuring venue details: services, working hours, specialists, and media.
- Activating premium subscriptions or special features for a business.
- User provides a business card, list of services, or logo/photos for a new salon.

## Onboarding Workflow

### 1. Identify User and Location
Before starting, ensure you have:
- The **UID** of the Auth User who will own the business.
- The **City (Province)** and **District** of the business.
- The **Category** of the business (Beauty Salon, Clinic, Hair Salon, etc.).

**Query Location IDs:**
```sql
SELECT id FROM provinces WHERE name ILIKE '%İzmir%';
SELECT id, name FROM districts WHERE province_id = 35 AND name ILIKE '%Konak%';
```

**Query Category IDs:**
```sql
SELECT id, name FROM venue_categories;
```

### 2. Create/Update Profile
Ensure the profile exists and is marked as a business account.

```sql
UPDATE public.profiles
SET 
  full_name = '[Business Name]',
  business_name = '[Business Name]',
  is_business_account = true,
  province_id = [Province ID],
  district_id = '[District UUID]',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '1 year'
WHERE id = '[User UUID]';
```

### 3. Create Venue
Create the venue entry and link it to the owner.

```sql
INSERT INTO public.venues (
  owner_id, 
  name, 
  category_id, 
  address, 
  province_id, 
  district_id, 
  latitude, 
  longitude, 
  social_links,
  is_active,
  is_verified,
  appointments_enabled
)
VALUES (
  '[User UUID]',
  '[Business Name]',
  '[Category UUID]',
  '[Full Address]',
  [Province ID],
  '[District UUID]',
  [Lat],
  [Lng],
  '{"instagram": "handle", "phone": "90...", "whatsapp": "90..."}'::jsonb,
  true,
  true,
  true
) RETURNING id;
```

*Don't forget to update the profile's `business_venue_id` if it's the primary venue.*

### 4. Manage Services
Check if the services exist in `service_categories`. If not, create them first.

**Check Categories:**
```sql
SELECT id, name FROM service_categories WHERE name ILIKE '%[Service Name]%';
```

**Create Missing Categories (if needed):**
```sql
INSERT INTO service_categories (name, sub_category, venue_category_id, average_duration_minutes, description)
VALUES ('[Name]', '[Subcat]', '[VenueCatID]', [Minutes], '[Description]')
ON CONFLICT (name) DO NOTHING;
```

**Link Services to Venue:**
```sql
INSERT INTO venue_services (venue_id, service_category_id, is_available)
VALUES ('[Venue UUID]', '[ServiceCat UUID]', true);
```

### 5. Add Specialists
Add the staff members providing the services.

```sql
INSERT INTO specialists (venue_id, name, profession, gender, is_active)
VALUES ('[Venue UUID]', '[Name]', '[Title]', '[Gender]', true);
```

### 6. Configure Working Hours
Update the JSONB `working_hours` field in the `venues` table.

```sql
UPDATE public.venues
SET working_hours = '{
  "monday": {"start": "09:00", "end": "19:00", "open": true},
  ...
  "sunday": {"start": "00:00", "end": "00:00", "open": false}
}'::jsonb
WHERE id = '[Venue UUID]';
```

### 7. Media & Gallery
Add images to the centralized media system.

1. **Insert into `media`**:
```sql
INSERT INTO public.media (storage_path, mime_type)
VALUES ('[folder]/[filename].jpg', 'image/jpeg') RETURNING id;
```

2. **Link via `entity_media`**:
```sql
INSERT INTO public.entity_media (media_id, entity_id, entity_type, sort_order)
VALUES ('[Media UUID]', '[Venue/Specialist UUID]', '[venue_gallery/venue_hero/specialist_photo]', [Order]);
```

### 8. Activation (Subscription)
Assign a subscription tier to enable platform features.

```sql
INSERT INTO public.venues_subscription (venue_id, subscription_type, status, expires_at, features)
VALUES (
  '[Venue UUID]',
  'premium',
  'active',
  NOW() + INTERVAL '1 year',
  '{"campaigns": {"enabled": true, "monthly_limit": -1}, ...}'::jsonb
);
```

## Checklist for New Registrations
- [ ] User UID confirmed?
- [ ] Verified location (Province/District) IDs?
- [ ] Business category matches platform types?
- [ ] Services mapped to existing catalog?
- [ ] Working hours match provided info?
- [ ] Contact info (Phone/WhatsApp) verified?
- [ ] Media/Photos added to gallery?
- [ ] Subscription activated?

## Common Commands & Tips
- Always check for existing data before inserts to avoid duplicates.
- Use `mcp_supabase-mcp-server_execute_sql` for all database operations.
- When the user provides an image (business card, screenshot), use your vision capabilities to extract data accurately.
- If a service is unique to the venue, add it with a professional description in Turkish.
