# Randevu Sistemi - Teknik Plan

## 📋 Genel Bakış

**Amaç**: İşletmelerin müşterileri için randevu oluşturmasını ve yönetmesini sağlayan bir sistem.

**Temel Özellikler**:
- ✅ Sadece işletme randevu oluşturabilir
- ✅ Var olan müşterilerden seçim yapılır
- ✅ **Birden fazla hizmet** seçimi (tek randevuda)
- ✅ **Uzman bazlı çakışma kontrolü** (aynı saatte farklı uzmanlar için randevu alınabilir)
- ✅ Otomatik süre hesaplama (seçilen hizmetlerin toplamı)
- ✅ Randevu durumu takibi (beklemede, onaylandı, tamamlandı, iptal)
- ✅ Bildirim sistemi entegrasyonu

---

## 🗄️ 1. Veritabanı Tasarımı

### 1.1. Customers Tablosu
**Durum**: ✅ Mevcut (CustomerService, CustomerProvider ile entegre)

```sql
-- Tablo zaten mevcut:
customers (
  id UUID PRIMARY KEY,
  owner_id UUID REFERENCES profiles(id),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  gender INTEGER,
  birth_date DATE,
  notes TEXT,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
)
```

### 1.2. Appointments Tablosu (YENİ)
**Oluşturulacak tablo**:

```sql
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- İlişkiler
  venue_id UUID REFERENCES venues(id) ON DELETE CASCADE NOT NULL,
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE NOT NULL,
  specialist_id UUID REFERENCES specialists(id), -- Opsiyonel, çakışma kontrolü uzman bazlı
  
  -- Randevu bilgileri
  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  total_duration_minutes INTEGER NOT NULL, -- Tüm hizmetlerin toplam süresi
  
  -- Durum
  status TEXT NOT NULL DEFAULT 'pending', 
  -- pending, confirmed, completed, cancelled, no_show
  
  -- Fiyat bilgisi (tüm hizmetlerin toplamı)
  total_price DECIMAL(10,2),
  
  -- Notlar
  notes TEXT,
  cancellation_reason TEXT,
  
  -- Zaman damgaları
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  cancelled_at TIMESTAMPTZ,
  
  -- Constraints
  CONSTRAINT valid_time_range CHECK (end_time > start_time),
  CONSTRAINT valid_duration CHECK (total_duration_minutes > 0),
  CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no_show'))
);

-- İndeksler
CREATE INDEX idx_appointments_venue_id ON appointments(venue_id);
CREATE INDEX idx_appointments_customer_id ON appointments(customer_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_specialist_id ON appointments(specialist_id) WHERE specialist_id IS NOT NULL;

-- Bileşik indeks: Uzman bazlı çakışma kontrolü için
CREATE INDEX idx_appointments_specialist_schedule ON appointments(specialist_id, appointment_date, start_time, end_time) 
WHERE status NOT IN ('cancelled', 'no_show') AND specialist_id IS NOT NULL;

-- Updated_at trigger
CREATE TRIGGER set_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 1.3. Appointment Services (Çoka-Çok İlişki) - YENİ
**Birden fazla hizmet için junction table**:

```sql
CREATE TABLE appointment_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE NOT NULL,
  service_id UUID REFERENCES venue_services(id) ON DELETE CASCADE NOT NULL,
  
  -- Hizmet sırası (birden fazla hizmet varsa)
  sort_order INTEGER NOT NULL DEFAULT 0,
  
  -- Hizmet detayları (o anki değerler, snapshot)
  service_name TEXT NOT NULL,
  service_price DECIMAL(10,2),
  service_duration_minutes INTEGER,
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- Unique constraint: Aynı randevuda aynı hizmet bir kez
  CONSTRAINT unique_appointment_service UNIQUE (appointment_id, service_id)
);

-- İndeksler
CREATE INDEX idx_appointment_services_appointment_id ON appointment_services(appointment_id);
CREATE INDEX idx_appointment_services_service_id ON appointment_services(service_id);
```

### 1.4. Appointment Notifications Tablosu (İSTEĞE BAĞLI)
**Gelecekte eklenebilir**:

```sql
CREATE TABLE appointment_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE NOT NULL,
  notification_type TEXT NOT NULL, -- reminder, confirmation, cancellation
  sent_at TIMESTAMPTZ,
  scheduled_for TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'pending', -- pending, sent, failed
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔒 2. Row Level Security (RLS) Politikaları

```sql
-- RLS'i etkinleştir
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- İşletme sahibi kendi mekanının randevularını görebilir
CREATE POLICY "Venue owners can view their appointments"
  ON appointments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

-- İşletme sahibi kendi mekanına randevu oluşturabilir
CREATE POLICY "Venue owners can create appointments"
  ON appointments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

-- İşletme sahibi kendi randevularını güncelleyebilir
CREATE POLICY "Venue owners can update their appointments"
  ON appointments FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

-- Silme (soft delete için UPDATE kullanılacak, bu opsiyonel)
CREATE POLICY "Venue owners can delete their appointments"
  ON appointments FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );
```

---

## 🔧 3. RPC Fonksiyonları

### 3.1. Çakışma Kontrolü (Uzman Bazlı)
```sql
CREATE OR REPLACE FUNCTION check_appointment_conflict(
  p_venue_id UUID,
  p_specialist_id UUID,
  p_date DATE,
  p_start_time TIME,
  p_end_time TIME,
  p_exclude_appointment_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_conflict_count INTEGER;
BEGIN
  -- ÖNEMLI: Çakışma kontrolü SADECE aynı uzman için yapılır
  -- Farklı uzmanlar aynı saatte randevu alabilir
  
  IF p_specialist_id IS NULL THEN
    -- Uzman seçilmemişse, venue bazlı kontrol (eski davranış)
    SELECT COUNT(*) INTO v_conflict_count
    FROM appointments
    WHERE venue_id = p_venue_id
      AND specialist_id IS NULL
      AND appointment_date = p_date
      AND status NOT IN ('cancelled', 'no_show')
      AND (p_exclude_appointment_id IS NULL OR id != p_exclude_appointment_id)
      AND (start_time, end_time) OVERLAPS (p_start_time, p_end_time);
  ELSE
    -- Uzman seçilmişse, o uzmana özel kontrol
    SELECT COUNT(*) INTO v_conflict_count
    FROM appointments
    WHERE specialist_id = p_specialist_id
      AND appointment_date = p_date
      AND status NOT IN ('cancelled', 'no_show')
      AND (p_exclude_appointment_id IS NULL OR id != p_exclude_appointment_id)
      AND (start_time, end_time) OVERLAPS (p_start_time, p_end_time);
  END IF;
  
  RETURN v_conflict_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3.2. Randevu İstatistikleri
```sql
CREATE OR REPLACE FUNCTION get_appointment_stats(p_venue_id UUID, p_date_from DATE, p_date_to DATE)
RETURNS TABLE (
  total_appointments BIGINT,
  pending_count BIGINT,
  confirmed_count BIGINT,
  completed_count BIGINT,
  cancelled_count BIGINT,
  no_show_count BIGINT,
  total_revenue DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_appointments,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_count,
    COUNT(*) FILTER (WHERE status = 'confirmed') as confirmed_count,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_count,
    COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_count,
    COUNT(*) FILTER (WHERE status = 'no_show') as no_show_count,
    COALESCE(SUM(total_price) FILTER (WHERE status = 'completed'), 0) as total_revenue
  FROM appointments
  WHERE venue_id = p_venue_id
    AND appointment_date BETWEEN p_date_from AND p_date_to;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3.3. Günlük Randevu Listesi (Detaylı - Birden Fazla Hizmet ile)
```sql
CREATE OR REPLACE FUNCTION get_daily_appointments(
  p_venue_id UUID, 
  p_date DATE
)
RETURNS TABLE (
  appointment_id UUID,
  customer_name TEXT,
  customer_phone TEXT,
  services JSONB, -- Birden fazla hizmet
  specialist_name TEXT,
  start_time TIME,
  end_time TIME,
  total_duration_minutes INTEGER,
  total_price DECIMAL,
  status TEXT,
  notes TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id as appointment_id,
    c.name as customer_name,
    c.phone as customer_phone,
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', aps.service_id,
          'name', aps.service_name,
          'price', aps.service_price,
          'duration', aps.service_duration_minutes,
          'order', aps.sort_order
        ) ORDER BY aps.sort_order
      )
      FROM appointment_services aps
      WHERE aps.appointment_id = a.id
    ) as services,
    sp.name as specialist_name,
    a.start_time,
    a.end_time,
    a.total_duration_minutes,
    a.total_price,
    a.status,
    a.notes
  FROM appointments a
  INNER JOIN customers c ON c.id = a.customer_id
  LEFT JOIN specialists sp ON sp.id = a.specialist_id
  WHERE a.venue_id = p_venue_id
    AND a.appointment_date = p_date
  ORDER BY a.start_time ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3.4. Uzman Müsaitlik Kontrolü
```sql
CREATE OR REPLACE FUNCTION get_specialist_availability(
  p_specialist_id UUID,
  p_date DATE,
  p_start_hour INTEGER DEFAULT 9,  -- Çalışma saati başlangıç (örn: 09:00)
  p_end_hour INTEGER DEFAULT 18    -- Çalışma saati bitiş (örn: 18:00)
)
RETURNS TABLE (
  time_slot TIME,
  is_available BOOLEAN,
  appointment_id UUID
) AS $$
BEGIN
  RETURN QUERY
  WITH time_slots AS (
    -- 30 dakikalık zaman dilimlerini oluştur
    SELECT (p_start_hour * INTERVAL '1 hour' + n * INTERVAL '30 minutes')::TIME as slot
    FROM generate_series(0, (p_end_hour - p_start_hour) * 2 - 1) n
  )
  SELECT 
    ts.slot,
    NOT EXISTS (
      SELECT 1 FROM appointments a
      WHERE a.specialist_id = p_specialist_id
        AND a.appointment_date = p_date
        AND a.status NOT IN ('cancelled', 'no_show')
        AND (a.start_time, a.end_time) OVERLAPS (ts.slot, ts.slot + INTERVAL '30 minutes')
    ) as is_available,
    (
      SELECT a.id FROM appointments a
      WHERE a.specialist_id = p_specialist_id
        AND a.appointment_date = p_date
        AND a.status NOT IN ('cancelled', 'no_show')
        AND (a.start_time, a.end_time) OVERLAPS (ts.slot, ts.slot + INTERVAL '30 minutes')
      LIMIT 1
    ) as appointment_id
  FROM time_slots ts
  ORDER BY ts.slot;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📱 4. Flutter Implementasyonu

### 4.1. Models

#### 4.1.1. AppointmentService Model (Hizmet-Randevu İlişkisi)

**Dosya**: `lib/data/models/appointment_service.dart`

```dart
class AppointmentService {
  final String id;
  final String appointmentId;
  final String serviceId;
  final int sortOrder;
  
  // Snapshot değerleri (o anki hizmet bilgileri)
  final String serviceName;
  final double? servicePrice;
  final int? serviceDurationMinutes;
  
  final DateTime createdAt;

  AppointmentService({
    required this.id,
    required this.appointmentId,
    required this.serviceId,
    required this.sortOrder,
    required this.serviceName,
    this.servicePrice,
    this.serviceDurationMinutes,
    required this.createdAt,
  });

  factory AppointmentService.fromJson(Map<String, dynamic> json) {
    return AppointmentService(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      serviceId: json['service_id'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      serviceName: json['service_name'] as String,
      servicePrice: (json['service_price'] as num?)?.toDouble(),
      serviceDurationMinutes: json['service_duration_minutes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'service_id': serviceId,
      'sort_order': sortOrder,
      'service_name': serviceName,
      'service_price': servicePrice,
      'service_duration_minutes': serviceDurationMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

#### 4.1.2. Appointment Model (Güncellenmiş)

**Dosya**: `lib/data/models/appointment.dart`

```dart
import 'appointment_service.dart';

class Appointment {
  final String id;
  final String venueId;
  final String customerId;
  final String? specialistId;
  
  final DateTime appointmentDate;
  final String startTime; // "14:30" formatında
  final String endTime;
  final int totalDurationMinutes; // Tüm hizmetlerin toplam süresi
  
  final String status; // pending, confirmed, completed, cancelled, no_show
  final double? totalPrice; // Tüm hizmetlerin toplam fiyatı
  
  final String? notes;
  final String? cancellationReason;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  
  // İlişkili hizmetler (birden fazla)
  final List<AppointmentService> services;
  
  // JOIN'den gelen ek bilgiler
  final String? customerName;
  final String? customerPhone;
  final String? specialistName;

  Appointment({
    required this.id,
    required this.venueId,
    required this.customerId,
    this.specialistId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.totalDurationMinutes,
    required this.status,
    this.totalPrice,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.services = const [],
    this.customerName,
    this.customerPhone,
    this.specialistName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Services JSONB'den parse et
    List<AppointmentService> servicesList = [];
    if (json['services'] != null) {
      if (json['services'] is List) {
        servicesList = (json['services'] as List)
            .map((s) => AppointmentService.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    }

    return Appointment(
      id: json['id'] as String? ?? json['appointment_id'] as String,
      venueId: json['venue_id'] as String,
      customerId: json['customer_id'] as String,
      specialistId: json['specialist_id'] as String?,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      totalDurationMinutes: json['total_duration_minutes'] as int,
      status: json['status'] as String,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
      services: servicesList,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      specialistName: json['specialist_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'customer_id': customerId,
      'specialist_id': specialistId,
      'appointment_date': appointmentDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'total_duration_minutes': totalDurationMinutes,
      'status': status,
      'total_price': totalPrice,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? venueId,
    String? customerId,
    String? specialistId,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    int? totalDurationMinutes,
    String? status,
    double? totalPrice,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    List<AppointmentService>? services,
    String? customerName,
    String? customerPhone,
    String? specialistName,
  }) {
    return Appointment(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      customerId: customerId ?? this.customerId,
      specialistId: specialistId ?? this.specialistId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      services: services ?? this.services,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      specialistName: specialistName ?? this.specialistName,
    );
  }
  
  /// Hizmet isimlerini birleştir (UI'da gösterim için)
  String get servicesDisplay {
    if (services.isEmpty) return 'Hizmet belirtilmemiş';
    return services.map((s) => s.serviceName).join(', ');
  }
}
```

### 4.2. Service: AppointmentService (Güncellenmiş)

**Dosya**: `lib/data/services/appointment_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';
import '../models/appointment_service.dart' as model;
import '../models/venue_service.dart';
import 'supabase_service.dart';

class AppointmentService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  static const String _tableName = 'appointments';
  static const String _servicesTableName = 'appointment_services';

  String? get _userId => _supabaseService.currentUser?.id;

  /// Belirli bir tarih için randevuları getir (detaylı, JOIN'li)
  Future<List<Appointment>> getAppointmentsByDate({
    required String venueId,
    required DateTime date,
  }) async {
    try {
      final response = await _supabaseService.rpc(
        'get_daily_appointments',
        params: {
          'p_venue_id': venueId,
          'p_date': date.toIso8601String().split('T')[0],
        },
      );

      return (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching appointments by date: $e');
      rethrow;
    }
  }

  /// Tarih aralığı için randevuları getir
  Future<List<Appointment>> getAppointmentsByDateRange({
    required String venueId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService
          .from(_tableName)
          .select('''
            *,
            customers!inner(name, phone),
            venue_services!inner(custom_name),
            specialists(name)
          ''')
          .eq('venue_id', venueId)
          .gte('appointment_date', startDate.toIso8601String().split('T')[0])
          .lte('appointment_date', endDate.toIso8601String().split('T')[0])
          .order('appointment_date', ascending: true)
          .order('start_time', ascending: true);

      return (response as List).map((json) {
        // Flatten nested relations
        return Appointment.fromJson({
          ...json,
          'customer_name': json['customers']?['name'],
          'customer_phone': json['customers']?['phone'],
          'service_name': json['venue_services']?['custom_name'],
          'specialist_name': json['specialists']?['name'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching appointments by range: $e');
      rethrow;
    }
  }

  /// Randevu çakışması kontrolü
  Future<bool> checkConflict({
    required String venueId,
    String? specialistId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeAppointmentId,
  }) async {
    try {
      final response = await _supabaseService.rpc(
        'check_appointment_conflict',
        params: {
          'p_venue_id': venueId,
          'p_specialist_id': specialistId,
          'p_date': date.toIso8601String().split('T')[0],
          'p_start_time': startTime,
          'p_end_time': endTime,
          'p_exclude_appointment_id': excludeAppointmentId,
        },
      );

      return response as bool;
    } catch (e) {
      print('Error checking appointment conflict: $e');
      rethrow;
    }
  }

  /// Yeni randevu oluştur (birden fazla hizmet ile)
  Future<Appointment> createAppointment({
    required Appointment appointment,
    required List<VenueService> selectedServices, // Seçilen hizmetler
  }) async {
    try {
      // Önce çakışma kontrolü (uzman bazlı)
      final hasConflict = await checkConflict(
        venueId: appointment.venueId,
        specialistId: appointment.specialistId,
        date: appointment.appointmentDate,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
      );

      if (hasConflict) {
        throw 'Bu uzmanın bu saatinde zaten bir randevu var!';
      }

      // Toplam süre ve fiyat hesapla
      int totalDuration = 0;
      double totalPrice = 0.0;
      
      for (var service in selectedServices) {
        totalDuration += service.durationMinutes ?? 0;
        totalPrice += service.price ?? 0.0;
      }

      // Randevu oluştur
      final appointmentData = appointment.toJson();
      appointmentData.remove('id');
      appointmentData.remove('created_at');
      appointmentData.remove('updated_at');
      appointmentData['total_duration_minutes'] = totalDuration;
      appointmentData['total_price'] = totalPrice;

      final appointmentResponse = await _supabaseService
          .from(_tableName)
          .insert(appointmentData)
          .select()
          .single();

      final newAppointmentId = appointmentResponse['id'] as String;

      // Hizmetleri ekle
      final servicesToInsert = selectedServices.asMap().entries.map((entry) {
        final index = entry.key;
        final service = entry.value;
        
        return {
          'appointment_id': newAppointmentId,
          'service_id': service.id,
          'sort_order': index,
          'service_name': service.serviceName ?? service.displayName,
          'service_price': service.price,
          'service_duration_minutes': service.durationMinutes,
        };
      }).toList();

      await _supabaseService
          .from(_servicesTableName)
          .insert(servicesToInsert);

      // Tam randevu verisini getir
      return await getAppointmentById(newAppointmentId);
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }
  
  /// Randevu ID'sine göre getir
  Future<Appointment> getAppointmentById(String appointmentId) async {
    try {
      final response = await _supabaseService
          .from(_tableName)
          .select('''
            *,
            customers!inner(name, phone),
            specialists(name),
            appointment_services(
              id,
              service_id,
              sort_order,
              service_name,
              service_price,
              service_duration_minutes,
              created_at
            )
          ''')
          .eq('id', appointmentId)
          .single();

      return Appointment.fromJson({
        ...response,
        'customer_name': response['customers']?['name'],
        'customer_phone': response['customers']?['phone'],
        'specialist_name': response['specialists']?['name'],
        'services': response['appointment_services'],
      });
    } catch (e) {
      print('Error fetching appointment by ID: $e');
      rethrow;
    }
  }

  /// Randevu güncelle
  Future<Appointment> updateAppointment(Appointment appointment) async {
    try {
      // Saat değişiyorsa çakışma kontrolü
      final data = appointment.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabaseService
          .from(_tableName)
          .update(data)
          .eq('id', appointment.id)
          .select()
          .single();

      return Appointment.fromJson(response);
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  /// Randevu durumunu güncelle
  Future<void> updateStatus({
    required String appointmentId,
    required String status,
    String? cancellationReason,
  }) async {
    try {
      final data = {
        'status': status,
        if (cancellationReason != null) 'cancellation_reason': cancellationReason,
        if (status == 'cancelled') 'cancelled_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService
          .from(_tableName)
          .update(data)
          .eq('id', appointmentId);
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  /// Randevu sil
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _supabaseService
          .from(_tableName)
          .delete()
          .eq('id', appointmentId);
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  /// Randevu istatistikleri
  Future<Map<String, dynamic>> getStats({
    required String venueId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await _supabaseService.rpc(
        'get_appointment_stats',
        params: {
          'p_venue_id': venueId,
          'p_date_from': fromDate.toIso8601String().split('T')[0],
          'p_date_to': toDate.toIso8601String().split('T')[0],
        },
      );

      return response[0] as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching appointment stats: $e');
      rethrow;
    }
  }
}
```

### 4.3. Provider: AppointmentProvider

**Dosya**: `lib/presentation/providers/appointment_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../data/models/appointment.dart';
import '../../data/services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _appointments = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Appointment> get appointments => _appointments;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Seçili tarihi değiştir
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Günlük randevuları getir
  Future<void> fetchDailyAppointments(String venueId, DateTime date) async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getAppointmentsByDate(
        venueId: venueId,
        date: date,
      );
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Yeni randevu oluştur
  Future<bool> createAppointment(Appointment appointment) async {
    _setLoading(true);
    _clearError();

    try {
      final newAppointment = await _appointmentService.createAppointment(appointment);
      _appointments.add(newAppointment);
      _appointments.sort((a, b) => a.startTime.compareTo(b.startTime));
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Randevu durumunu güncelle
  Future<bool> updateStatus({
    required String appointmentId,
    required String status,
    String? cancellationReason,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _appointmentService.updateStatus(
        appointmentId: appointmentId,
        status: status,
        cancellationReason: cancellationReason,
      );

      // Local state'i güncelle
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: status,
          cancellationReason: cancellationReason,
          cancelledAt: status == 'cancelled' ? DateTime.now() : null,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Randevu sil
  Future<bool> deleteAppointment(String appointmentId) async {
    _setLoading(true);
    _clearError();

    try {
      await _appointmentService.deleteAppointment(appointmentId);
      _appointments.removeWhere((a) => a.id == appointmentId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Duruma göre filtrele
  List<Appointment> filterByStatus(String status) {
    return _appointments.where((a) => a.status == status).toList();
  }

  /// Saat aralığına göre filtrele
  List<Appointment> filterByTimeRange(String startTime, String endTime) {
    return _appointments.where((a) {
      return a.startTime.compareTo(startTime) >= 0 && 
             a.endTime.compareTo(endTime) <= 0;
    }).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
```

---

## 🎨 5. UI Ekranları

### 5.1. Randevu Listesi Ekranı

**Dosya**: `lib/presentation/screens/business/admin/admin_appointments_screen.dart`

**Özellikler**:
- Takvim görünümü (günlük/haftalık)
- Randevu kartları (müşteri, hizmet, saat, durum)
- Durum filtreleme
- Yeni randevu ekle butonu
- Randevu detayına tıklama

### 5.2. Randevu Oluşturma Ekranı

**Dosya**: `lib/presentation/screens/business/admin/appointment_create_screen.dart`

**Form alanları**:
1. **Müşteri seçimi** (dropdown - mevcut customers'dan)
2. **Hizmet seçimi** (multi-select / chips - venue_services'den)
   - Birden fazla hizmet seçilebilir
   - Her hizmet için süre ve fiyat gösterilir
   - Toplam süre otomatik hesaplanır
3. **Uzman seçimi** (dropdown - specialists'den)
   - Seçilmezse genel randevu
   - Seçilirse uzman bazlı çakışma kontrolü
4. **Tarih seçimi** (date picker)
5. **Saat aralığı** (time picker - başlangıç)
   - Bitiş saati seçilen hizmetlerin toplam süresine göre otomatik hesaplanır
6. **Toplam süre** (salt okunur - otomatik hesaplanan)
7. **Toplam fiyat** (salt okunur - hizmetlerin toplamı)
8. **Notlar** (textarea)

**Validasyonlar**:
- Tüm zorunlu alanlar dolu mu?
- En az 1 hizmet seçilmeli
- Geçmiş tarih seçilemesin
- **Uzman bazlı çakışma kontrolü** (API çağrısı - sadece seçilen uzman için)
- Çalışma saatleri içinde mi?
- Toplam süre makul mu? (örn: max 8 saat)

### 5.3. Randevu Detay Ekranı

**Dosya**: `lib/presentation/screens/business/admin/appointment_detail_screen.dart`

**Özellikler**:
- Tüm randevu bilgileri
- **Hizmet listesi** (birden fazla hizmet gösterimi)
  - Her hizmet için isim, fiyat, süre
  - Toplam fiyat ve süre
- Müşteri bilgileri (telefon, notlar)
- Uzman bilgisi
- Durum değiştirme butonları
- İptal etme (sebep girişi ile)
- Düzenleme
- Silme (onay ile)

---

## 📍 6. Navigasyon & Routing

**app_router.dart'a eklenecekler**:

```dart
GoRoute(
  path: '/business/appointments',
  name: 'admin-appointments',
  builder: (context, state) => const AdminAppointmentsScreen(),
),
GoRoute(
  path: '/business/appointments/create',
  name: 'appointment-create',
  builder: (context, state) => const AppointmentCreateScreen(),
),
GoRoute(
  path: '/business/appointments/:id',
  name: 'appointment-detail',
  builder: (context, state) {
    final appointmentId = state.pathParameters['id']!;
    return AppointmentDetailScreen(appointmentId: appointmentId);
  },
),
```

**BusinessBottomNav'e eklenecek**:
- Yeni bir "Randevular" tab'i (icon: Icons.calendar_today)

---

## 🔔 7. Bildirim Sistemi (Gelecek Faz)

**Bildirim senaryoları**:
- Randevu oluşturulduğunda müşteriye SMS/bildirim
- 24 saat önce hatırlatma
- Randevu iptal edildiğinde bildirim
- Durum değişikliği bildirimleri

**Gereksinimler**:
- Firebase Cloud Messaging entegrasyonu (mevcut)
- SMS servisi entegrasyonu (Twilio, Netgsm vb.)
- Bildirim izinleri

---

## ✅ 8. Implementasyon Adımları

### Faz 1: Database (2-3 saat)
1. ✅ `appointments` tablosunu oluştur (migration)
2. ✅ `appointment_services` junction table oluştur
3. ✅ RLS politikalarını ekle (her iki tablo için)
4. ✅ RPC fonksiyonlarını oluştur
   - `check_appointment_conflict` (uzman bazlı)
   - `get_daily_appointments` (JSONB services ile)
   - `get_appointment_stats`
   - `get_specialist_availability`
5. ✅ Triggerleri ekle (updated_at)

### Faz 2: Backend - Flutter Models & Services (3-4 saat)
6. ✅ `AppointmentService` model oluştur (junction model)
7. ✅ `Appointment` model oluştur (birden fazla hizmet desteği ile)
8. ✅ `AppointmentService` (data service) oluştur
   - `createAppointment` (birden fazla hizmet ile)
   - `getAppointmentById` (hizmetler dahil)
9. ✅ `AppointmentProvider` oluştur
10. ✅ Unit testler yaz

### Faz 3: UI - Randevu Listesi (3-4 saat)
9. ✅ `AdminAppointmentsScreen` oluştur
10. ✅ Takvim widget'ı ekle
11. ✅ Randevu kartları tasarla
12. ✅ Filtreleme özellikleri

### Faz 4: UI - Randevu Oluşturma (5-6 saat)
13. ✅ `AppointmentCreateScreen` oluştur
14. ✅ Form validation
15. ✅ **Multi-select hizmet seçimi widget'ı**
   - Chip-based hizmet listesi
   - Toplam süre/fiyat gösterimi
   - Hizmet ekleme/çıkarma
16. ✅ Müşteri/uzman seçimi
17. ✅ Tarih/saat seçimi
18. ✅ **Uzman bazlı çakışma kontrolü entegrasyonu**
19. ✅ Otomatik süre hesaplama

### Faz 5: UI - Randevu Detay & Düzenleme (3-4 saat)
20. ✅ `AppointmentDetailScreen` oluştur
21. ✅ **Birden fazla hizmet gösterimi**
22. ✅ Durum değiştirme
23. ✅ İptal/silme özellikleri

### Faz 6: Navigasyon & Entegrasyon (1-2 saat)
24. ✅ Router konfigürasyonu
25. ✅ BusinessBottomNav'e tab ekle
26. ✅ Provider'ı app'e kaydet (main.dart)

### Faz 7: Test & Polish (2-3 saat)
27. ✅ End-to-end test (birden fazla hizmet ile randevu)
28. ✅ Edge case'leri test et
   - Uzman çakışması
   - Farklı uzmanlar aynı saat
   - Çok uzun toplam süre
29. ✅ UI/UX iyileştirmeleri
30. ✅ Error handling

**Toplam Tahmini Süre**: 18-26 saat

---

## 🎯 9. Gelecek İyileştirmeler

- 📅 Haftalık/aylık takvim görünümü
- 🔄 Tekrarlayan randevular
- 📊 Randevu istatistikleri dashboard'u
- 🔔 Otomatik hatırlatma sistemi
- 💬 Müşteri geri bildirim sistemi
- 📱 Müşteri self-servis randevu (mobil uygulama)
- 🤖 Otomatik randevu önerileri (AI)
- 📧 Email bildirimleri
- 📈 Kapasite yönetimi ve optimizasyon

---

## 📚 10. Referanslar

- Mevcut `Customer` sistemi
- Mevcut `VenueService` ve `Specialist` modelleri
- Supabase RLS best practices
- Flutter Provider state management pattern
- App router yapısı

---

---

## 🔑 Önemli Notlar

### Birden Fazla Hizmet Sistemi
- `appointment_services` junction table ile many-to-many ilişki
- Her hizmet için snapshot (o anki fiyat/süre) saklanır
- Toplam süre ve fiyat `appointments` tablosunda aggregate olarak tutulur

### Uzman Bazlı Çakışma Kontrolü
- Çakışma kontrolü **sadece aynı uzman için** yapılır
- Farklı uzmanlar **aynı saatte** randevu alabilir
- Uzman seçilmezse venue-level kontrol yapılır (eski davranış)

### Veri Bütünlüğü
- Hizmet bilgileri snapshot olarak saklanır (fiyat/süre değişirse eski randevular etkilenmez)
- CASCADE DELETE: Randevu silinirse hizmetleri de silinir
- Constraints ile veri tutarlılığı sağlanır

---

**Oluşturulma Tarihi**: 27 Ocak 2026  
**Son Güncelleme**: 27 Ocak 2026  
**Versiyon**: 2.0 (Birden fazla hizmet + Uzman bazlı çakışma)  
**Durum**: 📋 Planlama Tamamlandı - İmplementasyon Hazır
