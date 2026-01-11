# Spec Delta: Web Admin Panel

## ADDED Requirements

### Requirement: Admin Panel Project Structure
**GIVEN** the need for a web-based admin panel  
**WHEN** the project is set up  
**THEN** it SHALL be created as a separate React project in the `admin/` directory with:
- React framework (Vite or Next.js)
- Supabase client for authentication and data
- Responsive design matching Flutter app aesthetic
- Component-based architecture

#### Scenario: Project initialization
- Admin panel is in `admin/` folder at project root
- Separate `package.json` and dependencies
- Independent build and deployment
- Shares Supabase project with Flutter app

---

### Requirement: Admin Panel Authentication
**GIVEN** a business user wants to access the admin panel  
**WHEN** they navigate to the admin panel URL  
**THEN** the system SHALL:
- Check for existing Supabase session
- Verify user has `is_business_account = true`
- Verify user owns a venue
- Redirect to login if not authenticated

#### Scenario: Authenticated business user
- User has valid Supabase session
- User has `is_business_account = true`
- User is directed to dashboard
- Venue data is loaded

#### Scenario: Unauthenticated user
- User has no Supabase session
- User is redirected to login page
- After login, user is redirected back to dashboard

#### Scenario: Non-business user attempting access
- User is authenticated but `is_business_account = false`
- Access is denied
- Error message is displayed
- User is redirected to public site

---

### Requirement: Admin Panel Layout
**GIVEN** a business user is viewing the admin panel  
**WHEN** the main layout is rendered  
**THEN** it SHALL include:
- **Sidebar** with navigation menu
- **Header** with user info and logout
- **Main content area** for current page
- **Responsive design** for mobile and desktop

#### Scenario: Sidebar navigation
- Sidebar shows menu items:
  - Dashboard
  - Kampanyalar (Campaigns)
  - Randevular (Appointments)
  - Uzmanlar (Specialists)
  - Galeri (Gallery)
  - Bildirimler (Notifications)
  - Ayarlar (Settings)
- Active page is highlighted
- Icons match Flutter app style

---

### Requirement: Dashboard Page
**GIVEN** a business user is viewing the dashboard  
**WHEN** the page loads  
**THEN** it SHALL display:
- Business statistics (total appointments, reviews, followers)
- Recent appointments list
- Recent reviews
- Quick actions (create campaign, send notification)

#### Scenario: Dashboard with data
- Stats cards show real numbers from database
- Recent appointments show last 5 bookings
- Recent reviews show last 5 reviews
- Quick action buttons are functional

---

### Requirement: Campaign Management
**GIVEN** a business user wants to manage campaigns  
**WHEN** they navigate to Kampanyalar page  
**THEN** they SHALL be able to:
- View list of all campaigns
- Create new campaign
- Edit existing campaign
- Delete campaign
- Set campaign active/inactive status

#### Scenario: Creating a campaign
- User clicks "Yeni Kampanya" button
- Form is displayed with fields:
  - Title
  - Description
  - Discount percentage
  - Start date
  - End date
  - Image upload
- User fills form and submits
- Campaign is saved to database
- User sees success message

---

### Requirement: Appointment Management
**GIVEN** a business user wants to manage appointments  
**WHEN** they navigate to Randevular page  
**THEN** they SHALL be able to:
- View list of all appointments
- Filter by status (pending, confirmed, completed, cancelled)
- Update appointment status
- View appointment details

#### Scenario: Viewing appointments
- Page displays appointments in table/card format
- Each appointment shows:
  - Customer name
  - Service
  - Date and time
  - Status
  - Actions (confirm, cancel, complete)

---

### Requirement: Specialist Management
**GIVEN** a business user wants to manage their team  
**WHEN** they navigate to Uzmanlar page  
**THEN** they SHALL be able to:
- View list of all specialists
- Add new specialist
- Edit specialist information
- Upload specialist photo
- Remove specialist

#### Scenario: Adding a specialist
- User clicks "Uzman Ekle" button
- Form is displayed with fields:
  - Name
  - Title/Role
  - Experience (years)
  - Photo upload
  - Bio/Description
- User fills form and submits
- Specialist is added to venue's expert_team
- Photo is uploaded to Supabase Storage

---

### Requirement: Gallery Management
**GIVEN** a business user wants to manage venue photos  
**WHEN** they navigate to Galeri page  
**THEN** they SHALL be able to:
- View all venue photos
- Upload new photos (up to 5)
- Reorder photos via drag-and-drop
- Delete photos
- Set primary/hero image

#### Scenario: Uploading photos
- User clicks "Fotoğraf Yükle" button
- File picker is displayed
- User selects image(s)
- Images are uploaded to Supabase Storage
- Thumbnails are generated
- Photos are added to venue's hero_images

---

### Requirement: Notification Management
**GIVEN** a business user wants to send notifications  
**WHEN** they navigate to Bildirimler page  
**THEN** they SHALL be able to:
- View notification history
- Create new notification
- Send notification to all followers
- Schedule notification for later

#### Scenario: Sending a notification
- User clicks "Bildirim Gönder" button
- Form is displayed with fields:
  - Title
  - Message
  - Send immediately or schedule
- User fills form and submits
- Notification is sent to all followers via FCM
- Notification is saved to history

---

### Requirement: Settings Page
**GIVEN** a business user wants to manage venue settings  
**WHEN** they navigate to Ayarlar page  
**THEN** they SHALL be able to:
- Edit venue basic information (name, description, address)
- Update working hours
- Manage payment options
- Update social links
- Edit accessibility information

#### Scenario: Updating venue information
- User edits venue name
- User clicks "Kaydet" button
- Changes are saved to database
- User sees success message
- Changes are reflected in Flutter app

---

### Requirement: Admin Panel URL Configuration
**GIVEN** the admin panel needs to be accessed from Flutter app  
**WHEN** the configuration is set up  
**THEN** the admin panel URL SHALL be:
- Stored in `lib/config/admin_config.dart`
- Easily changeable for different environments
- Include venue ID as query parameter when opened

#### Scenario: Configuration file structure
```dart
class AdminConfig {
  static const String adminPanelUrl = 'https://admin.guzellikharitam.com';
  // For development: 'http://localhost:5173'
  
  static String getAdminUrl(String venueId) {
    return '$adminPanelUrl/dashboard?venue=$venueId';
  }
}
```

---

### Requirement: Responsive Design
**GIVEN** the admin panel is accessed from different devices  
**WHEN** the viewport size changes  
**THEN** the layout SHALL adapt:
- Desktop: Sidebar visible, multi-column layout
- Tablet: Collapsible sidebar, two-column layout
- Mobile: Hidden sidebar (hamburger menu), single-column layout

#### Scenario: Mobile view
- Sidebar is hidden by default
- Hamburger menu icon in header
- User taps icon to show sidebar
- Content takes full width

---

### Requirement: Design Consistency
**GIVEN** the admin panel design  
**WHEN** compared to the Flutter app  
**THEN** it SHALL maintain:
- Same color palette (nude, soft pink, cream, gold)
- Similar typography
- Consistent spacing and padding
- Matching button styles
- Same border radius and shadows

#### Scenario: Visual consistency
- Primary color matches Flutter app
- Buttons have same rounded corners
- Cards have same shadow style
- Font family is consistent
