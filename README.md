# Güzellik Platformu

A comprehensive mobile application that aggregates beauty salons, aesthetic clinics, and similar service providers across Turkey into a single platform.

## 🎯 Features

- **Map-Based Discovery**: Find nearby beauty venues using interactive maps
- **Detailed Venue Profiles**: View comprehensive information about services, staff, and facilities
- **Service Filtering**: Search by specific services (e.g., "Botoks + Jawline")
- **Follow System**: Follow favorite venues and receive notifications
- **Trust Badges**: Verified venues with hygiene and popularity badges
- **Reviews & Ratings**: Read and write reviews for venues
- **Push Notifications**: Stay updated with offers from followed venues

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **go_router** - Navigation and routing
- **Google Fonts** - Typography (Outfit, Inter)

### Backend & Services
- **Supabase** - Database, authentication, real-time, storage
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Analytics** - User behavior tracking
- **Firebase Crashlytics** - Error monitoring
- **Google Maps** - Maps and location services

## 📁 Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # App branding and constants
│   └── environment_config.dart  # Environment configuration
├── core/
│   ├── constants/               # App-wide constants
│   ├── theme/
│   │   ├── app_colors.dart      # Color palette
│   │   └── app_theme.dart       # Theme configuration
│   └── utils/
│       └── app_router.dart      # Navigation configuration
├── data/
│   ├── models/                  # Data models
│   ├── repositories/            # Repository pattern implementations
│   └── services/
│       ├── supabase_service.dart
│       ├── auth_service.dart
│       ├── notification_service.dart
│       ├── location_service.dart
│       └── storage_service.dart
├── presentation/
│   ├── screens/                 # App screens
│   ├── widgets/
│   │   ├── common/              # Reusable widgets
│   │   ├── venue/               # Venue-specific widgets
│   │   └── service/             # Service-specific widgets
│   └── providers/               # State management providers
└── main.dart                    # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK (3.10.4 or higher)
- Android Studio / VS Code with Flutter extensions
- Supabase account and project
- Firebase project
- Google Maps API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Guzellik
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Update `lib/config/environment_config.dart` with your API keys:
   ```dart
   static const EnvironmentConfig dev = EnvironmentConfig(
     environment: Environment.dev,
     supabaseUrl: 'YOUR_SUPABASE_URL',
     supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
     googleMapsApiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
   );
   ```

4. **Configure Firebase**
   
   Follow the detailed setup guide in [`docs/firebase-setup.md`](docs/firebase-setup.md):
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Configure FCM for push notifications
   - Upload APNs key for iOS notifications

5. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 Design System

### Color Palette
- **Primary**: Nude (#E8D5C4), Soft Pink (#FFC9D9), Cream (#FFFBF5)
- **Accent**: Gold (#D4AF37) - Premium feel
- **Base**: White (#FFFFFF) - Cleanliness and trust

### Typography
- **Headings**: Outfit (Google Font)
- **Body**: Inter (Google Font)

### Design Principles
- Clean, minimal, premium aesthetic
- Emphasis on trust and professionalism
- Easy navigation and discovery
- Visual hierarchy with gold accents

## 🔧 Configuration

### App Branding
All app branding is managed from a single file: `lib/config/app_config.dart`

```dart
class AppConfig {
  static const String appName = 'Güzellik Platformu';
  static const String appTagline = 'Güzelliğiniz için her şey bir arada';
  // ... other branding constants
}
```

### Environment Configuration
Supports dev, staging, and production environments in `lib/config/environment_config.dart`

## 📱 Platform-Specific Setup

### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions: Location, Camera, Storage, Notifications

### iOS
- Minimum iOS: 12.0
- Permissions: Location, Camera, Photos, Notifications

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/widget_test.dart
```

### Run Integration Tests
```bash
flutter test integration_test/
```

## 📦 Building

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔐 Security

- API keys stored in environment configuration (not committed to git)
- Supabase Row Level Security (RLS) for data protection
- HTTPS for all network communications
- KVKK (Turkish GDPR) compliance

## 📄 License

This project is proprietary and confidential.

## 👥 Team

- Development Team
- Design Team
- Product Team

## 📞 Support

For support, email: destek@guzellikplatformu.com

---

**Version**: 1.0.0  
**Last Updated**: January 2026
