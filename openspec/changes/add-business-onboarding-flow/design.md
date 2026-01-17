# Design: Business Account Onboarding Flow

## Architecture Overview

This feature introduces a guided onboarding experience for converting regular user accounts to business accounts. The implementation spans UI, state management, and backend integration.

## Component Structure

### 1. UI Components

#### ProfileScreen Enhancement
- **Location**: `lib/presentation/screens/profile_screen.dart`
- **Change**: Add "İşletme Hesabına Geç" button in the menu list
- **Placement**: After settings group, before logout button
- **Condition**: Only show if `!authProvider.isBusinessAccount`

```dart
// Pseudo-code structure
if (!authProvider.isBusinessAccount) {
  BusinessAccountPromptCard(
    onTap: () => context.push('/business-onboarding'),
  )
}
```

#### BusinessOnboardingScreen
- **Location**: `lib/presentation/screens/business/business_onboarding_screen.dart`
- **Purpose**: Container for the onboarding carousel
- **Components**:
  - PageView for carousel
  - Dot indicators
  - "Devam Et" / "Atla" buttons

#### OnboardingStep Widget
- **Location**: `lib/presentation/widgets/business/onboarding_step.dart`
- **Purpose**: Reusable widget for each onboarding step
- **Props**:
  - `title`: String
  - `description`: String
  - `iconData`: IconData
  - `gradient`: LinearGradient (optional)

#### BusinessInfoFormScreen
- **Location**: `lib/presentation/screens/business/business_info_form_screen.dart`
- **Purpose**: Collect business name and type
- **Components**:
  - TextFormField for business name
  - DropdownButtonFormField for business type
  - Submit button
  - Form validation

### 2. State Management

#### BusinessOnboardingProvider
- **Location**: `lib/presentation/providers/business_onboarding_provider.dart`
- **Responsibilities**:
  - Track current onboarding step
  - Store form data (business name, type)
  - Handle form validation
  - Trigger account conversion
  - Manage loading/error states

```dart
class BusinessOnboardingProvider extends ChangeNotifier {
  int _currentStep = 0;
  String? _businessName;
  String? _businessType;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> convertToBusinessAccount() async {
    // Call repository
    // Create subscription
    // Update profile
  }
}
```

### 3. Data Layer

#### BusinessRepository Enhancement
- **Location**: `lib/data/repositories/business_repository.dart`
- **New Method**: `convertToBusinessAccount()`

```dart
Future<void> convertToBusinessAccount({
  required String userId,
  required String businessName,
  required String businessType,
}) async {
  // 1. Update profiles table
  await _supabase
    .from('profiles')
    .update({'is_business_account': true})
    .eq('id', userId);

  // 2. Create subscription
  await _supabase
    .from('business_subscriptions')
    .insert({
      'profile_id': userId,
      'subscription_type': 'trial',
      'status': 'active',
      'expires_at': DateTime.now().add(Duration(days: 365)),
      'features': {
        'campaigns': true,
        'analytics': true,
        'team_management': true,
        'priority_support': true,
      },
    });

  // 3. Store business info temporarily
  // (Will be used when creating venue)
  await _supabase
    .from('profiles')
    .update({
      'business_name': businessName,
      'business_type': businessType,
    })
    .eq('id', userId);
}
```

#### VenueCategoryRepository
- **Location**: `lib/data/repositories/venue_category_repository.dart`
- **Purpose**: Fetch venue categories for dropdown
- **Method**: `getActiveCategories()`

```dart
Future<List<VenueCategory>> getActiveCategories() async {
  final response = await _supabase
    .from('venue_categories')
    .select()
    .eq('is_active', true)
    .order('name');
  
  return (response as List)
    .map((json) => VenueCategory.fromJson(json))
    .toList();
}
```

## Database Schema Updates

### profiles table
Add temporary fields to store business info before venue creation:

```sql
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS business_name TEXT,
ADD COLUMN IF NOT EXISTS business_type UUID REFERENCES venue_categories(id);
```

These fields will be used to pre-fill venue creation form later.

### business_subscriptions table
Add 'trial' subscription type:

```sql
ALTER TABLE business_subscriptions
DROP CONSTRAINT IF EXISTS business_subscriptions_subscription_type_check;

ALTER TABLE business_subscriptions
ADD CONSTRAINT business_subscriptions_subscription_type_check
CHECK (subscription_type IN ('trial', 'standard', 'premium', 'enterprise'));
```

## Navigation Flow

```
/profile
  ↓ (tap "İşletme Hesabına Geç")
/business-onboarding
  ↓ (complete carousel)
/business-info-form
  ↓ (submit form)
  → convertToBusinessAccount()
  ↓ (success)
/business-dashboard (or /venue-setup)
```

### Router Configuration
```dart
// In app_router.dart
GoRoute(
  path: '/business-onboarding',
  builder: (context, state) => const BusinessOnboardingScreen(),
),
GoRoute(
  path: '/business-info-form',
  builder: (context, state) => const BusinessInfoFormScreen(),
),
```

## Design System Integration

### Colors
- **Primary CTA**: `AppColors.primary` (#e23661)
- **Background**: `AppColors.backgroundLight` / `AppColors.backgroundDark`
- **Accent**: `AppColors.gold` for premium highlights
- **Text**: Standard text colors from theme

### Typography
- **Onboarding Titles**: 24px, Bold
- **Onboarding Descriptions**: 16px, Regular
- **Form Labels**: 14px, Medium
- **Button Text**: 16px, Bold

### Spacing
- **Card Padding**: 20px
- **Section Spacing**: 24px
- **Button Height**: 56px
- **Border Radius**: 20px (cards), 12px (inputs)

### Animations
- **Carousel Transition**: 300ms ease-in-out
- **Button Press**: Scale 0.95, 100ms
- **Page Transition**: Slide from right, 250ms

## Error Handling

### Form Validation
- Business name: Required, min 2 characters, max 100 characters
- Business type: Required selection

### Network Errors
- Show SnackBar with error message
- Allow retry
- Don't navigate away on error

### Database Errors
- Rollback transaction if any step fails
- Log error for debugging
- Show user-friendly message

## Testing Strategy

### Unit Tests
- `BusinessOnboardingProvider` state management
- Form validation logic
- Repository methods

### Widget Tests
- OnboardingStep rendering
- Form input validation
- Button states (enabled/disabled)

### Integration Tests
- Complete onboarding flow
- Account conversion success
- Error handling scenarios

## Performance Considerations

### Lazy Loading
- Load venue categories only when form screen is reached
- Cache categories in provider

### Image Optimization
- Use vector icons (Material Icons) for onboarding steps
- No heavy images in carousel

### State Management
- Dispose provider when leaving flow
- Clear form data on success

## Accessibility

### Screen Reader Support
- Semantic labels for all interactive elements
- Announce page changes in carousel
- Form field hints and error messages

### Touch Targets
- Minimum 48x48 logical pixels for all buttons
- Sufficient spacing between interactive elements

### Color Contrast
- Ensure WCAG AA compliance for text
- Use semantic colors for error states

## Security Considerations

### Input Validation
- Sanitize business name input
- Validate category ID against database

### Authorization
- Verify user is authenticated before conversion
- Check user doesn't already have business account

### Transaction Safety
- Use database transactions for atomic operations
- Rollback on any failure

## Future Enhancements

### Phase 2 (Out of Current Scope)
- Add business logo upload during onboarding
- Collect additional business details (address, phone)
- Email verification for business accounts
- Welcome email with getting started guide

### Phase 3 (Future)
- A/B test different onboarding messages
- Track onboarding completion rate
- Add video tutorials in carousel
- Personalized recommendations based on business type
