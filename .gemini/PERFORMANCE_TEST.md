# PERFORMANS TEST RAPORU

## Test Adımları

### 1. Hot Reload Yap
```bash
r  # Terminal'de
```

### 2. Logları Kontrol Et
```bash
# Yeni terminal'de
adb logcat -c  # Logları temizle
adb logcat | grep -i "lockHardwareCanvas"
```

### 3. Test Senaryoları

#### A. Ana Sayfa (Keşfet)
- [ ] Ana sayfayı aç
- [ ] 10 saniye bekle
- [ ] Kaç log geldi? _______

#### B. Arama Ekranı
- [ ] Arama ekranını aç
- [ ] Kategori seç
- [ ] 10 saniye bekle
- [ ] Kaç log geldi? _______

#### C. Venue Details
- [ ] Bir venue'ye tıkla
- [ ] 10 saniye bekle
- [ ] Kaç log geldi? _______

#### D. Hiçbir Şey Yapma
- [ ] Ekrana dokunma
- [ ] 10 saniye bekle
- [ ] Kaç log geldi? _______

## Beklenen Sonuçlar

### İYİ (Optimizasyon Başarılı)
- Hiçbir şey yapmadan: 0-2 log
- Normal kullanımda: 5-10 log (10 saniyede)

### KÖTÜ (Hala Sorun Var)
- Hiçbir şey yapmadan: 10+ log
- Normal kullanımda: 50+ log (10 saniyede)

## Eğer Hala Sorun Varsa

### Olası Sebepler:
1. Google Maps sürekli çalışıyor
2. Bir provider sürekli notifyListeners() çağırıyor
3. Bir Timer/Stream dispose edilmemiş
4. Platform view (WebView, Map) sürekli repaint ediyor

### Sonraki Adım:
Bana hangi ekranda olduğunuzu ve log sıklığını söyleyin.
Ben o ekrana özel optimizasyon yapacağım.
