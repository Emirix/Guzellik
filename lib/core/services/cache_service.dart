/// TTL destekli hafıza içi cache servisi

/// TTL destekli hafıza içi cache servisi
/// Sık kullanılan verilerin tekrar tekrar sorgulanmasını önler
class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  static CacheService get instance => _instance;
  CacheService._internal();

  /// Cache storage: key -> (data, expiry time)
  final Map<String, _CacheEntry> _cache = {};

  /// Default TTL değerleri (saniye cinsinden)
  static const int categoriesTTL = 1800; // 30 dakika
  static const int featuredVenuesTTL = 300; // 5 dakika
  static const int venueDetailsTTL = 120; // 2 dakika
  static const int servicesTTL = 600; // 10 dakika

  /// Cache key'leri
  static const String categoriesKey = 'venue_categories';
  static const String featuredVenuesKey = 'featured_venues';
  static String venueDetailKey(String id) => 'venue_$id';
  static String venueServicesKey(String venueId) => 'venue_services_$venueId';

  /// Cache'den veri oku
  /// Eğer cache'de yoksa veya süresi dolmuşsa null döner
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T;
  }

  /// Cache'e veri yaz
  void set<T>(String key, T data, {int ttlSeconds = 300}) {
    final expiry = DateTime.now().add(Duration(seconds: ttlSeconds));
    _cache[key] = _CacheEntry(data: data, expiry: expiry);
  }

  /// Belirli bir key'i cache'den sil
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Pattern ile eşleşen tüm key'leri sil
  void invalidatePattern(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }

  /// Tüm cache'i temizle
  void clear() {
    _cache.clear();
  }

  /// Cache istatistikleri (debug için)
  Map<String, dynamic> get stats => {
    'totalEntries': _cache.length,
    'keys': _cache.keys.toList(),
  };
}

/// Cache entry wrapper
class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
