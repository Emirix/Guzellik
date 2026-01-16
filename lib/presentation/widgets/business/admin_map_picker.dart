import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/location_service.dart';

class AdminMapPicker extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng location, String? address) onLocationSelected;

  const AdminMapPicker({
    super.key,
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<AdminMapPicker> createState() => _AdminMapPickerState();
}

class _AdminMapPickerState extends State<AdminMapPicker> {
  GoogleMapController? _mapController;
  late LatLng _selectedLocation;
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation.latitude == 0 && _selectedLocation.longitude == 0) {
      _initializeCurrentLocation();
    } else {
      _updateAddress(_selectedLocation);
    }
  }

  Future<void> _initializeCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedLocation = newLocation;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 15),
        );
        await _updateAddress(newLocation);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    try {
      final address = await _locationService.getAddressFromCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (mounted) {
        setState(() {
          _selectedAddress = address;
        });
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateAddress(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Konum Seç',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1B0E11)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onLocationSelected(_selectedLocation, _selectedAddress);
              Navigator.pop(context);
            },
            child: const Text(
              'BİTTİ',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation.latitude == 0
                  ? const LatLng(41.0082, 28.9784)
                  : _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) async {
              _mapController = controller;
              try {
                final style = await DefaultAssetBundle.of(
                  context,
                ).loadString('assets/maps/rose_premium_style.json');
                await _mapController?.setMapStyle(style);
              } catch (e) {
                debugPrint('Map style loading failed: $e');
              }
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onTap: _onMapTapped,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: _onMapTapped,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Custom button used below
          ),

          // Address bar
          if (_selectedAddress != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedAddress!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1B0E11),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Controls
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: _initializeCurrentLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onLocationSelected(
                        _selectedLocation,
                        _selectedAddress,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'KONUMU ONAYLA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
