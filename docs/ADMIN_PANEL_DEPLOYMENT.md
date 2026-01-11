# Admin Panel Deployment Rehberi

## Gereksinimler
- Node.js 18+
- npm veya yarn
- Vercel veya Netlify hesabı

## Kurulum

### 1. Proje Kurulumu
```bash
cd admin
npm install
```

### 2. Environment Variables
`.env` dosyası oluşturun:
```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 3. Local Development
```bash
npm run dev
```
Admin panel `http://localhost:5173` adresinde çalışacaktır.

## Vercel Deployment

### Otomatik Deployment
1. Vercel hesabınıza giriş yapın
2. "New Project" tıklayın
3. GitHub repository'nizi seçin
4. Root Directory: `admin`
5. Framework Preset: Vite
6. Environment Variables ekleyin:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
7. Deploy butonuna tıklayın

### Manuel Deployment
```bash
cd admin
npm run build
vercel --prod
```

## Netlify Deployment

### Otomatik Deployment
1. Netlify hesabınıza giriş yapın
2. "New site from Git" tıklayın
3. Repository'nizi seçin
4. Build settings:
   - Base directory: `admin`
   - Build command: `npm run build`
   - Publish directory: `admin/dist`
5. Environment variables ekleyin
6. Deploy butonuna tıklayın

### Manuel Deployment
```bash
cd admin
npm run build
netlify deploy --prod --dir=dist
```

## Custom Domain Yapılandırması

### Vercel
1. Project Settings → Domains
2. Domain adınızı ekleyin (örn: `admin.guzellikharitam.com`)
3. DNS kayıtlarını yapılandırın:
   ```
   Type: CNAME
   Name: admin
   Value: cname.vercel-dns.com
   ```

### Netlify
1. Site Settings → Domain Management
2. "Add custom domain" tıklayın
3. DNS kayıtlarını yapılandırın:
   ```
   Type: CNAME
   Name: admin
   Value: your-site-name.netlify.app
   ```

## SSL Sertifikası
Hem Vercel hem de Netlify otomatik olarak Let's Encrypt SSL sertifikası sağlar.

## Flutter App Konfigürasyonu

Deployment sonrası `lib/config/admin_config.dart` dosyasını güncelleyin:

```dart
class AdminConfig {
  // Production URL
  static const String adminPanelUrl = 'https://admin.guzellikharitam.com';
  
  // Development URL
  // static const String adminPanelUrl = 'http://localhost:5173';
  
  static String getAdminUrl(String venueId) {
    return '$adminPanelUrl/dashboard?venue=$venueId';
  }
}
```

## Monitoring ve Logs

### Vercel
- Dashboard → Your Project → Deployments
- Real-time logs ve analytics mevcut

### Netlify
- Site Dashboard → Deploys
- Function logs ve analytics mevcut

## Güvenlik

### CORS Ayarları
Supabase Dashboard → Settings → API → CORS:
```
https://admin.guzellikharitam.com
```

### Environment Variables
- Production ve development için ayrı Supabase projeleri kullanın
- Anon key'leri public olarak paylaşılabilir (RLS ile korunur)
- Service role key'i asla client-side kodda kullanmayın

## Troubleshooting

### Build Hatası
```bash
# Cache temizle
rm -rf node_modules
rm package-lock.json
npm install
npm run build
```

### Environment Variables Yüklenmiyor
- Vercel/Netlify dashboard'dan değişkenleri kontrol edin
- `VITE_` prefix'inin kullanıldığından emin olun
- Redeploy yapın

### 404 Hatası
- `vercel.json` veya `netlify.toml` dosyasında SPA routing yapılandırması:

**vercel.json:**
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

**netlify.toml:**
```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

## Performans Optimizasyonu

### Build Optimizasyonu
```javascript
// vite.config.js
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          supabase: ['@supabase/supabase-js']
        }
      }
    }
  }
}
```

### CDN Cache
Vercel ve Netlify otomatik olarak static asset'leri CDN'de cache'ler.

## Backup ve Rollback

### Vercel
- Her deployment otomatik olarak saklanır
- Previous deployment'a tek tıkla dönülebilir

### Netlify
- Deploy history mevcut
- Rollback için eski deployment'ı "Publish" edin

## Monitoring Tools
- Vercel Analytics (built-in)
- Netlify Analytics (built-in)
- Google Analytics (manuel entegrasyon)
- Sentry (error tracking)

## Support
Sorun yaşarsanız:
1. Build logs'u kontrol edin
2. Environment variables'ı doğrulayın
3. Supabase bağlantısını test edin
4. Browser console'u kontrol edin
