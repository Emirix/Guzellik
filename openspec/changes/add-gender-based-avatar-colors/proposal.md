# Proposal: Uzman Avatar Arkaplan Renklerini Cinsiyete Göre Özelleştir

## Motivation

Şu anda uzmanların fotoğrafı olmadığında gösterilen varsayılan avatar ikonları tüm uzmanlar için aynı gri arka plan rengini kullanıyor. Bu, kullanıcı deneyimini iyileştirmek ve uzmanları görsel olarak daha kolay ayırt edilebilir hale getirmek için bir fırsat sunuyor.

Uzmanların cinsiyet bilgisi zaten `specialist` tablosunda mevcut (`gender` alanı) ancak UI'da kullanılmıyor. Bu bilgiyi kullanarak:
- **Erkek uzmanlar** için mavi tonlu arka plan
- **Kadın uzmanlar** için pembe tonlu arka plan
- **Cinsiyet belirtilmemişse** nötr gri arka plan

kullanarak daha anlamlı ve görsel olarak zengin bir deneyim sunabiliriz.

## Scope

Bu değişiklik aşağıdaki kapsamları etkiler:
- **UI/UX**: Uzman avatar görüntüleme bileşenleri
- **Theme System**: Yeni renk tanımları (erkek/kadın avatar renkleri)

## User Impact

### Pozitif Etkiler
- Uzmanları görsel olarak daha kolay tanıma
- Daha kişiselleştirilmiş ve profesyonel görünüm
- Mevcut cinsiyet verisinin anlamlı kullanımı

### Değişiklik Gerektiren Durumlar
- Hiçbir kullanıcı eylemi gerekmez
- Mevcut veriler otomatik olarak yeni görsel stile uyarlanır

## Implementation Overview

### Etkilenen Bileşenler

1. **Theme System** (`lib/core/theme/app_colors.dart`)
   - Yeni renk sabitleri eklenecek:
     - `avatarMale`: Erkek uzmanlar için mavi ton
     - `avatarFemale`: Kadın uzmanlar için pembe ton
     - `avatarNeutral`: Cinsiyet belirtilmemişse nötr gri

2. **Expert Card Widget** (`lib/presentation/widgets/venue/components/expert_card.dart`)
   - Avatar arka plan rengi cinsiyete göre dinamik olarak ayarlanacak
   - Mevcut `gray100` yerine cinsiyet bazlı renk kullanılacak

3. **Specialist Card** (Admin panelinde kullanılan)
   - `lib/presentation/screens/business/admin/admin_specialists_screen.dart` içindeki `_SpecialistCard`
   - Aynı renk mantığı uygulanacak

4. **Experts Tab** (`lib/presentation/widgets/venue/tabs/experts_tab.dart`)
   - Uzmanların listelendiği tüm yerler güncellenecek

5. **Experts Section V2** (`lib/presentation/widgets/venue/v2/experts_section_v2.dart`)
   - V2 tasarımında da aynı renk mantığı uygulanacak

### Teknik Yaklaşım

```dart
// Cinsiyet bazlı renk seçimi için yardımcı fonksiyon
Color _getAvatarBackgroundColor(String? gender) {
  if (gender == null || gender.isEmpty) {
    return AppColors.avatarNeutral;
  }
  
  switch (gender.toLowerCase()) {
    case 'male':
    case 'erkek':
    case 'm':
      return AppColors.avatarMale;
    case 'female':
    case 'kadın':
    case 'f':
      return AppColors.avatarFemale;
    default:
      return AppColors.avatarNeutral;
  }
}
```

### Renk Seçimi

Mevcut tema paletine uyumlu renkler:
- **Erkek (Mavi)**: `Color(0xFFE3F2FD)` - Açık mavi, profesyonel
- **Kadın (Pembe)**: `Color(0xFFFFEAF3)` - Mevcut `primaryLight` ile uyumlu pembe
- **Nötr (Gri)**: `Color(0xFFF5F5F5)` - Mevcut `gray100`

## Dependencies

### Önkoşullar
- Hiçbir önkoşul yok, mevcut `gender` alanı zaten kullanılabilir durumda

### Etkilenen Sistemler
- UI rendering (Flutter widget tree)
- Theme system

### Dış Bağımlılıklar
- Yok

## Risks & Mitigations

### Risk 1: Cinsiyet Verisi Tutarsızlığı
**Risk**: Veritabanında cinsiyet değerleri farklı formatlarda olabilir (örn: "male", "Male", "M", "erkek")

**Mitigation**: 
- Case-insensitive karşılaştırma kullan
- Birden fazla format desteği (male/erkek/m, female/kadın/f)
- Bilinmeyen değerler için nötr renk fallback

### Risk 2: Tema Uyumsuzluğu
**Risk**: Yeni renkler mevcut tema ile uyumsuz olabilir

**Mitigation**:
- Mevcut `primaryLight` rengini kadın avatarları için kullan
- Açık, pastel tonlar seç (mevcut nude/soft pink paletine uyumlu)
- Design review süreci

### Risk 3: Erişilebilirlik
**Risk**: Renk körlüğü olan kullanıcılar için sorun olabilir

**Mitigation**:
- Sadece arka plan rengi değişiyor, ikon ve metin aynı kalıyor
- Yeterli kontrast oranı sağlanacak
- Renk tek bilgi kaynağı değil (isim ve meslek bilgisi de gösteriliyor)

## Alternatives Considered

### Alternatif 1: Farklı İkon Şekilleri
Erkek ve kadın için farklı ikon şekilleri kullanmak (örn: farklı avatar ikonları)

**Neden Reddedildi**: Daha karmaşık implementasyon, potansiyel stereotipler

### Alternatif 2: Gradient Arka Planlar
Düz renk yerine gradient kullanmak

**Neden Reddedildi**: Mevcut minimal tasarım diline uygun değil, gereksiz karmaşıklık

### Alternatif 3: Hiçbir Değişiklik Yapmamak
Mevcut gri arka planı korumak

**Neden Reddedildi**: Mevcut cinsiyet verisini kullanma fırsatını kaçırır, daha az görsel zenginlik

## Success Criteria

### Fonksiyonel Kriterler
- [ ] Erkek uzmanlar mavi arka plan ile gösteriliyor
- [ ] Kadın uzmanlar pembe arka plan ile gösteriliyor
- [ ] Cinsiyet belirtilmemişse nötr gri arka plan gösteriliyor
- [ ] Tüm uzman görüntüleme noktalarında tutarlı davranış

### Teknik Kriterler
- [ ] Yeni renkler `AppColors` sınıfına eklendi
- [ ] Tüm uzman widget'ları güncellendi
- [ ] Kod temiz ve bakımı kolay
- [ ] Hot reload ile değişiklikler anında görülebiliyor

### Kullanıcı Deneyimi Kriterlers
- [ ] Renkler mevcut tema ile uyumlu
- [ ] Görsel hiyerarşi korunuyor
- [ ] Erişilebilirlik standartlarına uygun (kontrast oranı)
- [ ] Performans etkilenmemiş

## Timeline Estimate

- **Tasarım ve Planlama**: 30 dakika (tamamlandı)
- **Implementation**: 1-2 saat
  - Theme colors ekleme: 15 dakika
  - Widget güncellemeleri: 45-60 dakika
  - Test ve ince ayarlar: 30 dakika
- **Review ve Test**: 30 dakika

**Toplam**: ~2-3 saat

## Open Questions

1. ✅ Cinsiyet alanı veritabanında mevcut mu? → **Evet, `gender` alanı mevcut**
2. ✅ Hangi ekranlarda uygulanmalı? → **Tüm uzman görüntüleme noktalarında**
3. ✅ Renk tonları? → **Mevcut tema ile uyumlu pastel tonlar**
4. ⏳ Null cinsiyet için hangi renk? → **Gri (gray100) önerildi, onay bekleniyor**
