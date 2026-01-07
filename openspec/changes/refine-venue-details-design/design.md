# Design: Mekan Detay Sayfası Tasarım İyileştirmesi

## Architectural Overview

Bu değişiklik, mevcut mekan detay sayfasının görsel ve kullanıcı deneyimini design klasöründeki premium tasarımlara göre yeniden düzenlemektedir. Temel mimari yapı korunurken, UI component'leri ve styling güncellenecektir.

## Design Decisions

### 1. Component-Based Architecture
**Karar**: Yeniden kullanılabilir atomic component'ler oluşturmak.

**Gerekçe**:
- `QuickActionButton`, `ServiceCard`, `ExpertCard` gibi component'ler diğer sayfalarda da kullanılabilir
- Test edilebilirlik artar
- Kod tekrarı azalır
- Design system tutarlılığı sağlanır

**Alternatifler**:
- Monolithic widget'lar: Daha az dosya ama daha az yeniden kullanılabilirlik
- Inline implementation: Hızlı ama sürdürülemez

**Seçim**: Component-based yaklaşım, uzun vadede maintainability ve scalability sağlar.

---

### 2. Color Palette Management
**Karar**: Design dosyalarındaki renkleri AppColors'a merkezi olarak eklemek.

**Gerekçe**:
- Tüm uygulama genelinde tutarlı renk kullanımı
- Design değişikliklerinde tek noktadan güncelleme
- Type-safe renk referansları

**Implementation**:
```dart
class AppColors {
  // Existing colors...
  
  // Design palette additions
  static const nude = Color(0xFFF5E6D3);
  static const softPink = Color(0xFFFFB6C1);
  static const gold = Color(0xFFD4AF37);
  static const lightGray = Color(0xFFFAFAFA);
  
  // Gradients
  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black54],
  );
}
```

---

### 3. Typography Strategy
**Karar**: Google Fonts ile Inter ve Outfit fontlarını kullanmak.

**Gerekçe**:
- Design dosyalarıyla tam uyum
- Modern ve okunabilir fontlar
- Google Fonts package ile kolay entegrasyon

**Implementation**:
```dart
class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle bodyText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
```

---

### 4. Quick Action Buttons Integration
**Karar**: url_launcher ve share_plus package'larını kullanmak.

**Gerekçe**:
- Platform-agnostic çözüm (iOS/Android)
- Güvenilir ve yaygın kullanılan package'lar
- Deep linking desteği

**Alternatifler**:
- Native platform channels: Daha fazla kontrol ama daha fazla kod
- WebView: Performans sorunu

**Seçim**: Package'lar mature ve well-maintained, hızlı implementation sağlar.

---

### 5. Before/After Photo Display
**Karar**: Tek bir image widget içinde iki fotoğrafı yan yana göstermek.

**Gerekçe**:
- Design dosyalarındaki görünümle tam uyum
- Kullanıcı karşılaştırmayı kolayca yapabilir
- Responsive layout için uygun

**Implementation**:
```dart
Row(
  children: [
    Expanded(
      child: Stack(
        children: [
          Image.network(service.beforePhoto),
          Positioned(
            top: 8,
            left: 8,
            child: Chip(label: Text('Önce')),
          ),
        ],
      ),
    ),
    Container(width: 2, color: Colors.white), // Divider
    Expanded(
      child: Stack(
        children: [
          Image.network(service.afterPhoto),
          Positioned(
            top: 8,
            right: 8,
            child: Chip(label: Text('Sonra')),
          ),
        ],
      ),
    ),
  ],
)
```

---

### 6. Fixed Bottom Bar Implementation
**Karar**: Stack ve Positioned widget'ları kullanarak sabit alt bar oluşturmak.

**Gerekçe**:
- Scroll edilebilir içerik ile sabit buton kombinasyonu
- Native app hissi
- Design dosyalarındaki UX pattern'i

**Alternatifler**:
- FloatingActionButton: Tam genişlikte değil
- BottomNavigationBar: Farklı amaç için

**Implementation**:
```dart
Stack(
  children: [
    NestedScrollView(...), // Scrollable content
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BookingBottomBar(),
    ),
  ],
)
```

---

## Data Flow

### Current State:
```
VenueDetailsProvider → VenueDetailsScreen → Tabs (Services, About, Experts)
```

### After Changes:
```
VenueDetailsProvider → VenueDetailsScreen → 
  ├─ VenueHero (with QuickActionButtons)
  ├─ Tabs
  │   ├─ ServicesTab → ServiceCard[]
  │   ├─ AboutTab → WorkingHoursCard, PaymentMethods
  │   └─ ExpertsTab → ExpertCard[]
  └─ BookingBottomBar
```

---

## Performance Considerations

### Image Loading:
- Before/after fotoğrafları için cached_network_image kullanılmalı (zaten projede var mı kontrol et)
- Placeholder ve error widget'ları ekle
- Image compression backend'de yapılmalı

### Widget Rebuilds:
- Consumer widget'ları sadece gerekli yerlerde kullan
- Selector kullanarak partial rebuilds sağla
- Const constructor'lar kullan

---

## Accessibility

- Tüm butonlara semanticLabel ekle
- Renk kontrastı WCAG AA standardına uygun olmalı
- Font boyutları accessibility settings'e uymalı

---

## Testing Strategy

### Unit Tests:
- Component'lerin render edilmesi
- Callback'lerin çağrılması

### Widget Tests:
- Quick action button taps
- Service card interactions
- Booking button tap

### Integration Tests:
- Full user flow: Mekan detay → Hizmet seçimi → Randevu oluşturma

---

## Migration Path

1. **Phase 1**: Foundation (Colors, Typography) - Breaking change yok
2. **Phase 2**: Component'ler - Yeni dosyalar, mevcut kod etkilenmez
3. **Phase 3**: Integration - Mevcut widget'ları güncelle
4. **Phase 4**: Testing & Refinement

Bu aşamalı yaklaşım, her adımda test edilebilir ve geri alınabilir değişiklikler sağlar.

---

## Open Questions

1. **Expert Data Model**: Uzman bilgileri için ayrı bir model var mı yoksa oluşturulmalı mı?
2. **Working Hours Format**: Backend'den gelen çalışma saatleri formatı nedir?
3. **Payment Methods**: Kabul edilen ödeme yöntemleri backend'den mi geliyor?
4. **Before/After Photos**: Service model'inde bu alanlar var mı?

Bu sorular implementation sırasında netleştirilmeli.
