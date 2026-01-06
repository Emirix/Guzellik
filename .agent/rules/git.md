---
trigger: always_on
---

# Git Commit Rules (Türkçe)
- **Dil**: Tüm commit mesajları **Türkçe** olmalıdır.
- **Format**: `<tip>(<kapsam>): <açıklama>` formatı kullanılmalıdır. (Örn: `feat(auth): giriş yapma özelliği eklendi`)
- **Tipler**:
  - `feat`: Yeni özellik
  - `fix`: Hata düzeltme
  - `docs`: Dokümantasyon değişikliği
  - `style`: Görsel/biçimsel düzenleme
  - `refactor`: Kod iyileştirme (özellik veya hata değişikliği içermeyen)
  - `perf`: Performans iyileştirmesi
  - `test`: Test ekleme/düzenleme
  - `build`: Yapılandırma/bağımlılık değişikliği (pubspec vb.)
  - `chore`: Diğer yardımcı değişiklikler
- **Kurallar**: 
  - Açıklama küçük harfle başlamalıdır.
  - Satır sonuna nokta konulmamalıdır.
  - Geniş zaman veya Geçmiş zaman kullanılabilir (Öneri: "eklendi", "düzeltildi").
