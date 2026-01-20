# Maskot Entegrasyonu Tasarım Dokümanı

**Tarih:** 2026-01-20  
**Durum:** Onaylandı  
**Hedef:** Güzellik Haritam uygulaması için maskot karakterinin marka kimliği odaklı entegrasyonu

---

## 📋 Genel Bakış

Güzellik Haritam uygulaması için tasarlanan maskot karakteri, konum pin şeklinde sevimli bir karakter olup, elinde makyaj fırçası tutuyor. Bu maskot, uygulamanın marka kimliğini güçlendirmek ve kullanıcı deneyimini iyileştirmek amacıyla stratejik noktalarda kullanılacaktır.

### 🎯 Kullanım Stratejisi

- **Odak:** Marka kimliği oluşturma
- **Format:** Statik görsel (PNG)
- **Renk Paleti:** Soft pink, nude, cream, gold (proje paletine uyumlu)

---

## 🖼️ Maskot Varyasyonları

### 1. **mascot_full.png** (600x600px)
- **Kullanım Alanları:** Login, Register, Ayarlar sayfaları
- **Özellikler:** 
  - Tam görsel (pin + yüz + fırça)
  - Şeffaf arka plan
  - Yüksek çözünürlük
  - Sparkle efektleri

### 2. **mascot_header.png** (120x120px)
- **Kullanım Alanları:** Header logo (tüm ekranlar)
- **Özellikler:**
  - Kompakt versiyon (sadece pin + yüz)
  - Fırça detayı yok
  - Minimal, küçük boyutlarda tanınabilir
  - Şeffaf arka plan

### 3. **ic_notification.png** (72x72px)
- **Kullanım Alanları:** Push notification icon
- **Özellikler:**
  - Basitleştirilmiş silüet
  - Tek renk (beyaz)
  - Android notification standartlarına uygun
  - Şeffaf arka plan

---

## 📱 Ekran Bazında Kullanım Detayları

### 🔐 Login Ekranı

**Konum:** Ekranın üst-orta kısmı  
**Boyut:** 200x200 dp  
**Dosya:** `mascot_full.png`

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFF5F0), // Cream
        Color(0xFFFFE8E0), // Soft pink
      ],
    ),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/mascot/mascot_full.png',
        width: 200,
        height: 200,
      ),
      SizedBox(height: 24),
      Text(
        'Güzellik Haritam',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD4A574), // Gold
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Hoş Geldiniz',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    ],
  ),
)
```

**Tasarım Notları:**
- Gradient arka plan kullan (cream → soft pink)
- Maskot ile uygulama adı arasında 24dp boşluk
- Samimi ve davetkar bir atmosfer oluştur

---

### ✍️ Register Ekranı

**Konum:** Ekranın üst-orta kısmı  
**Boyut:** 200x200 dp  
**Dosya:** `mascot_full.png`

```dart
Container(
  padding: EdgeInsets.symmetric(vertical: 40),
  child: Column(
    children: [
      Image.asset(
        'assets/images/mascot/mascot_full.png',
        width: 200,
        height: 200,
      ),
      SizedBox(height: 16),
      Text(
        'Aramıza Katıl',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD4A574),
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Güzellik dünyasını keşfet',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black45,
        ),
      ),
    ],
  ),
)
```

**Tasarım Notları:**
- Login ile aynı maskot kullanılır
- Başlık metni "Aramıza Katıl" olarak değişir
- Alt başlık ile kullanıcıyı motive et

---

### 📍 Header Logo (Ana Sayfa & Diğer Ekranlar)

**Konum:** AppBar sol üst köşe veya merkez  
**Boyut:** 40x40 dp  
**Dosya:** `mascot_header.png`

```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  leading: Padding(
    padding: EdgeInsets.all(8.0),
    child: Image.asset(
      'assets/images/mascot/mascot_header.png',
      width: 40,
      height: 40,
    ),
  ),
  title: Text(
    'Güzellik Haritam',
    style: TextStyle(
      color: Colors.black87,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  centerTitle: false,
)
```

**Alternatif - Merkezi Header:**

```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/mascot/mascot_header.png',
        width: 32,
        height: 32,
      ),
      SizedBox(width: 8),
      Text(
        'Güzellik Haritam',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)
```

**Tasarım Notları:**
- Kompakt versiyon kullan (fırça detayı yok)
- Beyaz arka plan üzerinde iyi görünür
- Tüm ekranlarda tutarlı kullanım

---

### ⚙️ Ayarlar Sayfası

**Konum:** Sayfa başlığı altında, merkezi  
**Boyut:** 120x120 dp  
**Dosya:** `mascot_full.png`

```dart
Column(
  children: [
    SizedBox(height: 24),
    Image.asset(
      'assets/images/mascot/mascot_full.png',
      width: 120,
      height: 120,
    ),
    SizedBox(height: 16),
    Text(
      'Ayarlar',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    SizedBox(height: 32),
    // Ayarlar listesi buraya gelir
    ListTile(
      leading: Icon(Icons.person_outline),
      title: Text('Profil'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.notifications_outlined),
      title: Text('Bildirimler'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.info_outline),
      title: Text('Hakkında'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    ),
  ],
)
```

**Tasarım Notları:**
- Orta boy maskot kullan (120x120)
- Marka kimliğini pekiştir
- Sayfa başlığı ile maskot arasında denge kur

---

### 🔔 Push Notification

**Konum:** Android bildirim çubuğu  
**Boyut:** 24x24, 48x48, 72x72 dp (multiple densities)  
**Dosya:** `ic_notification.png`

```dart
// Firebase Messaging konfigürasyonu
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'guzellik_haritam_channel',
  'Güzellik Haritam Bildirimleri',
  description: 'Mekan bildirimleri ve güncellemeler',
  importance: Importance.high,
  playSound: true,
);

// Bildirim gönderme
await flutterLocalNotificationsPlugin.show(
  0,
  'Yeni Güncelleme!',
  'Takip ettiğiniz mekan yeni bir kampanya ekledi',
  NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      icon: 'ic_notification', // assets/images/mascot/notification/ic_notification.png
      color: Color(0xFFFF6B6B), // Soft pink
      importance: Importance.high,
      priority: Priority.high,
    ),
  ),
);
```

**Android Notification Icon Gereksinimleri:**
- Tek renk (beyaz) silüet
- Şeffaf arka plan
- Basit, tanınabilir şekil
- Multiple densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

**Dosya Yapısı:**
```
android/app/src/main/res/
├── drawable-mdpi/ic_notification.png (24x24)
├── drawable-hdpi/ic_notification.png (36x36)
├── drawable-xhdpi/ic_notification.png (48x48)
├── drawable-xxhdpi/ic_notification.png (72x72)
└── drawable-xxxhdpi/ic_notification.png (96x96)
```

---

## 🎨 Renk Paleti ve Tema Entegrasyonu

### Maskot Renkleri
- **Pin Şekli:** #FF6B6B (Coral Pink)
- **Yüz:** #FFEFD5 (Cream)
- **Fırça:** #FFB6C1 (Light Pink)
- **Detaylar:** #8B4513 (Brown - gözler, kontur)

### Proje Renk Paleti ile Uyum
```dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B6B);      // Soft Pink (maskot ile uyumlu)
  static const Color secondary = Color(0xFFD4A574);    // Gold
  static const Color background = Color(0xFFFFFAFA);   // White/Cream
  
  // Accent Colors
  static const Color accent1 = Color(0xFFFFE8E0);      // Light Pink
  static const Color accent2 = Color(0xFFFFF5F0);      // Cream
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF757575);
}
```

### Gradient Önerileri

**Login/Register Arka Plan:**
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFFF5F0), // Cream
    Color(0xFFFFE8E0), // Soft pink
  ],
)
```

**Button Gradient:**
```dart
LinearGradient(
  colors: [
    Color(0xFFFF6B6B), // Soft pink
    Color(0xFFFF8E8E), // Lighter pink
  ],
)
```

---

## 📂 Dosya Yapısı

```
assets/
└── images/
    └── mascot/
        ├── mascot_full.png           # 600x600px - Login/Register/Ayarlar
        ├── mascot_header.png         # 120x120px - Header logo
        └── notification/
            └── ic_notification.png   # 72x72px - Push notification

android/app/src/main/res/
├── drawable-mdpi/ic_notification.png
├── drawable-hdpi/ic_notification.png
├── drawable-xhdpi/ic_notification.png
├── drawable-xxhdpi/ic_notification.png
└── drawable-xxxhdpi/ic_notification.png
```

---

## ✅ Implementasyon Checklist

### Aşama 1: Asset Hazırlığı
- [x] `mascot_full.png` oluşturuldu (600x600px)
- [x] `mascot_header.png` oluşturuldu (120x120px)
- [x] `ic_notification.png` oluşturuldu (72x72px)
- [x] Assets klasörüne kopyalandı
- [x] `pubspec.yaml` güncellendi

### Aşama 2: Login/Register Ekranları
- [ ] Login ekranı tasarımı güncellendi
- [ ] Register ekranı tasarımı güncellendi
- [ ] Gradient arka planlar eklendi
- [ ] Responsive tasarım test edildi

### Aşama 3: Header Entegrasyonu
- [ ] Ana sayfa AppBar'ına eklendi
- [ ] Diğer ekranlara eklendi
- [ ] Merkezi/sol hizalama kararı verildi
- [ ] Tutarlılık kontrolü yapıldı

### Aşama 4: Ayarlar Sayfası
- [ ] Ayarlar sayfası tasarımı güncellendi
- [ ] Maskot merkezi konumda yerleştirildi
- [ ] Sayfa düzeni optimize edildi

### Aşama 5: Push Notification
- [ ] Android notification icon'ları oluşturuldu (multiple densities)
- [ ] `android/app/src/main/res/` klasörüne eklendi
- [ ] Firebase Messaging konfigürasyonu güncellendi
- [ ] Test bildirimi gönderildi

### Aşama 6: Test ve Optimizasyon
- [ ] Tüm ekranlarda görsel test yapıldı
- [ ] Farklı cihaz boyutlarında test edildi
- [ ] Performans kontrolü yapıldı
- [ ] Dosya boyutları optimize edildi

---

## 🚀 Sonraki Adımlar

1. **Login/Register ekranlarını güncelle** - Maskot ile yeni tasarımı uygula
2. **Header entegrasyonu** - Tüm ekranlara header logo ekle
3. **Ayarlar sayfası** - Maskot ile yeni tasarımı uygula
4. **Push notification setup** - Android notification icon'larını yapılandır
5. **Test ve iyileştirme** - Kullanıcı geri bildirimi al ve optimize et

---

## 📝 Notlar

- Maskot görselleri şeffaf arka plana sahip, her arka plan rengi ile uyumlu
- Statik kullanım performans açısından optimize edilmiş
- Gelecekte animasyonlu versiyon eklenebilir (Lottie desteği mevcut)
- Tüm görseller yüksek çözünürlükte, retina display uyumlu

---

**Tasarım Onayı:** ✅  
**Implementasyon Durumu:** Hazır  
**Tahmini Süre:** 2-3 gün
