# Project Context

## Purpose

**Güzellik Hizmetleri Platformu** - A comprehensive mobile application that aggregates beauty salons, aesthetic clinics, and similar service providers across Turkey into a single platform.

### Primary Goals
- Connect women seeking beauty and aesthetic services with verified service providers
- Provide location-based discovery through interactive map view
- Enable detailed venue exploration with comprehensive information
- Facilitate direct communication between users and venues
- Build trust through reviews, certifications, and verification badges
- Allow venues to engage with followers through push notifications

### Target Audience
- **Primary Users**: Women in Turkey seeking beauty and aesthetic services
- **Service Providers**: Beauty salons, aesthetic clinics, nail studios, hair salons, solarium centers, and foot care specialists

## Tech Stack

### Frontend
- **Framework**: Flutter (cross-platform mobile development)
- **State Management**: Provider / Riverpod
- **UI Components**: Custom widgets organized by function (Header, Navbar, Cards, etc.)

### Backend
- **Database & Auth**: Supabase (PostgreSQL-based BaaS)
- **Real-time Features**: Supabase Realtime
- **Storage**: Supabase Storage (for images, logos, certificates)

### Notifications
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **In-App Notifications**: Supabase + local state management

### Maps & Location
- **Map Integration**: Google Maps API
- **Geolocation**: Flutter geolocator package
- **Address Services**: Google Places API (optional)

### Additional Services
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Deep Linking**: Firebase Dynamic Links (for sharing venues)

## Project Conventions

### Code Style

#### File Organization
```
lib/
├── config/
│   └── app_config.dart          # Single source for app name, logos, branding
├── core/
│   ├── constants/
│   ├── theme/
│   │   ├── app_colors.dart      # Nude, soft pink, cream, gold palette
│   │   └── app_theme.dart
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── header.dart
│   │   │   ├── navbar.dart
│   │   │   ├── bottom_nav.dart
│   │   │   └── trust_badges.dart
│   │   ├── venue/
│   │   └── service/
│   └── providers/
└── main.dart
```

#### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Private members**: Prefix with `_`

#### Widget Organization
- Separate widgets by responsibility (Header, Navbar, Cards, Buttons, etc.)
- Create reusable components in `widgets/common/`
- Domain-specific widgets in respective folders (`venue/`, `service/`)
- Keep widgets focused and single-purpose

#### Branding Management
- **Single Source of Truth**: `lib/config/app_config.dart`
- All app names, logos, and branding assets referenced from this file
- Easy updates without touching multiple files

### Architecture Patterns

#### Clean Architecture Layers
1. **Presentation Layer**: UI widgets, screens, state management
2. **Domain Layer**: Business logic, use cases, entities
3. **Data Layer**: Repositories, data sources, API clients

#### State Management
- Use Provider/Riverpod for state management
- Separate UI state from business logic
- Implement proper loading, error, and success states

#### Repository Pattern
- Abstract data sources behind repository interfaces
- Implement Supabase-specific repositories
- Enable easy testing and future migrations

#### Service Pattern
- Dedicated services for:
  - Authentication (`AuthService`)
  - Notifications (`NotificationService`)
  - Location (`LocationService`)
  - Storage (`StorageService`)

### Testing Strategy

#### Unit Tests
- Test business logic and utilities
- Mock external dependencies (Supabase, Firebase)
- Aim for >70% coverage on core logic

#### Widget Tests
- Test custom widgets in isolation
- Verify UI behavior and user interactions
- Test theme variations (light/dark mode)

#### Integration Tests
- Test critical user flows:
  - Venue search and filtering
  - Map-based discovery
  - Follow/unfollow venues
  - Notification delivery
- Test Supabase integration with test database

### Git Workflow

#### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Urgent production fixes

#### Commit Conventions
Follow conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `refactor:` Code refactoring
- `style:` UI/styling changes
- `docs:` Documentation
- `test:` Testing
- `chore:` Maintenance tasks

Example: `feat: add venue follow functionality with push notifications`

## Domain Context

### Venue Types
The platform supports six primary venue categories:
1. **Güzellik Salonları** (Beauty Salons)
2. **Solaryum** (Solarium Centers)
3. **Kuaför** (Hair Salons)
4. **Tırnak Stüdyoları** (Nail Studios)
5. **Estetik Klinikleri** (Aesthetic Clinics)
6. **Ayak Bakım** (Foot Care)

### Service Categories & Examples

#### Saç (Hair)
- Kesim, Boya, Keratin, Kaynak, Perma

#### Cilt Bakımı (Skin Care)
- Hydrafacial, Peeling, Leke Tedavisi, Akne Tedavisi

#### Tırnak (Nails)
- Manikür, Protez Tırnak, Kalıcı Oje

#### Estetik (Aesthetics)
- Botoks, Dolgu, Lazer Epilasyon, PRP, Mezoterapi

#### Vücut (Body)
- Masaj, Zayıflama, Selülit Tedavisi

#### Kaş-Kirpik (Brows & Lashes)
- Microblading, Laminasyon, Lifting

### Trust & Verification System

#### Güven Rozetleri (Trust Badges)
- **Onaylı Mekan**: Verified venue with confirmed credentials
- **En Çok Tercih Edilen**: Most preferred based on user engagement
- **Hijyen Onaylı**: Hygiene certified

### Venue Information Structure

Each venue profile includes:
- Basic info (name, logo, description, address, phone)
- Visual gallery (photos, before/after comparisons)
- Social links (Instagram, WhatsApp)
- Working hours (daily schedule, public holidays)
- Expert team profiles (staff photos, names, experience)
- Certifications and documents
- Payment options (cash, credit card, installments)
- Accessibility info (parking, public transport, disability access)
- Reviews and ratings
- FAQ section

### User Engagement Features

#### Follow System
- Users can follow venues
- Venues can send in-app and push notifications to followers
- Notification preferences managed by users

#### Filtering & Discovery
- Service-based filtering (e.g., "Botoks + Jawline")
- Location-based search via map
- Category filtering
- Rating/review filtering

### Design Language

#### Color Palette
- **Primary**: Nude, Soft Pink, Cream tones
- **Accent**: Gold details (premium feel)
- **Base**: White dominant (cleanliness + trust)
- **Supporting**: Subtle gradients for depth

#### Design Principles
- Clean, minimal, premium aesthetic
- **Design Source of Truth**: Always use the files in the `design/` folder as the primary reference for UI implementations.
- Emphasis on trust and professionalism
- Easy navigation and discovery
- Visual hierarchy with gold accents

## Important Constraints

### Technical Constraints
- **Platform**: Mobile-first (iOS & Android via Flutter)
- **Offline Support**: Limited - map and core features require internet
- **Image Optimization**: Required for before/after galleries
- **Geolocation**: Must request and handle location permissions properly
- **Push Notifications**: Require user opt-in, respect notification preferences

### Business Constraints
- **Target Market**: Turkey only (Turkish language, Turkish locations)
- **User Base**: Primarily women seeking beauty services
- **Venue Verification**: Manual approval process for trust badges
- **Content Moderation**: Reviews and venue content must be moderated

### Regulatory Constraints
- **KVKK Compliance**: Turkish data protection law (similar to GDPR)
- **Medical Services**: Aesthetic clinics may require special disclaimers
- **User Privacy**: Location data must be handled securely
- **Payment Processing**: If implemented, must comply with Turkish financial regulations

### Performance Constraints
- **Map Performance**: Optimize marker clustering for many venues
- **Image Loading**: Lazy loading for galleries, thumbnail optimization
- **Database Queries**: Efficient geospatial queries for nearby venues
- **Notification Limits**: Prevent spam, implement rate limiting

## External Dependencies

### Core Services
- **Supabase**: Database, authentication, real-time subscriptions, storage
- **Firebase Cloud Messaging**: Push notifications
- **Google Maps Platform**: Maps, geocoding, places

### Optional/Future Services
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Error monitoring
- **Sentry**: Alternative error tracking
- **Cloudinary/ImageKit**: Advanced image optimization
- **Algolia**: Enhanced search capabilities
- **Stripe/Iyzico**: Payment processing (future feature)

### Development Tools
- **Flutter SDK**: Mobile framework
- **Dart**: Programming language
- **Android Studio / VS Code**: IDEs
- **Supabase CLI**: Database migrations and management
- **Firebase CLI**: Firebase service configuration

### Third-Party Packages (Expected)
- `supabase_flutter`: Supabase client
- `firebase_messaging`: FCM integration
- `google_maps_flutter`: Map integration
- `geolocator`: Location services
- `provider` / `riverpod`: State management
- `cached_network_image`: Image caching
- `image_picker`: Photo uploads
- `url_launcher`: External links (WhatsApp, Instagram)
- `share_plus`: Sharing venues
- `flutter_local_notifications`: Local notification handling
