# Design: add-search-screen

## Architecture Overview

Bu değişiklik mevcut discovery sisteminin genişletilmesiyle arama ve filtreleme özelliklerini ayrı bir ekran olarak sunar.

```
┌─────────────────────────────────────────────────────────────┐
│                     HomeScreen                               │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐        │
│  │ Keşfet  │   Ara   │Favoriler│Bildirim │ Profil  │        │
│  │ (0)     │   (1)   │   (2)   │   (3)   │   (4)   │        │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     SearchScreen                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              SearchHeader                            │    │
│  │  [← Back] [Search Input] [Map Toggle]               │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              FilterChips                             │    │
│  │  [Filtrele] [En Yakın ▼] [4.5+ ⭐] [Şu An Açık]   │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         Content (State-based)                        │    │
│  │  - Empty: RecentSearches + PopularServices          │    │
│  │  - Results: SearchResultsList                        │    │
│  │  - Loading: Shimmer/Skeleton                         │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## State Management

### SearchProvider
```dart
class SearchProvider extends ChangeNotifier {
  // Arama durumu
  String _searchQuery = '';
  bool _isLoading = false;
  List<Venue> _searchResults = [];
  String? _errorMessage;
  
  // Filtreler
  SearchFilter _filter = SearchFilter.empty();
  
  // Son aramalar (local)
  List<RecentSearch> _recentSearches = [];
  
  // Popüler hizmetler
  List<Service> _popularServices = [];
  
  // Konum
  String? _selectedProvince;
  String? _selectedDistrict;
  LatLng? _userLocation;
}
```

### SearchFilter Model
```dart
class SearchFilter {
  final String? province;          // İl
  final String? district;          // İlçe
  final double? maxDistanceKm;     // Mesafe (km)
  final List<String> serviceIds;   // Seçili hizmetler
  final List<String> venueTypes;   // Mekan türleri
  final double? minRating;         // Min puan
  final bool onlyVerified;         // Onaylı mekanlar
  final bool onlyHygienic;         // Hijyen onaylı
  final bool onlyPreferred;        // En çok tercih
  final bool isOpenNow;            // Şu an açık
  final SortOption sortBy;         // Sıralama
}

enum SortOption { recommended, nearest, highestRated, mostReviewed }
```

### RecentSearch Model
```dart
class RecentSearch {
  final String id;
  final String query;
  final String? location;         // "Nişantaşı, İstanbul"
  final DateTime timestamp;
  final SearchType type;          // venue, service, location
}

enum SearchType { venue, service, location }
```

## Component Hierarchy

```
SearchScreen
├── SearchHeader
│   ├── BackButton
│   ├── SearchInputField (tappable -> focuses)
│   │   ├── SearchIcon
│   │   ├── QueryText / PlaceholderText
│   │   ├── LocationSubtext
│   │   └── ClearButton
│   └── MapToggleButton
├── FilterChipsRow (horizontal scroll)
│   ├── FilterButton -> SearchFilterBottomSheet
│   ├── SortChip (dropdown)
│   ├── RatingChip
│   ├── OpenNowChip
│   └── CampaignChip
└── SearchContent (conditional)
    ├── [Empty State]
    │   ├── RecentSearchesSection
    │   │   ├── SectionHeader ("Son Aramalar", "Temizle")
    │   │   └── RecentSearchTile (list)
    │   └── PopularServicesSection
    │       ├── SectionHeader ("Popüler Hizmetler")
    │       └── ServiceChip (wrap)
    ├── [Results State]
    │   ├── ResultsHeader ("X sonuç bulundu", Sort dropdown)
    │   └── SearchResultCard (list)
    │       ├── VenueImage (with distance badge)
    │       ├── VenueInfo
    │       │   ├── VenueName + FavoriteButton
    │       │   ├── LocationText
    │       │   ├── RatingRow
    │       │   ├── ServiceTags
    │       │   └── ActionRow (time ago, button)
    │       └── Divider
    └── [Loading State]
        └── ShimmerCards
```

## Filter Bottom Sheet Structure

```
SearchFilterBottomSheet
├── SheetHeader
│   ├── CloseButton (X)
│   ├── Title ("Filtrele")
│   └── ResetButton ("Temizle")
├── SheetContent (scrollable)
│   ├── SortSection
│   │   └── SortOptionChips (Önerilen, Fiyat Artan, Fiyat Azalan)
│   ├── LocationSection
│   │   ├── ProvinceDropdown (İl)
│   │   ├── DistrictDropdown (İlçe) - dependent on province
│   │   └── UseMyLocationButton
│   ├── DistanceSection
│   │   ├── DistanceSlider (1-50 km)
│   │   └── CurrentValue label
│   ├── VenueTypeSection
│   │   └── VenueTypeChips (multi-select)
│   │       ├── Güzellik Salonu
│   │       ├── Kuaför
│   │       ├── Estetik Kliniği
│   │       ├── Tırnak Stüdyosu
│   │       ├── Solaryum
│   │       └── Ayak Bakım
│   ├── ServicesSection
│   │   ├── "Tümünü Gör" link
│   │   └── ServiceChips (from DB, multi-select)
│   ├── RatingSection
│   │   └── StarRatingSelector
│   └── TrustBadgesSection
│       ├── VerifiedCheckbox
│       ├── HygienicCheckbox
│       └── PreferredCheckbox
└── ApplyButton
    └── "Sonuçları Göster (X)" - shows result count
```

## Data Flow

```
                    ┌──────────────┐
                    │ User Action  │
                    └──────┬───────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  Search  │    │  Filter  │    │  Select  │
    │  Query   │    │  Change  │    │  Recent  │
    └────┬─────┘    └────┬─────┘    └────┬─────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
                ┌────────────────┐
                │ SearchProvider │
                │  updateSearch  │
                └────────┬───────┘
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
┌─────────────────┐             ┌─────────────────┐
│ VenueRepository │             │ LocalStorage    │
│ searchAdvanced  │             │ saveRecentSearch│
└────────┬────────┘             └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Supabase RPC  │
│ search_venues_  │
│    advanced     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Search Results │
│   → UI Update   │
└─────────────────┘
```

## Location Flow

```
App Start
    │
    ▼
Check Location Permission
    │
    ├── Granted ────────────────┐
    │                           ▼
    │                   Get Current Location
    │                           │
    │                           ▼
    │                   Reverse Geocode
    │                   (lat,lng → il,ilçe)
    │                           │
    │                           ▼
    │                   Set Default Filter
    │                           │
    └── Denied ─────────────────┤
                                ▼
                    Show Location Prompt
                    in Filter Sheet
                                │
                                ▼
                    User manually selects
                    Province/District
```

## Local Storage Schema

```json
// SharedPreferences keys
{
  "recent_searches": [
    {
      "id": "uuid-1",
      "query": "Lazer Epilasyon",
      "location": "Nişantaşı, İstanbul",
      "timestamp": "2026-01-08T19:00:00Z",
      "type": "service"
    },
    {
      "id": "uuid-2", 
      "query": "Vogue Beauty Center",
      "location": null,
      "timestamp": "2026-01-08T18:30:00Z",
      "type": "venue"
    }
  ],
  "last_search_filter": {
    "province": "İstanbul",
    "district": "Şişli",
    "maxDistanceKm": 10,
    "serviceIds": ["svc-1", "svc-2"],
    "venueTypes": ["beauty_salon"],
    "minRating": 4.0
  }
}
```

## Navigation Integration

### Current Navbar (4 items):
```
[Keşfet] [Favoriler] [Bildirimler] [Profil]
   0         1            2           3
```

### Updated Navbar (5 items):
```
[Keşfet] [Ara] [Favoriler] [Bildirimler] [Profil]
   0       1       2            3           4
```

### Search Bar Integration
- Keşfet ekranındaki arama çubuğuna tıklandığında `SearchScreen`'e navigate edilecek
- `AppStateProvider.setBottomNavIndex(1)` ile Ara sekmesine geçiş

## Performance Considerations

1. **Debounced Search**: Kullanıcı yazarken 300ms debounce
2. **Cached Services**: Hizmet listesi bir kez çekilip cache'lenecek
3. **Lazy Loading**: Sonuçlar pagination ile yüklenecek
4. **Optimistic UI**: Filtre değişikliklerinde anında UI güncelleme

## Error Handling

| Durum | Davranış |
|-------|----------|
| Konum izni yok | İl/ilçe manuel seçim göster |
| Ağ hatası | Retry butonu ile hata mesajı |
| Sonuç yok | "Aradığınız bulunamadı" + öneriler |
| Servis yüklenemedi | Varsayılan kategori chip'leri göster |
