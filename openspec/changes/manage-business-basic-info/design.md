# Design: İşletme Temel Bilgileri Yönetimi

## Overview

Bu tasarım dokümanı, işletme sahiplerinin mobil yönetim panelinden temel işletme bilgilerini düzenleyebilmeleri için teknik mimariyi açıklar. Çözüm, mevcut `add-mobile-business-admin` yapısına entegre olur ve venues tablosundaki mevcut alanları kullanır.

## Architecture

### Screen Hierarchy

```
AdminDashboardScreen (Yönetim Ana Ekranı)
  └── AdminBasicInfoScreen (Temel Bilgiler) ← YENİ
      ├── AdminWorkingHoursScreen (Çalışma Saatleri) ← YENİ
      └── AdminLocationScreen (Konum ve Adres) ← YENİ
```

### Route Structure

```
/business/admin
  └── /business/admin/basic-info
      ├── /business/admin/basic-info/working-hours
      └── /business/admin/basic-info/location
```

### Data Flow

```
User Input → Provider → Supabase Client → Database
                ↓
         Optimistic UI Update
                ↓
         Real Response → Update State → Notify Listeners
                                            ↓
                                    VenueDetailsScreen Auto-Refresh
```

## Database Schema

### Venues Table (Existing)

Kullanılacak alanlar:

```sql
CREATE TABLE venues (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  location GEOGRAPHY(POINT, 4326),
  
  -- Contact Info
  phone TEXT,
  email TEXT,
  
  -- JSONB Fields
  working_hours JSONB DEFAULT '{}'::jsonb,
  social_links JSONB DEFAULT '{}'::jsonb,
  
  -- Location IDs
  province_id INTEGER,
  district_id TEXT,
  
  -- Ownership
  owner_id UUID REFERENCES profiles(id),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### JSONB Structures

**working_hours:**
```json
{
  "monday": {
    "open": true,
    "start": "09:00",
    "end": "20:00",
    "break_start": "13:00",  // opsiyonel
    "break_end": "14:00"     // opsiyonel
  },
  "tuesday": { ... },
  "wednesday": { ... },
  "thursday": { ... },
  "friday": { ... },
  "saturday": { ... },
  "sunday": {
    "open": false
  },
  "holidays": "Resmi tatillerde kapalı"  // opsiyonel
}
```

**social_links:**
```json
{
  "instagram": "https://instagram.com/username",
  "whatsapp": "+905551234567",
  "facebook": "https://facebook.com/page",
  "website": "https://example.com"
}
```

## Provider Architecture

### AdminBasicInfoProvider

```dart
class AdminBasicInfoProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  
  // State
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _venueData;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get venueData => _venueData;
  
  // Methods
  Future<void> loadVenueBasicInfo(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _supabase
          .from('venues')
          .select('id, name, description, address, phone, email, social_links')
          .eq('id', venueId)
          .single();
      
      _venueData = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateBasicInfo({
    required String venueId,
    String? name,
    String? description,
    String? phone,
    String? email,
    Map<String, dynamic>? socialLinks,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (phone != null) updateData['phone'] = phone;
      if (email != null) updateData['email'] = email;
      if (socialLinks != null) updateData['social_links'] = socialLinks;
      
      await _supabase
          .from('venues')
          .update(updateData)
          .eq('id', venueId);
      
      // Optimistic update
      _venueData = {...?_venueData, ...updateData};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Validation methods
  bool validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\s'), ''));
  }
  
  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  bool validateUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
```

### AdminWorkingHoursProvider

```dart
class AdminWorkingHoursProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  
  Map<String, dynamic> _workingHours = {};
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic> get workingHours => _workingHours;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadWorkingHours(String venueId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _supabase
          .from('venues')
          .select('working_hours')
          .eq('id', venueId)
          .single();
      
      _workingHours = response['working_hours'] ?? _getDefaultWorkingHours();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void updateDayHours(String day, Map<String, dynamic> hours) {
    _workingHours[day] = hours;
    notifyListeners();
  }
  
  void applyToAllDays(Map<String, dynamic> hours) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    for (final day in days) {
      _workingHours[day] = {...hours};
    }
    notifyListeners();
  }
  
  Future<void> saveWorkingHours(String venueId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase
          .from('venues')
          .update({'working_hours': _workingHours})
          .eq('id', venueId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  Map<String, dynamic> _getDefaultWorkingHours() {
    return {
      'monday': {'open': true, 'start': '09:00', 'end': '18:00'},
      'tuesday': {'open': true, 'start': '09:00', 'end': '18:00'},
      'wednesday': {'open': true, 'start': '09:00', 'end': '18:00'},
      'thursday': {'open': true, 'start': '09:00', 'end': '18:00'},
      'friday': {'open': true, 'start': '09:00', 'end': '18:00'},
      'saturday': {'open': true, 'start': '09:00', 'end': '18:00'},
      'sunday': {'open': false},
    };
  }
}
```

### AdminLocationProvider

```dart
class AdminLocationProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  
  String? _address;
  double? _latitude;
  double? _longitude;
  int? _provinceId;
  String? _districtId;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  String? get address => _address;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  int? get provinceId => _provinceId;
  String? get districtId => _districtId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadLocation(String venueId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _supabase
          .from('venues')
          .select('address, latitude, longitude, province_id, district_id')
          .eq('id', venueId)
          .single();
      
      _address = response['address'];
      _latitude = response['latitude'];
      _longitude = response['longitude'];
      _provinceId = response['province_id'];
      _districtId = response['district_id'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void updateAddress(String address) {
    _address = address;
    notifyListeners();
  }
  
  void updateCoordinates(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }
  
  void updateProvinceDistrict(int provinceId, String districtId) {
    _provinceId = provinceId;
    _districtId = districtId;
    notifyListeners();
  }
  
  Future<void> saveLocation(String venueId) async {
    if (_latitude == null || _longitude == null) {
      throw Exception('Konum bilgileri eksik');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Update with PostGIS point
      await _supabase.rpc('update_venue_location', params: {
        'venue_id': venueId,
        'new_address': _address,
        'new_latitude': _latitude,
        'new_longitude': _longitude,
        'new_province_id': _provinceId,
        'new_district_id': _districtId,
      });
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
```

## UI Components

### AdminBasicInfoScreen

```dart
class AdminBasicInfoScreen extends StatefulWidget {
  final String venueId;
  
  const AdminBasicInfoScreen({required this.venueId});
  
  @override
  State<AdminBasicInfoScreen> createState() => _AdminBasicInfoScreenState();
}

class _AdminBasicInfoScreenState extends State<AdminBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _instagramController;
  late TextEditingController _whatsappController;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temel Bilgiler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Consumer<AdminBasicInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // İşletme Adı
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'İşletme Adı',
                    hintText: 'Örn: Güzellik Salonu',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İşletme adı zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Tanıtım Yazısı
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Tanıtım Yazısı',
                    hintText: 'İşletmenizi tanıtın...',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                
                // Telefon
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: '+90 555 123 45 67',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!provider.validatePhone(value)) {
                        return 'Geçerli bir telefon numarası girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // E-posta
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'ornek@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!provider.validateEmail(value)) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Sosyal Medya Başlığı
                const Text(
                  'Sosyal Medya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Instagram
                TextFormField(
                  controller: _instagramController,
                  decoration: const InputDecoration(
                    labelText: 'Instagram',
                    hintText: 'https://instagram.com/kullaniciadi',
                    prefixIcon: Icon(Icons.camera_alt),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!provider.validateUrl(value)) {
                        return 'Geçerli bir URL girin';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // WhatsApp
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    hintText: '+90 555 123 45 67',
                    prefixIcon: Icon(Icons.chat),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                
                // Çalışma Saatleri Butonu
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Çalışma Saatleri'),
                  subtitle: const Text('Pzt-Cmt: 09:00 - 20:00'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/business/admin/basic-info/working-hours');
                  },
                ),
                
                // Konum Butonu
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Konum ve Adres'),
                  subtitle: Text(_addressController.text),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/business/admin/basic-info/location');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<AdminBasicInfoProvider>();
    
    try {
      await provider.updateBasicInfo(
        venueId: widget.venueId,
        name: _nameController.text,
        description: _descriptionController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        socialLinks: {
          'instagram': _instagramController.text,
          'whatsapp': _whatsappController.text,
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Değişiklikler kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
```

## Database Functions

### update_venue_location (RPC)

```sql
CREATE OR REPLACE FUNCTION update_venue_location(
  venue_id UUID,
  new_address TEXT,
  new_latitude DOUBLE PRECISION,
  new_longitude DOUBLE PRECISION,
  new_province_id INTEGER,
  new_district_id TEXT
)
RETURNS VOID AS $$
BEGIN
  UPDATE venues
  SET
    address = new_address,
    latitude = new_latitude,
    longitude = new_longitude,
    location = ST_SetSRID(ST_MakePoint(new_longitude, new_latitude), 4326)::geography,
    province_id = new_province_id,
    district_id = new_district_id,
    updated_at = NOW()
  WHERE id = venue_id AND owner_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Security (RLS)

Mevcut RLS politikaları yeterli:

```sql
-- Owners can manage their venues
CREATE POLICY "Owners can manage their venues" 
  ON venues 
  FOR ALL 
  USING (auth.uid() = owner_id);
```

## Design Considerations

### 1. Form Validation
- Client-side validation (immediate feedback)
- Server-side validation (security)
- Türkçe hata mesajları

### 2. Optimistic Updates
- UI anında güncellenir
- Hata durumunda rollback
- Loading states minimal

### 3. Data Consistency
- JSONB yapıları doğru parse edilmeli
- Null safety
- Default values

### 4. User Experience
- Auto-save (opsiyonel)
- Unsaved changes warning
- Success/error feedback
- Responsive design

## Testing Strategy

### Unit Tests
- Provider validation methods
- JSONB parsing logic
- Form validators

### Widget Tests
- Form rendering
- Validation messages
- Button interactions

### Integration Tests
- End-to-end update flow
- RLS policy enforcement
- Data persistence

## Performance Considerations

- Debounce form inputs
- Lazy load location data
- Cache venue data
- Minimize Supabase calls

## Future Enhancements

- Bulk edit for working hours
- Location history
- Address verification
- Social media preview
- Multi-language support
