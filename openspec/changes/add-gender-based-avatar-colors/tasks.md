# Tasks: Uzman Avatar Arkaplan Renklerini Cinsiyete Göre Özelleştir

## Task 1: Theme System'e Cinsiyet Bazlı Avatar Renkleri Ekle
**Dosya**: `lib/core/theme/app_colors.dart`

- [x] `avatarMale` renk sabiti ekle (açık mavi: `Color(0xFFE3F2FD)`)
- [x] `avatarFemale` renk sabiti ekle (açık pembe: `Color(0xFFFFEAF3)`)
- [x] `avatarNeutral` renk sabiti ekle (gri: `Color(0xFFF5F5F5)`)
- [x] Dokümantasyon yorumları ekle

**Validation**: 
- Renkler `AppColors` sınıfında tanımlanmış
- Hot reload ile yeni renkler kullanılabilir

**Estimated Time**: 15 dakika

---

## Task 2: Cinsiyet Bazlı Renk Seçimi Yardımcı Fonksiyonu Oluştur
**Dosya**: `lib/core/utils/avatar_utils.dart` (yeni dosya)

- [x] `getAvatarBackgroundColor(String? gender)` fonksiyonu oluştur
- [x] Case-insensitive cinsiyet kontrolü ekle
- [x] Birden fazla format desteği (male/erkek/m, female/kadın/f)
- [x] Null ve bilinmeyen değerler için nötr renk döndür
- [x] Unit test ekle

**Validation**:
- Fonksiyon tüm cinsiyet formatlarını doğru işliyor
- Null değerler için nötr renk döndürüyor
- Test coverage %100

**Estimated Time**: 30 dakika

---

## Task 3: Expert Card Widget'ını Güncelle
**Dosya**: `lib/presentation/widgets/venue/components/expert_card.dart`

- [x] `avatar_utils.dart` import et
- [x] Avatar container'ın `color` özelliğini cinsiyet bazlı renk ile değiştir
- [x] `Expert` modelinin `gender` alanını kullan
- [x] Mevcut `gray100` referanslarını kaldır

**Validation**:
- Fotoğrafı olmayan erkek uzmanlar mavi arka plan ile gösteriliyor
- Fotoğrafı olmayan kadın uzmanlar pembe arka plan ile gösteriliyor
- Cinsiyet belirtilmemişse gri arka plan gösteriliyor
- Fotoğrafı olan uzmanlar etkilenmiyor

**Estimated Time**: 20 dakika

---

## Task 4: Admin Specialist Card'ı Güncelle
**Dosya**: `lib/presentation/screens/business/admin/admin_specialists_screen.dart`

- [x] `_SpecialistCard` widget'ında avatar arka plan rengini güncelle
- [x] `avatar_utils.dart` import et
- [x] Cinsiyet bazlı renk mantığını uygula
- [x] Mevcut `gray100` referanslarını kaldır

**Validation**:
- Admin panelinde uzmanlar doğru renklerle gösteriliyor
- Tutarlı görünüm (kullanıcı tarafı ile aynı)

**Estimated Time**: 15 dakika

---

## Task 5: Experts Tab Widget'ını Güncelle
**Dosya**: `lib/presentation/widgets/venue/tabs/experts_tab.dart`

- [x] Avatar gösterimi yapan tüm yerleri bul
- [x] Cinsiyet bazlı renk mantığını uygula
- [x] `avatar_utils.dart` import et
- [x] Tutarlılık kontrolü yap

**Validation**:
- Venue details ekranındaki Experts tab'inde renkler doğru gösteriliyor
- Liste ve grid görünümlerinde tutarlı davranış

**Estimated Time**: 20 dakika

---

## Task 6: Experts Section V2 Widget'ını Güncelle
**Dosya**: `lib/presentation/widgets/venue/v2/experts_section_v2.dart`

- [x] V2 tasarımında avatar arka plan rengini güncelle
- [x] Cinsiyet bazlı renk mantığını uygula
- [x] `avatar_utils.dart` import et
- [x] V1 ile tutarlılık kontrolü

**Validation**:
- V2 tasarımında renkler doğru gösteriliyor
- V1 ve V2 arasında tutarlı davranış

**Estimated Time**: 15 dakika

---

## Task 7: Diğer Uzman Görüntüleme Noktalarını Kontrol Et ve Güncelle

- [x] Codebase'de `Specialist` veya `Expert` kullanılan tüm yerleri tara
- [x] Avatar gösterimi yapan diğer widget'ları bul
- [x] Gerekirse cinsiyet bazlı renk mantığını uygula
- [x] Tutarlılık kontrolü

**Validation**:
- Tüm uzman görüntüleme noktalarında tutarlı renk kullanımı
- Hiçbir yer atlanmamış

**Estimated Time**: 30 dakika

---

## Task 8: Manuel Test ve Görsel Doğrulama

- [x] Erkek uzman ekle ve avatar rengini kontrol et (mavi olmalı)
- [x] Kadın uzman ekle ve avatar rengini kontrol et (pembe olmalı)
- [x] Cinsiyet belirtilmemiş uzman ekle (gri olmalı)
- [x] Farklı cinsiyet formatlarını test et (male/Male/M/erkek)
- [x] Fotoğraflı uzmanların etkilenmediğini doğrula
- [x] Tüm ekranlarda tutarlılığı kontrol et:
  - Venue details → Experts tab
  - Admin panel → Specialists screen
  - V2 tasarım bileşenleri

**Validation**:
- Tüm senaryolar beklendiği gibi çalışıyor
- Görsel olarak tema ile uyumlu
- Performans sorunu yok

**Estimated Time**: 30 dakika

---

## Task 9: Dokümantasyon ve Temizlik

- [x] `avatar_utils.dart` için dokümantasyon ekle
- [x] Değişiklik yapılan widget'lara yorum ekle
- [x] Kullanılmayan import'ları temizle
- [x] Code formatting kontrolü (`dart format`)

**Validation**:
- Kod temiz ve okunabilir
- Dokümantasyon yeterli
- Linter uyarısı yok

**Estimated Time**: 15 dakika

---

## Toplam Tahmini Süre: 2.5-3 saat

## Bağımlılıklar
- Task 1 → Task 2 (renkler tanımlanmalı)
- Task 2 → Task 3, 4, 5, 6, 7 (yardımcı fonksiyon hazır olmalı)
- Task 3-7 → Task 8 (implementasyon tamamlanmalı)
- Task 8 → Task 9 (test tamamlanmalı)

## Paralel Çalışılabilir Görevler
- Task 3, 4, 5, 6, 7 birbirinden bağımsız, paralel yapılabilir
