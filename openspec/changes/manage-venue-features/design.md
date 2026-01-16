# Design: Enhanced Venue Features System

## Architecture

### Data Layer
- **Master Table**: `venue_features` (id, name, slug, icon, category, is_active).
- **Junction Table**: `venue_selected_features` (venue_id, feature_id).
- **Search Column**: `venues.features` (JSONB array of slugs).

We will add a PostgreSQL trigger:
```sql
CREATE OR REPLACE FUNCTION sync_venue_features_to_array()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE venues
  SET features = (
    SELECT jsonb_agg(vf.slug)
    FROM venue_selected_features vsf
    JOIN venue_features vf ON vf.id = vsf.feature_id
    WHERE vsf.venue_id = COALESCE(NEW.venue_id, OLD.venue_id)
  )
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Business Logic
- `VenueFeaturesRepository`: Already exists, but we will add logic to handle the transition from old fields if necessary.
- `AdminFeaturesProvider`: Already exists, will be used by the `AdminFeaturesScreen`.

### UI/UX
- **Venue Profile (`AboutTab`)**:
    - Remove separate "Ödeme Seçenekleri" and "Özellikler" (Accessibility) sections.
    - Replace with a single "İşletme Özellikleri" section.
    - Use `Wrap` of `Chip` widgets.
    - **No icons will be used**; the chips will focus on clean typography.
    - Soft background colors (AppColors.gray50) and subtle borders.

- **Admin Dashboard & Router**:
    - Add a new route `/business/admin/features` to `AppRouter`.
    - Add a new menu item "İşletme Özellikleri" to `AdminDashboardScreen`.
    - Refactor `AdminFeaturesScreen` to remove icon column and checkboxes for a cleaner look.

## Trade-offs
- **Redundancy**: Keeping `venues.features` JSONB array alongside the junction table creates redundancy but is necessary for performant search filtering in Supabase without complex joins.
- **Migration**: Old `accessibility` and `payment_options` fields will be gradually phased out. We will keep them for backward compatibility until all venues are migrated.
