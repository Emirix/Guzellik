# Git Commit Kuralları

Bu projede commit mesajları için **Conventional Commits** standartları kullanılır ve mesajların **Türkçe** olması zorunludur.

## Mesaj Formatı

Her commit mesajı bir **tip**, bir **kapsam** (isteğe bağlı) ve bir **açıklama** içermelidir:

```
<tip>(<kapsam>): <açıklama>
```

Örnek: `feat(auth): google login entegrasyonu tamamlandı`

## Commit Tipleri

| Tip | Açıklama |
| :--- | :--- |
| **feat** | Yeni bir özelliğin eklenmesi |
| **fix** | Bir hatanın düzeltilmesi |
| **docs** | Sadece dokümantasyon değişikliği |
| **style** | Kodun çalışmasını etkilemeyen görsel/biçimsel değişiklikler |
| **refactor** | Ne bir hata düzelten ne de özellik ekleyen kod değişikliği |
| **perf** | Performans iyileştirmesi |
| **test** | Test ekleme veya mevcut testleri düzeltme |
| **build** | Derleme sistemi veya bağımlılık değişiklikleri (pubspec, gradle vb.) |
| **ci** | CI yapılandırma dosyaları ve betiklerindeki değişiklikler |
| **chore** | Kaynak kod veya test dosyası içermeyen diğer değişiklikler |
| **revert** | Önceki bir commit'i geri alma |

## Temel Kurallar

1. **Dil**: Tüm mesajlar gramer kurallarına uygun **Türkçe** ile yazılmalıdır.
2. **Küçük Harf**: Açıklama kısmı küçük harfle başlamalıdır.
3. **Noktalama**: Mesajın sonuna nokta (.) konulmamalıdır.
4. **Zaman**: Geçmiş zaman ("eklendi", "düzeltildi") veya emir kipi ("ekle", "düzelt") kullanılabilir. Proje genelinde tutarlılık için **geçmiş zaman** önerilir.

---
Bu kurallar `.cursorrules` dosyasına da dahil edilmiştir ve AI asistanı tarafından takip edilecektir.
