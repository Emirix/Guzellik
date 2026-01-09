# Quote Request Specification

## Overview
Kullanıcıların işletmelerden fiyat teklifi isteyebilmesini sağlayan özellik.

---

## ADDED Requirements

### Requirement: Quote Request Creation
Kullanıcılar birden fazla hizmet seçerek, tercih ettikleri tarih ve saat dilimini belirterek işletmelerden teklif isteyebilmeli.

#### Scenario: Successful Quote Request
- **WHEN** giriş yapmış kullanıcı navbar'daki teklif butonuna tıklar
- **AND** en az bir hizmet seçer
- **AND** tercih edilen tarihi seçer
- **AND** saat dilimi seçer
- **AND** "Teklif İste" butonuna tıklar
- **THEN** teklif başarıyla oluşturulur
- **AND** kullanıcı "Tekliflerim" sayfasına yönlendirilir
- **AND** teklif durumu "Yayında" olarak görünür

#### Scenario: Quote Request Without Login
- **WHEN** giriş yapmamış kullanıcı navbar'daki teklif butonuna tıklar
- **THEN** giriş yapması istenir
- **AND** teklif oluşturma sayfası gösterilmez

#### Scenario: Quote Request Validation
- **WHEN** teklif oluşturma sayfasındaki kullanıcı hizmet seçmeden devam etmeye çalışır
- **THEN** "En az bir hizmet seçmelisiniz" uyarısı gösterilir

---

### Requirement: Quote Request Listing
Kullanıcılar oluşturdukları teklifleri listeleyebilmeli ve durumlarını takip edebilmeli.

#### Scenario: View My Quotes
- **WHEN** giriş yapmış ve teklif oluşturmuş kullanıcı profil sayfasından "Tekliflerim" bölümüne gider
- **THEN** tüm teklifler tarih sırasına göre listelenir
- **AND** her teklifte seçilen hizmetler görünür
- **AND** her teklifte tercih edilen tarih görünür
- **AND** her teklifte durum (Yayında/Kapandı) görünür
- **AND** her teklifte yanıt sayısı görünür

#### Scenario: Filter Quotes by Status
- **WHEN** tekliflerim listesindeki kullanıcı "Yayında" filtresi seçer
- **THEN** sadece aktif teklifler görünür

---

### Requirement: Quote Request Detail
Kullanıcılar teklif detaylarını ve işletme yanıtlarını görüntüleyebilmeli.

#### Scenario: View Quote Detail
- **WHEN** giriş yapmış kullanıcı tekliflerim listesinden bir teklife tıklar
- **THEN** seçilen hizmetler görünür
- **AND** tercih edilen tarih ve saat görünür
- **AND** varsa notlar görünür
- **AND** gelen işletme yanıtları listelenir

#### Scenario: View Quote Response
- **WHEN** teklif detay sayfasında bir yanıt varsa
- **THEN** işletme adı görünür
- **AND** teklif edilen fiyat görünür
- **AND** işletme mesajı görünür
- **AND** işletmenin puanı görünür

---

### Requirement: Quote Request Closure
Kullanıcılar aktif tekliflerini kapatabilmeli.

#### Scenario: Close Active Quote
- **WHEN** aktif bir teklif detay sayfasındaki kullanıcı "Teklifi Kapat" butonuna tıklar
- **AND** onay verir
- **THEN** teklif durumu "Kapandı" olarak güncellenir
- **AND** işletmeler artık bu teklife yanıt veremez

---

### Requirement: Floating Action Button Navigation
Navbar'da merkezi bir teklif butonu bulunmalı.

#### Scenario: FAB Navigation
- **WHEN** uygulamanın herhangi bir ana sayfasındaki kullanıcı navbar'daki merkezi teklif butonuna tıklar
- **THEN** teklif oluşturma sayfası açılır

---

### Requirement: Quote Expiration
Teklifler belirli süre sonra otomatik kapanmalı.

#### Scenario: Quote Auto-Expiration
- **WHEN** 7 günden eski bir aktif teklif varsa
- **AND** sistem kontrol eder
- **THEN** teklif durumu otomatik "Kapandı" olarak güncellenir
