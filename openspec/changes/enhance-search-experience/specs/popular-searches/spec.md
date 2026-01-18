# Popüler Aramalar

## ADDED Requirements

### Requirement: Popüler Hizmetleri Gösterme

Kullanıcılar arama ekranının başlangıç görünümünde, sistemde en çok sunulan hizmetleri "Popüler Aramalar" bölümünde görebilmelidir. Bu özellik kullanıcıların ne arayacaklarını bilmedikleri durumlarda keşif yapmalarını kolaylaştırır.

#### Scenario: Popüler Aramalar Başarıyla Yükleniyor

**Given** Kullanıcı arama ekranına girmiştir  
**And** Sistemde en az 3 farklı hizmet sunan işletme vardır  
**When** Arama ekranı yüklendiğinde  
**Then** "Popüler Aramalar" bölümü görüntülenir  
**And** En çok sunulan 6-7 hizmet chip formatında gösterilir  
**And** Her chip hizmet adını içerir  
**And** Chip'ler yatay kaydırılabilir listede gösterilir

#### Scenario: Yetersiz Veri Durumunda Popüler Aramalar Gizleniyor

**Given** Kullanıcı arama ekranına girmiştir  
**And** Sistemde 3'ten az farklı hizmet vardır  
**When** Arama ekranı yüklendiğinde  
**Then** "Popüler Aramalar" bölümü gösterilmez  
**And** Sadece kategori seçimi gösterilir

#### Scenario: Popüler Aramaya Tıklama

**Given** Kullanıcı arama ekranındadır  
**And** "Popüler Aramalar" bölümü görüntülenmektedir  
**When** Kullanıcı "Saç Kesimi (Kadın)" chip'ine tıkladığında  
**Then** Arama sorgusu "Saç Kesimi (Kadın)" olarak ayarlanır  
**And** İlgili hizmet için arama başlatılır  
**And** Arama sonuçları gösterilir

### Requirement: Popüler Hizmetleri Belirleme

Sistem, bir hizmetin popülerliğini kaç farklı işletmenin o hizmeti sunduğuna göre belirler. En çok sunulan hizmetler popüler olarak işaretlenir.

#### Scenario: Popülerlik Hesaplama

**Given** Sistemde "Saç Kesimi (Kadın)" hizmetini 50 işletme sunmaktadır  
**And** "Manikür" hizmetini 30 işletme sunmaktadır  
**And** "Masaj" hizmetini 10 işletme sunmaktadır  
**When** Popüler hizmetler sorgulandığında  
**Then** "Saç Kesimi (Kadın)" ilk sırada yer alır  
**And** "Manikür" ikinci sırada yer alır  
**And** "Masaj" üçüncü sırada yer alır

#### Scenario: Sadece Aktif Hizmetler Dahil Edilir

**Given** Sistemde "Botoks" hizmetini 40 işletme sunmaktadır  
**And** Bu hizmetlerden 10 tanesi `is_available = false` durumundadır  
**When** Popüler hizmetler sorgulandığında  
**Then** "Botoks" için sadece 30 işletme sayılır  
**And** Popülerlik sıralaması buna göre yapılır

### Requirement: Popüler Aramaları Cache'leme

Performans optimizasyonu için popüler aramalar cache'lenir ve belirli bir süre boyunca cache'ten sunulur.

#### Scenario: Cache'ten Popüler Aramalar Yükleme

**Given** Kullanıcı 3 dakika önce arama ekranını açmıştır  
**And** Popüler aramalar cache'e kaydedilmiştir  
**When** Kullanıcı arama ekranını tekrar açtığında  
**Then** Popüler aramalar cache'ten yüklenir  
**And** Veritabanı sorgusu yapılmaz  
**And** Yükleme anında gerçekleşir

#### Scenario: Cache Süresi Dolduğunda Yeniden Yükleme

**Given** Kullanıcı 6 dakika önce arama ekranını açmıştır  
**And** Cache süresi 5 dakika olarak ayarlanmıştır  
**When** Kullanıcı arama ekranını tekrar açtığında  
**Then** Cache geçersiz kabul edilir  
**And** Popüler aramalar veritabanından yeniden yüklenir  
**And** Yeni veriler cache'e kaydedilir

### Requirement: Popüler Aramalar UI Tasarımı

Popüler aramalar bölümü modern, etkileşimli ve premium bir tasarıma sahip olmalıdır.

#### Scenario: Chip Tasarımı ve Animasyonları

**Given** Kullanıcı arama ekranındadır  
**And** Popüler aramalar gösterilmektedir  
**When** Kullanıcı bir chip'e dokunduğunda  
**Then** Chip'te tıklama animasyonu oynatılır  
**And** Chip rengi geçici olarak değişir  
**And** Haptic feedback verilir (destekleyen cihazlarda)

#### Scenario: Loading State Gösterimi

**Given** Kullanıcı arama ekranını açmıştır  
**And** Popüler aramalar henüz yüklenmemiştir  
**When** Veriler yüklenirken  
**Then** Shimmer loading animasyonu gösterilir  
**And** 6-7 adet placeholder chip gösterilir  
**And** Kullanıcı loading sırasında başka işlem yapabilir

## MODIFIED Requirements

### Requirement: Arama Başlangıç Ekranı

Mevcut arama başlangıç ekranı sadece kategorileri göstermektedir. Bu ekran popüler aramalar bölümünü de içerecek şekilde genişletilmiştir.

#### Scenario: Güncellenmiş Başlangıç Ekranı

**Given** Kullanıcı arama ekranına girmiştir  
**And** Henüz bir kategori seçmemiştir  
**When** Başlangıç ekranı gösterildiğinde  
**Then** Üstte "Kategoriler" başlığı ve kategori grid'i gösterilir  
**And** Kategorilerin altında "Popüler Aramalar" bölümü gösterilir  
**And** Popüler aramaların altında "Önerilen Mekanlar" bölümü gösterilir (varsa)  
**And** Tüm bölümler scroll edilebilir

## REMOVED Requirements

_Bu değişiklik kapsamında kaldırılan requirement bulunmamaktadır._
