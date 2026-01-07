# Change: Supabase Test Verisi Ekleme

## Why

Uygulamanın geliştirme aşamasında harita, liste ve detay sayfalarının doğru çalıştığını doğrulamak için gerçekçi test verilerine ihtiyaç vardır. Bu veriler, mekanların (venues) ve hizmetlerin (services) veritabanında bulunmasını sağlar.

## What Changes

- Supabase veritabanına örnek mekanlar (venues) ve bu mekanlara ait hizmetler (services) eklenmesi.
- Mekan resimleri eklenmesi
- Mekanlar için gerçekçi koordinatlar, kategoriler ve güven rozetleri kullanımı.

## Impact

- Affected specs: `database`
- Affected code: Supabase database content (public schema)
