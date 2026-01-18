import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location service for geolocation and geocoding features
/// Handles location permissions, current location, and address conversion
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    // Check permission
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Konum izni reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin.',
      );
    }

    // Get position
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get position stream for real-time location updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Calculate distance between two points (in meters)
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return _formatAddress(place);
      }
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address (geocoding)
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Format placemark to readable address
  String _formatAddress(Placemark place) {
    final parts = <String>[];

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }

    return parts.join(', ');
  }

  /// Format distance to human-readable string
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Get full placemark data from coordinates
  Future<Placemark?> getPlacemarkFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      print('Error getting placemark from coordinates: $e');
      return null;
    }
  }

  /// Extract province and district from coordinates
  /// Returns a map with 'province' and 'district' keys
  Future<Map<String, String>?> extractProvinceAndDistrictFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemark = await getPlacemarkFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      if (placemark == null) return null;

      return extractProvinceAndDistrictFromPlacemark(placemark);
    } catch (e) {
      print('Error extracting province and district: $e');
      return null;
    }
  }

  /// Extract province and district from a Placemark
  Map<String, String>? extractProvinceAndDistrictFromPlacemark(
    Placemark placemark,
  ) {
    // In Turkey, administrativeArea is typically the province (il)
    // and subAdministrativeArea or locality is the district (ilçe)
    String? province = placemark.administrativeArea;
    String? district =
        placemark.subAdministrativeArea ??
        placemark.locality ??
        placemark.subLocality;

    // Handle special cases where district might be in different fields
    if (district == null || district.isEmpty) {
      district = placemark.locality ?? placemark.subLocality;
    }

    // If we still don't have a district, use a placeholder
    if (district == null || district.isEmpty) {
      district = 'Merkez';
    }

    if (province == null || province.isEmpty) {
      return null;
    }

    // Clean up the names (remove "Province" suffix if present)
    province = province
        .replaceAll(' Province', '')
        .replaceAll(' İli', '')
        .trim();

    return {'province': province, 'district': district};
  }
}

/// Custom exception for location service disabled
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([this.message = 'Konum servisleri kapalı']);

  @override
  String toString() => message;
}

/// Custom exception for permission denied
class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException([this.message = 'İzin reddedildi']);

  @override
  String toString() => message;
}
