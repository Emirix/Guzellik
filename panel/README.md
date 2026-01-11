# Güzellik Haritam - Admin Panel

Modern React tabanlı admin paneli. İşletmeleri (venues) yönetmek için kullanılır.

## Özellikler

- ✅ İşletme listeleme, arama ve filtreleme
- ✅ Yeni işletme ekleme
- ✅ İşletme düzenleme
- ✅ Konum yönetimi (İl/İlçe)
- ✅ Kategori yönetimi
- ✅ Modern ve responsive tasarım
- ✅ Supabase entegrasyonu

## Teknolojiler

- **React 18** - UI framework
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **React Router** - Routing
- **Supabase** - Backend & Database

## Kurulum

1. Bağımlılıkları yükleyin:
```bash
npm install
```

2. `.env` dosyasını oluşturun ve Supabase bilgilerinizi ekleyin:
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. Development server'ı başlatın:
```bash
npm run dev
```

4. Tarayıcıda açın: http://localhost:5173

## Kullanım

### İşletme Ekleme
1. Sol menüden "Yeni İşletme" seçeneğine tıklayın
2. Formu doldurun (İsim, Kategori, Konum, vb.)
3. "İşletmeyi Oluştur" butonuna tıklayın

### İşletme Düzenleme
1. İşletmeler listesinden düzenlemek istediğiniz işletmeyi bulun
2. "Düzenle" linkine tıklayın
3. Değişiklikleri yapın ve kaydedin

## Proje Yapısı

```
panel/
├── src/
│   ├── components/
│   │   ├── common/          # Ortak UI bileşenleri
│   │   ├── layout/          # Layout bileşenleri
│   │   └── venue/           # İşletme bileşenleri
│   ├── contexts/            # React Context'leri
│   ├── hooks/               # Custom hooks
│   ├── pages/               # Sayfa bileşenleri
│   ├── services/            # API servisleri
│   ├── utils/               # Yardımcı fonksiyonlar
│   ├── App.jsx              # Ana uygulama
│   └── main.jsx             # Giriş noktası
├── public/                  # Statik dosyalar
└── index.html               # HTML şablonu
```

## Geliştirme

### Build
```bash
npm run build
```

### Preview
```bash
npm run preview
```

## Notlar

- Bu versiyon authentication içermemektedir (gelecek versiyonda eklenecek)
- Tüm veriler Supabase'de saklanır
- RLS (Row Level Security) politikaları Supabase'de yapılandırılmalıdır

## Lisans

MIT
