# Change: add-business-account-management

## Status
🟡 **PROPOSED** - Awaiting approval

## Overview
This change introduces comprehensive business account management capabilities to the platform, enabling venue owners to manage their businesses through both a Flutter mobile interface and a web-based admin panel.

## Key Features
- **Business Account Detection**: Automatic detection of business accounts on login
- **Dual Mode System**: Users can switch between normal user and business owner modes
- **Business Navigation**: Dedicated navigation for business features (Profile, Subscription, Store)
- **Subscription Management**: View and manage business subscription details
- **Web Admin Panel**: Full-featured React-based admin panel for business management
- **Premium Features Marketplace**: Store screen for purchasing additional business features

## Affected Specs
- `database-schema` (NEW) - Business account fields and subscriptions table
- `business-authentication` (NEW) - Business account detection and mode selection
- `business-navigation` (NEW) - Business-specific navigation and routing
- `business-subscriptions` (NEW) - Subscription management system
- `web-admin-panel` (NEW) - Web-based admin panel for businesses

## Implementation Phases
1. **Phase 1-3**: Database schema and Flutter data layer (2-3 days)
2. **Phase 4-5**: Authentication and navigation (2-3 days)
3. **Phase 6-8**: UI screens and components (3-4 days)
4. **Phase 9-10**: Web admin panel setup (3-4 days)
5. **Phase 11**: Testing and validation (1-2 days)
6. **Phase 12**: Documentation (1 day)

**Total Estimated Effort**: 12-17 days

## Files Created/Modified

### New Files (Flutter)
- `lib/data/models/business_subscription.dart`
- `lib/core/enums/business_mode.dart`
- `lib/data/repositories/business_repository.dart`
- `lib/data/repositories/subscription_repository.dart`
- `lib/presentation/providers/business_provider.dart`
- `lib/presentation/providers/subscription_provider.dart`
- `lib/presentation/widgets/business/business_mode_dialog.dart`
- `lib/presentation/widgets/common/business_bottom_nav.dart`
- `lib/presentation/widgets/business/subscription_card.dart`
- `lib/presentation/screens/business/subscription_screen.dart`
- `lib/presentation/screens/business/store_screen.dart`
- `lib/config/admin_config.dart`

### Modified Files (Flutter)
- `lib/presentation/providers/auth_provider.dart`
- `lib/presentation/widgets/common/custom_bottom_nav.dart`
- `lib/presentation/screens/profile_screen.dart`
- `lib/core/utils/app_router.dart`

### New Files (Database)
- `supabase/migrations/[timestamp]_add_business_account_fields.sql`
- `supabase/migrations/[timestamp]_create_business_subscriptions.sql`

### New Project (Web Admin)
- `admin/` - Complete React project for web-based admin panel

## Dependencies
- Existing `business_applications` table and approval workflow
- Supabase authentication and RLS policies
- React framework (Vite or Next.js) for admin panel
- `url_launcher` package for opening admin panel from Flutter

## Breaking Changes
None. This change is additive and only affects users with `is_business_account = true`.

## Next Steps
1. Review and approve this proposal
2. Run `/openspec-apply add-business-account-management` to begin implementation
3. Follow task sequence in `tasks.md`

## Related Documents
- [proposal.md](./proposal.md) - Detailed proposal and rationale
- [design.md](./design.md) - Architecture and design decisions
- [tasks.md](./tasks.md) - Implementation task breakdown
- [specs/](./specs/) - Detailed requirements for each capability

## Questions or Concerns?
Please review the proposal and design documents. If you have questions or concerns, discuss them before approving the change.
