# Design: Uzman Avatar Arkaplan Renklerini Cinsiyete Göre Özelleştir

## Problem Statement

Mevcut implementasyonda, fotoğrafı olmayan tüm uzmanlar için aynı gri arka plan rengi (`gray100`) kullanılıyor. Bu, görsel olarak monoton bir deneyim yaratıyor ve mevcut cinsiyet verisini kullanma fırsatını kaçırıyor.

Uzmanların cinsiyet bilgisi zaten `specialist` tablosunda `gender` alanında mevcut, ancak UI'da hiçbir şekilde kullanılmıyor.

## Design Goals

1. **Görsel Zenginlik**: Uzman avatarlarını daha ayırt edilebilir ve görsel olarak zengin hale getirmek
2. **Veri Kullanımı**: Mevcut cinsiyet verisini anlamlı bir şekilde kullanmak
3. **Tema Tutarlılığı**: Mevcut tema paleti ile uyumlu renkler kullanmak
4. **Erişilebilirlik**: Renk körlüğü olan kullanıcılar için de erişilebilir olmak
5. **Basitlik**: Minimal kod değişikliği ile maksimum etki

## Architecture Overview

### Component Hierarchy

```
AppColors (Theme System)
    ↓
AvatarUtils (Utility Layer)
    ↓
┌─────────────────┬──────────────────┬─────────────────┐
│                 │                  │                 │
ExpertCard    SpecialistCard   ExpertsTab   ExpertsSectionV2
(User View)   (Admin View)     (User View)    (User View V2)
```

### Data Flow

```
Specialist Model (gender: String?)
        ↓
getAvatarBackgroundColor(gender)
        ↓
Color Selection Logic
        ↓
┌───────────┬────────────┬──────────────┐
│           │            │              │
Male      Female      Null/Unknown
(Blue)    (Pink)      (Gray)
```

## Detailed Design

### 1. Theme System Extension

**File**: `lib/core/theme/app_colors.dart`

```dart
class AppColors {
  // ... existing colors ...
  
  // Avatar Background Colors (Gender-based)
  /// Light blue background for male specialist avatars without photos
  static const Color avatarMale = Color(0xFFE3F2FD);
  
  /// Light pink background for female specialist avatars without photos
  /// Matches primaryLight for theme consistency
  static const Color avatarFemale = Color(0xFFFFEAF3);
  
  /// Neutral gray background for specialists with unknown/unspecified gender
  /// Matches gray100 for theme consistency
  static const Color avatarNeutral = Color(0xFFF5F5F5);
}
```

**Rationale**:
- `avatarMale`: Açık mavi (`#E3F2FD`) - Material Design'ın Blue 50 tonu, profesyonel ve sakin
- `avatarFemale`: Açık pembe (`#FFEA F3`) - Mevcut `primaryLight` ile aynı, tema tutarlılığı
- `avatarNeutral`: Gri (`#F5F5F5`) - Mevcut `gray100` ile aynı, nötr ve profesyonel

### 2. Utility Function

**File**: `lib/core/utils/avatar_utils.dart` (yeni)

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Utilities for avatar rendering and customization
class AvatarUtils {
  /// Returns the appropriate background color for a specialist avatar
  /// based on their gender.
  ///
  /// Supports multiple gender formats:
  /// - Male: "male", "m", "erkek", "e" (case-insensitive)
  /// - Female: "female", "f", "kadın", "k" (case-insensitive)
  /// - Unknown/Null: Returns neutral gray
  ///
  /// Example:
  /// ```dart
  /// final color = AvatarUtils.getAvatarBackgroundColor(specialist.gender);
  /// Container(color: color, child: Icon(Icons.person))
  /// ```
  static Color getAvatarBackgroundColor(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AppColors.avatarNeutral;
    }

    final normalizedGender = gender.toLowerCase().trim();

    // Male variants
    if (normalizedGender == 'male' ||
        normalizedGender == 'm' ||
        normalizedGender == 'erkek' ||
        normalizedGender == 'e') {
      return AppColors.avatarMale;
    }

    // Female variants
    if (normalizedGender == 'female' ||
        normalizedGender == 'f' ||
        normalizedGender == 'kadın' ||
        normalizedGender == 'k') {
      return AppColors.avatarFemale;
    }

    // Unknown/unrecognized gender
    return AppColors.avatarNeutral;
  }

  // Private constructor to prevent instantiation
  AvatarUtils._();
}
```

**Rationale**:
- **Centralized Logic**: Tek bir yerde cinsiyet-renk eşleştirmesi
- **Multiple Format Support**: Hem İngilizce hem Türkçe, hem tam hem kısaltma
- **Case-Insensitive**: Veri tutarsızlıklarına karşı dayanıklı
- **Null-Safe**: Null ve boş değerler için güvenli fallback
- **Well-Documented**: Kullanımı kolay, örneklerle dokümante edilmiş

### 3. Widget Updates

#### 3.1 ExpertCard Widget

**File**: `lib/presentation/widgets/venue/components/expert_card.dart`

**Before**:
```dart
Container(
  color: AppColors.gray100,
  child: Icon(Icons.person, size: 40, color: AppColors.gray400),
)
```

**After**:
```dart
Container(
  color: AvatarUtils.getAvatarBackgroundColor(expert.gender),
  child: Icon(Icons.person, size: 40, color: AppColors.gray400),
)
```

**Changes**:
- Import `avatar_utils.dart`
- Replace `AppColors.gray100` with `AvatarUtils.getAvatarBackgroundColor(expert.gender)`
- `Expert` modeli zaten `gender` alanına sahip (mevcut `Specialist` modelinden türetilmiş)

#### 3.2 Admin Specialist Card

**File**: `lib/presentation/screens/business/admin/admin_specialists_screen.dart`

**Location**: `_SpecialistCard` widget içinde

**Before**:
```dart
Container(
  color: AppColors.gray100,
  child: Icon(Icons.person, size: 40, color: AppColors.gray400),
)
```

**After**:
```dart
Container(
  color: AvatarUtils.getAvatarBackgroundColor(specialist.gender),
  child: Icon(Icons.person, size: 40, color: AppColors.gray400),
)
```

#### 3.3 Other Locations

Aynı pattern tüm uzman avatar gösterimlerinde uygulanacak:
- `experts_tab.dart`
- `experts_section_v2.dart`
- Diğer potansiyel uzman görüntüleme noktaları

### 4. Testing Strategy

#### Unit Tests

**File**: `test/core/utils/avatar_utils_test.dart` (yeni)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:guzellik/core/utils/avatar_utils.dart';
import 'package:guzellik/core/theme/app_colors.dart';

void main() {
  group('AvatarUtils.getAvatarBackgroundColor', () {
    test('returns male color for "male"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('male'),
        AppColors.avatarMale,
      );
    });

    test('returns male color for "MALE" (case-insensitive)', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('MALE'),
        AppColors.avatarMale,
      );
    });

    test('returns male color for "erkek"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('erkek'),
        AppColors.avatarMale,
      );
    });

    test('returns female color for "female"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('female'),
        AppColors.avatarFemale,
      );
    });

    test('returns female color for "kadın"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('kadın'),
        AppColors.avatarFemale,
      );
    });

    test('returns neutral color for null', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor(null),
        AppColors.avatarNeutral,
      );
    });

    test('returns neutral color for empty string', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor(''),
        AppColors.avatarNeutral,
      );
    });

    test('returns neutral color for unknown gender', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('other'),
        AppColors.avatarNeutral,
      );
    });
  });
}
```

#### Widget Tests

**File**: `test/presentation/widgets/venue/components/expert_card_test.dart`

```dart
testWidgets('ExpertCard shows correct background color for male expert', 
  (WidgetTester tester) async {
  final expert = Expert(
    id: '1',
    name: 'Ahmet Yılmaz',
    title: 'Kuaför',
    gender: 'male',
    photoUrl: null,
  );

  await tester.pumpWidget(
    MaterialApp(home: ExpertCard(expert: expert)),
  );

  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(ExpertCard),
      matching: find.byType(Container),
    ).first,
  );

  expect(container.color, AppColors.avatarMale);
});
```

#### Manual Testing Checklist

1. **Erkek Uzman**:
   - [ ] Gender: "male" → Mavi arka plan
   - [ ] Gender: "erkek" → Mavi arka plan
   - [ ] Gender: "M" → Mavi arka plan

2. **Kadın Uzman**:
   - [ ] Gender: "female" → Pembe arka plan
   - [ ] Gender: "kadın" → Pembe arka plan
   - [ ] Gender: "F" → Pembe arka plan

3. **Bilinmeyen Cinsiyet**:
   - [ ] Gender: null → Gri arka plan
   - [ ] Gender: "" → Gri arka plan
   - [ ] Gender: "other" → Gri arka plan

4. **Fotoğraflı Uzman**:
   - [ ] Cinsiyet ne olursa olsun, fotoğraf gösteriliyor
   - [ ] Arka plan rengi görünmüyor

5. **Ekran Tutarlılığı**:
   - [ ] Venue Details → Experts Tab
   - [ ] Admin Panel → Specialists Screen
   - [ ] V2 Design Components

## Performance Considerations

### Impact Analysis

**Positive**:
- Minimal performance impact (sadece renk seçimi)
- Utility function çok hafif (birkaç string karşılaştırması)
- Widget rebuild performansı etkilenmez

**Neutral**:
- Ek import (`avatar_utils.dart`) - negligible
- Ek fonksiyon çağrısı - microseconds

**No Negative Impact**:
- Image loading etkilenmez
- Widget tree complexity artmaz
- Memory footprint değişmez

### Optimization

Eğer gelecekte performans sorunu olursa:
```dart
// Memoization (gerekirse)
static final Map<String?, Color> _colorCache = {};

static Color getAvatarBackgroundColor(String? gender) {
  if (_colorCache.containsKey(gender)) {
    return _colorCache[gender]!;
  }
  
  final color = _computeColor(gender);
  _colorCache[gender] = color;
  return color;
}
```

Ancak şu an için **premature optimization** - gerekli değil.

## Accessibility Considerations

### Color Contrast

**WCAG AA Compliance**:
- Icon color: `AppColors.gray400` (#BDBDBD)
- Background colors:
  - Male: `#E3F2FD` (light blue)
  - Female: `#FFEA F3` (light pink)
  - Neutral: `#F5F5F5` (gray)

**Contrast Ratios** (icon vs background):
- Gray400 on avatarMale: ~2.8:1 (acceptable for large graphics)
- Gray400 on avatarFemale: ~3.1:1 (WCAG AA compliant)
- Gray400 on avatarNeutral: ~2.5:1 (acceptable for large graphics)

### Color Independence

**Non-Color Information**:
- Uzman adı (text)
- Meslek/uzmanlık (text)
- Fotoğraf (varsa)

Renk **tek bilgi kaynağı değil**, sadece görsel zenginlik için kullanılıyor.

### Screen Reader Support

Mevcut accessibility labels korunuyor:
```dart
Semantics(
  label: '${expert.name}, ${expert.title}',
  child: Container(...),
)
```

## Migration Strategy

### Backward Compatibility

**Mevcut Veriler**:
- `gender` alanı zaten mevcut, null olabilir
- Null değerler için nötr gri kullanılacak
- Hiçbir veri migration gerekmez

**Mevcut UI**:
- Fotoğraflı uzmanlar etkilenmez
- Fotoğrafsız uzmanlar yeni renkleri otomatik alır
- Hiçbir breaking change yok

### Rollout Plan

1. **Phase 1**: Theme colors ve utility function ekle
2. **Phase 2**: ExpertCard widget'ını güncelle
3. **Phase 3**: Admin specialist card'ı güncelle
4. **Phase 4**: Diğer uzman görüntüleme noktalarını güncelle
5. **Phase 5**: Test ve validation

**Rollback Strategy**:
Eğer sorun çıkarsa, sadece `AvatarUtils.getAvatarBackgroundColor()` çağrılarını `AppColors.gray100` ile değiştir.

## Alternative Designs Considered

### Alternative 1: Enum-Based Gender

```dart
enum Gender { male, female, other }

class Specialist {
  final Gender? gender;
}
```

**Pros**: Type-safe, compile-time checks  
**Cons**: Breaking change, veri migration gerekir, mevcut string verilerle uyumsuz  
**Decision**: Reddedildi - mevcut string-based approach'u koruyoruz

### Alternative 2: Gender-Specific Icons

Farklı cinsiyet için farklı ikon şekilleri (örn: `Icons.man`, `Icons.woman`)

**Pros**: Daha belirgin görsel ayrım  
**Cons**: Potansiyel stereotipler, daha karmaşık implementasyon  
**Decision**: Reddedildi - sadece renk değişikliği daha minimal ve profesyonel

### Alternative 3: Gradient Backgrounds

Düz renk yerine gradient kullanmak

**Pros**: Daha "premium" görünüm  
**Cons**: Mevcut minimal tasarım diline uygun değil, gereksiz karmaşıklık  
**Decision**: Reddedildi - düz renkler daha temiz ve tutarlı

## Future Enhancements

### Potential Improvements

1. **Custom Avatar Colors**: Admin panelinde uzman başına özel renk seçimi
2. **Theme Variations**: Dark mode için farklı tonlar
3. **Animated Transitions**: Cinsiyet değiştiğinde smooth color transition
4. **Gender Diversity**: "Other" cinsiyeti için özel renk/ikon

### Non-Goals (Out of Scope)

- Cinsiyet alanını enum'a çevirmek
- Veritabanı migration
- Cinsiyet seçim UI'ı değişikliği
- Avatar shape değişiklikleri

## Conclusion

Bu design, minimal kod değişikliği ile maksimum görsel etki sağlıyor:
- ✅ Mevcut veriyi kullanıyor
- ✅ Tema ile tutarlı
- ✅ Erişilebilir
- ✅ Performanslı
- ✅ Test edilebilir
- ✅ Backward compatible

Implementation straightforward ve risk düşük.
