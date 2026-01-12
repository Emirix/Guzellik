# Design: Admin Panel Architecture

## Overview
The admin panel is a standalone React application that provides a comprehensive interface for managing venue data. It follows a modular architecture with clear separation of concerns and integrates directly with the existing Supabase backend.

## Architecture

### Technology Stack
- **Framework**: React 18+ with Vite
- **Language**: JavaScript (ES6+)
- **Styling**: Tailwind CSS
- **State Management**: React Context API + Hooks
- **Backend**: Supabase (existing instance)
- **File Upload**: Supabase Storage
- **Routing**: React Router v6

### Project Structure
```
panel/
├── public/
│   └── favicon.ico
├── src/
│   ├── assets/
│   │   └── images/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── Select.jsx
│   │   │   ├── Toast.jsx
│   │   │   └── LoadingSpinner.jsx
│   │   ├── layout/
│   │   │   ├── Sidebar.jsx
│   │   │   ├── Header.jsx
│   │   │   └── MainLayout.jsx
│   │   └── venue/
│   │       ├── VenueForm.jsx
│   │       ├── BasicInfoSection.jsx
│   │       ├── LocationSection.jsx
│   │       ├── WorkingHoursSection.jsx
│   │       ├── ServicesSection.jsx
│   │       ├── SpecialistsSection.jsx
│   │       ├── PhotosSection.jsx
│   │       └── SubscriptionSection.jsx
│   ├── contexts/
│   │   ├── VenueContext.jsx
│   │   └── ToastContext.jsx
│   ├── hooks/
│   │   ├── useSupabase.js
│   │   ├── useVenues.js
│   │   └── useFileUpload.js
│   ├── services/
│   │   ├── supabaseClient.js
│   │   ├── venueService.js
│   │   ├── photoService.js
│   │   └── locationService.js
│   ├── utils/
│   │   ├── validators.js
│   │   └── formatters.js
│   ├── pages/
│   │   ├── VenueList.jsx
│   │   ├── VenueCreate.jsx
│   │   └── VenueEdit.jsx
│   ├── App.jsx
│   └── main.jsx
├── index.html
├── package.json
├── vite.config.js
├── tailwind.config.js
└── README.md
```

## Key Design Decisions

### 1. State Management
**Decision**: Use React Context API instead of Redux/Zustand
**Rationale**: 
- Simpler setup for a focused admin tool
- Sufficient for managing venue form state and UI state
- Reduces bundle size and complexity
- Easy to upgrade to Redux later if needed

### 2. Form Management
**Decision**: Controlled components with custom hooks
**Rationale**:
- Full control over form state and validation
- Better integration with Supabase data structure
- Easier to implement complex multi-step forms
- No additional dependencies (avoiding react-hook-form for simplicity)

### 3. Photo Upload Strategy
**Decision**: Direct upload to Supabase Storage with client-side ordering
**Rationale**:
- Leverages existing Supabase infrastructure
- `venue_photos` table already has `sort_order` field
- Drag-and-drop implemented with HTML5 Drag API or react-beautiful-dnd
- Optimistic UI updates for better UX

### 4. Data Fetching
**Decision**: Custom hooks wrapping Supabase client
**Rationale**:
- Encapsulates Supabase queries in reusable hooks
- Easy to add caching or optimistic updates later
- Keeps components clean and focused on UI
- No need for React Query initially (can add later)

### 5. Routing Strategy
**Decision**: React Router with nested routes
**Rationale**:
- `/venues` - List all venues
- `/venues/create` - Create new venue
- `/venues/:id/edit` - Edit existing venue
- Clean URLs and browser history support

## Component Design

### VenueForm Component
**Purpose**: Main container for venue creation/editing
**Responsibilities**:
- Orchestrate all form sections
- Handle form submission
- Manage loading and error states
- Coordinate with Supabase services

**Props**:
```javascript
{
  venueId?: string,  // undefined for create, UUID for edit
  onSuccess: (venue) => void,
  onCancel: () => void
}
```

### PhotosSection Component
**Purpose**: Manage venue photo gallery
**Features**:
- Drag-and-drop upload zone
- Photo preview grid
- Drag-to-reorder functionality
- Delete photos
- Set hero/cover image

**State**:
```javascript
{
  photos: Array<{id, url, order_index, is_hero}>,
  uploading: boolean,
  uploadProgress: number
}
```

### WorkingHoursSection Component
**Purpose**: Manage venue operating hours
**Features**:
- Day-by-day schedule editor
- Closed/Open toggle per day
- Multiple time slots per day
- Copy schedule to other days

**Data Structure** (matches `venues.working_hours` JSONB):
```javascript
{
  monday: { closed: false, slots: [{open: "09:00", close: "18:00"}] },
  tuesday: { closed: false, slots: [{open: "09:00", close: "18:00"}] },
  // ... other days
}
```

## Data Flow

### Venue Creation Flow
1. User fills out VenueForm sections
2. User uploads photos (immediately stored in Supabase Storage)
3. User clicks "Create Venue"
4. Form validates all fields
5. Create venue record in `venues` table
6. Create related records (services, specialists, photos metadata)
7. Show success toast and redirect to venue list

### Photo Upload Flow
1. User drags/selects photos
2. Client validates file type and size
3. Upload to Supabase Storage bucket `venue-photos`
4. Get public URL from Supabase
5. Create record in `venue_photos` table with URL and order_index
6. Update UI with new photo

### Photo Reordering Flow
1. User drags photo to new position
2. Update local state optimistically
3. Batch update `order_index` for affected photos in `venue_photos` table
4. Show success feedback

## Integration Points

### Supabase Tables Used
- `venues` - Main venue data
- `venue_photos` - Photo gallery
- `venue_services` - Services offered
- `service_categories` - Service catalog
- `specialists` - Team members
- `provinces` - Location data
- `districts` - Location data
- `venue_categories` - Business categories
- `venues_subscription` - Subscription info

### Supabase Storage
- Bucket: `venue-photos`
- Path structure: `{venue_id}/{timestamp}_{filename}`
- Public access for read
- Authenticated access for write (bypassed initially without auth)

## Design System

### Colors (from existing admin design)
```javascript
{
  primary: '#ec3c68',
  secondary: '#1b0e11',
  accent: '#d4af37',
  background: '#fcfcfc',
  backgroundDark: '#1a1113',
}
```

### Typography
- Font Family: 'Manrope', sans-serif
- Headings: Bold, tracking-tight
- Body: Regular, comfortable line-height

### Components Style
- Glass-card effect: `backdrop-filter: blur(12px)`
- Rounded corners: `border-radius: 1.5rem` (24px)
- Shadows: Soft, subtle elevation
- Transitions: Smooth, 300ms ease

## Error Handling

### Strategy
1. **Client-side validation**: Immediate feedback on form fields
2. **Supabase errors**: Catch and display user-friendly messages
3. **Network errors**: Retry mechanism with user notification
4. **Upload errors**: Show per-file error states

### User Feedback
- Toast notifications for success/error
- Inline validation messages
- Loading spinners for async operations
- Disabled states during submission

## Performance Considerations

### Optimizations
- Lazy load venue list (pagination)
- Image thumbnails for photo grid
- Debounced search inputs
- Optimistic UI updates
- Code splitting by route

### Constraints
- Max photo size: 5MB per file
- Max photos per venue: 20
- Image formats: JPEG, PNG, WebP
- Recommended image dimensions: 1920x1080

## Future Enhancements (Out of Scope)
- Authentication with role-based access
- Real-time collaboration (multiple admins)
- Audit log for changes
- Bulk operations (import/export)
- Advanced analytics dashboard
- Mobile responsive design
