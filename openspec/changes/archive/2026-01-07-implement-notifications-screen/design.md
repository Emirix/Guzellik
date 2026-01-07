# Design: Notifications System

## UI Design

### Theme & Aesthetics
The notifications screen will follow the project's premium aesthetic:
- **Base Color**: White/Cream background.
- **Accent Color**: Soft Pink (`AppColors.primary`) for active tabs and unread dots.
- **Typography**: Inter/Outfit for modern feel.
- **Cards**: Subtle shadows or thin light-grey borders to separate notification items.

### Component Breakdown
1.  **Header**:
    - Custom AppBar with a back button.
    - Title "Bildirimler".
    - Right-side action menu (`...`) for settings or bulk actions.
2.  **Filter Tabs**:
    - Horizontal scrollable bar or segmented control.
    - Options: "Tümü", "Fırsatlar", "Sistem". (Randevular excluded).
    - Active state: Pink background with white text.
    - Inactive state: Gray-bordered button with pink text.
3.  **Date Headers**:
    - Text headers for "Bugün", "Dün", "Geçen Hafta".
    - "Bugün" header includes a "Tümünü Oku" (Mark All as Read) action text on the right.
4.  **Notification List**:
    - `NotificationItem` widget:
        - Leading icon: Circular background (Nude/Pink) with relevant icon.
        - Content: Title (Bold), Body (Max 2 lines), Timestamp.
        - Trailing: Red unread dot.
        - Action: Inline action text (e.g., "Fırsatı Gör").
5.  **Swipe Actions**:
    - Dismissible background with a red "trash" icon on the right for deleting.

## Architecture

### Data Model
```dart
enum NotificationType { opportunity, system }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
}
```

### Database Schema
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL, -- 'opportunity', 'system'
  is_read BOOLEAN DEFAULT FALSE,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for fast user-specific lookups
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
```

### Notification Logic
- **Real-time Updates**: Using Supabase real-time subscriptions to update the list instantly when a new notification arrives.
- **Push Integration**: When a push notification arrives via FCM (handled in `NotificationService`), if the app is foreground, we manually inject it into the `NotificationProvider` list or let real-time handle it.

## Navigation Logic
- Notifications can contain a `venue_id` or `link` in the `metadata`.
- Tapping a notification will trigger `NotificationProvider.markAsRead(id)` and then navigation.
