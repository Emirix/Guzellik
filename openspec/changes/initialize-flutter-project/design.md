## Context

This is the foundational setup for a Flutter-based beauty services aggregator platform targeting the Turkish market. The application will connect women seeking beauty and aesthetic services with verified service providers through location-based discovery, detailed venue profiles, and direct communication channels.

### Background
- **Platform**: Mobile-first (iOS & Android)
- **Target Market**: Turkey
- **Primary Users**: Women seeking beauty services
- **Service Providers**: Beauty salons, aesthetic clinics, nail studios, etc.

### Constraints
- Must support offline-capable features where possible
- Requires efficient geospatial queries for map-based discovery
- Must handle image-heavy content (galleries, before/after photos)
- Must comply with KVKK (Turkish data protection law)
- Limited budget for third-party services initially

### Stakeholders
- End users (women seeking services)
- Venue owners (service providers)
- Development team
- Future investors/stakeholders

## Goals / Non-Goals

### Goals
- ✅ Create production-ready Flutter project structure
- ✅ Implement clean architecture with clear separation of concerns
- ✅ Set up scalable backend integration (Supabase)
- ✅ Enable push notifications from day one (Firebase)
- ✅ Support location-based features (Google Maps)
- ✅ Centralize branding management for easy updates
- ✅ Establish consistent design system with defined color palette
- ✅ Enable rapid feature development with reusable widgets
- ✅ Set up proper testing infrastructure

### Non-Goals
- ❌ Payment processing integration (future feature)
- ❌ Advanced analytics beyond basic Firebase Analytics
- ❌ Multi-language support (Turkish only for MVP)
- ❌ Web or desktop versions
- ❌ Complex offline synchronization (basic caching only)

## Decisions

### 1. State Management: Provider/Riverpod

**Decision**: Use Provider or Riverpod for state management.

**Rationale**:
- Officially recommended by Flutter team
- Simpler learning curve than BLoC
- Sufficient for app complexity level
- Good performance characteristics
- Easy to test and mock

**Alternatives Considered**:
- **BLoC**: More boilerplate, steeper learning curve, overkill for current needs
- **GetX**: Less community support, mixing concerns (navigation + state)
- **MobX**: Additional code generation complexity

### 2. Backend: Supabase

**Decision**: Use Supabase as the primary backend service.

**Rationale**:
- PostgreSQL-based (powerful relational database)
- Built-in authentication and authorization
- Real-time subscriptions for live updates
- Storage for images and files
- Row-level security for data protection
- Generous free tier
- Good Flutter SDK support

**Alternatives Considered**:
- **Firebase**: More expensive at scale, NoSQL limitations for complex queries
- **Custom Backend**: Higher development and maintenance cost
- **AWS Amplify**: More complex setup, steeper learning curve

### 3. Notifications: Firebase Cloud Messaging

**Decision**: Use FCM for push notifications.

**Rationale**:
- Industry standard for mobile notifications
- Reliable delivery
- Free for unlimited notifications
- Good Flutter integration
- Works well alongside Supabase

**Alternatives Considered**:
- **OneSignal**: Additional third-party dependency
- **Supabase only**: Limited push notification capabilities

### 4. Maps: Google Maps

**Decision**: Use Google Maps Platform for map features.

**Rationale**:
- Best map data coverage for Turkey
- Familiar UI for users
- Robust geocoding and places API
- Good Flutter package support
- Reasonable pricing for expected usage

**Alternatives Considered**:
- **Mapbox**: Less familiar to Turkish users, similar pricing
- **OpenStreetMap**: Limited geocoding capabilities, requires more setup

### 5. Architecture: Clean Architecture with Repository Pattern

**Decision**: Implement clean architecture with three layers (Presentation, Domain, Data).

**Rationale**:
- Clear separation of concerns
- Testable business logic
- Easy to swap implementations (e.g., switch backend)
- Industry best practice for Flutter apps
- Scales well as app grows

**Structure**:
```
lib/
├── config/          # App-wide configuration
├── core/            # Shared utilities, constants, theme
├── data/            # Data layer (repositories, services, models)
└── presentation/    # UI layer (screens, widgets, providers)
```

### 6. Centralized Branding: app_config.dart

**Decision**: Single source of truth for app name, logos, and branding.

**Rationale**:
- Easy to update branding across entire app
- Prevents inconsistencies
- Supports future white-labeling if needed
- Simple to manage during development

**Implementation**:
```dart
class AppConfig {
  static const String appName = 'Güzellik Platformu';
  static const String appLogo = 'assets/images/logo.png';
  // ... other branding constants
}
```

### 7. Design System: Centralized Theme

**Decision**: Implement comprehensive theme system in `app_theme.dart`.

**Rationale**:
- Consistent UI across entire app
- Easy to maintain and update
- Supports light/dark modes
- Enforces design guidelines

**Color Palette**:
- Primary: Nude, Soft Pink, Cream
- Accent: Gold (premium feel)
- Base: White (cleanliness + trust)

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Screens  │  │ Widgets  │  │Providers │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Entities │  │Use Cases │  │Repository│              │
│  │          │  │          │  │Interfaces│              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │Repository│  │ Services │  │  Models  │              │
│  │   Impl   │  │          │  │          │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│              External Services                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Supabase │  │ Firebase │  │Google Maps│             │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
```

## Data Flow

1. **User Interaction** → Widget triggers action
2. **Provider/State** → Calls use case or repository
3. **Repository** → Abstracts data source
4. **Service** → Communicates with Supabase/Firebase/Google
5. **Response** → Flows back through layers
6. **UI Update** → Provider notifies listeners, widgets rebuild

## Risks / Trade-offs

### Risk: Supabase Vendor Lock-in
- **Mitigation**: Repository pattern abstracts data layer, making it easier to switch backends if needed
- **Trade-off**: Accepting some lock-in for faster development and lower costs

### Risk: Google Maps Pricing
- **Mitigation**: Implement map clustering to reduce API calls, cache geocoding results
- **Trade-off**: May need to switch to alternative if usage exceeds budget

### Risk: Firebase Free Tier Limits
- **Mitigation**: Monitor usage, implement notification batching
- **Trade-off**: May need to upgrade to paid plan as user base grows

### Risk: Complex State Management
- **Mitigation**: Start simple with Provider, can migrate to Riverpod if needed
- **Trade-off**: May need refactoring if state becomes too complex

### Risk: Image Storage Costs
- **Mitigation**: Implement image compression, use Supabase storage efficiently
- **Trade-off**: May need CDN in future for better performance

## Migration Plan

N/A - This is the initial setup. Future migrations will be documented in subsequent changes.

## Rollback Plan

If critical issues arise:
1. Revert to empty Flutter project
2. Re-evaluate architecture decisions
3. Create new proposal with adjusted approach

## Testing Strategy

### Unit Tests
- Test services in isolation with mocked dependencies
- Test repository implementations
- Test business logic in providers

### Widget Tests
- Test individual widgets with mock data
- Test user interactions
- Test theme variations

### Integration Tests
- Test complete user flows
- Test backend integration with test Supabase project
- Test navigation between screens

## Performance Considerations

### Image Loading
- Use `cached_network_image` for efficient caching
- Implement lazy loading for galleries
- Compress images before upload

### Map Performance
- Implement marker clustering for many venues
- Lazy load venue details
- Cache geocoding results

### Database Queries
- Use Supabase indexes for geospatial queries
- Implement pagination for large result sets
- Cache frequently accessed data

## Security Considerations

### Authentication
- Use Supabase Auth with secure token storage
- Implement proper session management
- Handle token refresh automatically

### Data Protection
- Implement row-level security in Supabase
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Comply with KVKK requirements

### API Keys
- Store API keys in environment variables
- Never commit keys to version control
- Use different keys for dev/staging/prod

## Open Questions

1. **State Management**: Should we start with Provider or go directly to Riverpod?
   - **Recommendation**: Start with Provider for simplicity, migrate if needed

2. **Navigation**: Should we use named routes or go_router?
   - **Recommendation**: go_router for better type safety and deep linking support

3. **Image Optimization**: Should we use a CDN like Cloudinary from the start?
   - **Recommendation**: Start with Supabase Storage, add CDN if performance becomes an issue

4. **Internationalization**: Should we set up i18n infrastructure even though we're Turkish-only for MVP?
   - **Recommendation**: Yes, minimal setup now will make future expansion easier

5. **Analytics**: Beyond Firebase Analytics, do we need additional tracking?
   - **Recommendation**: Start with Firebase Analytics, add more sophisticated tools later if needed
