import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/map_marker_utils.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../data/models/venue.dart';
import '../venue/venue_card.dart';

class DiscoveryMapView extends StatefulWidget {
  const DiscoveryMapView({super.key});

  @override
  State<DiscoveryMapView> createState() => _DiscoveryMapViewState();
}

class _DiscoveryMapViewState extends State<DiscoveryMapView>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  final Map<String, BitmapDescriptor> _markerIcons = {};
  bool _cameraInitialized = false;

  // Selected venue for showing single card
  Venue? _selectedVenue;

  @override
  bool get wantKeepAlive => true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 15,
    tilt: 30.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkerIcons();
    });
  }

  @override
  void dispose() {
    // Dispose the map controller to stop GPU surface updates
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    if (!mounted) return;
    final provider = context.read<DiscoveryProvider>();
    if (provider.venues.isEmpty) return;

    final Map<String, BitmapDescriptor> icons = {};
    for (final venue in provider.venues) {
      if (_markerIcons.containsKey(venue.id)) continue;

      final String label = venue.rating > 0
          ? venue.rating.toStringAsFixed(1)
          : '';

      // Get category icon
      final IconData categoryIcon = IconUtils.getCategoryIcon(
        venue.icon ?? venue.category?.icon,
      );

      try {
        final icon = await MapMarkerUtils.createCustomMarkerBitmap(
          label,
          isActive: false,
          categoryIcon: categoryIcon,
        );
        icons[venue.id] = icon;
      } catch (e) {
        debugPrint('Error creating marker for ${venue.id}: $e');
      }
    }

    if (mounted && icons.isNotEmpty) {
      setState(() {
        _markerIcons.addAll(icons);
      });
    }
  }

  void _onMarkerTapped(Venue venue) {
    setState(() {
      // If same venue tapped again, close the card
      if (_selectedVenue?.id == venue.id) {
        _selectedVenue = null;
      } else {
        _selectedVenue = venue;
      }
    });

    // Animate camera to the selected venue
    if (_selectedVenue != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(venue.latitude, venue.longitude)),
      );
    }
  }

  void _onMapTapped(LatLng position) {
    // Close the card when tapping on the map
    if (_selectedVenue != null) {
      setState(() {
        _selectedVenue = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        // Trigger icon load if venues changed
        if (provider.venues.any((v) => !_markerIcons.containsKey(v.id))) {
          Future.microtask(() => _loadMarkerIcons());
        }

        return Stack(
          children: [
            // 1. Google Map - PERF: RepaintBoundary isolates PlatformView GPU updates
            RepaintBoundary(
              child: GoogleMap(
                initialCameraPosition: provider.currentPosition != null
                    ? CameraPosition(
                        target: LatLng(
                          provider.currentPosition!.latitude,
                          provider.currentPosition!.longitude,
                        ),
                        zoom: 15,
                        tilt: 30.0,
                      )
                    : _initialPosition,
                onMapCreated: (controller) async {
                  _mapController = controller;
                  final style = await DefaultAssetBundle.of(
                    context,
                  ).loadString('assets/maps/rose_premium_style.json');
                  _mapController!.setMapStyle(style);
                  _initializeCamera(provider);
                },
                onTap: _onMapTapped,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                }.toSet(),
                markers: _buildMarkers(provider),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                tiltGesturesEnabled: true,
                rotateGesturesEnabled: true,
              ),
            ),

            // 2. Right Side Controls
            Positioned(
              right: 16,
              top: MediaQuery.of(context).padding.top + 100,
              child: Column(
                children: [
                  _buildMapAction(
                    Icons.my_location,
                    () => _goToCurrentLocation(provider),
                  ),
                ],
              ),
            ),

            // 3. Selected Venue Card (shows when a marker is tapped)
            if (_selectedVenue != null)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to venue details
                    context.pushNamed(
                      'venue-details',
                      pathParameters: {'id': _selectedVenue!.id},
                      extra: _selectedVenue,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: VenueCard(
                      venue: _selectedVenue!,
                      type: VenueCardType.horizontal,
                    ),
                  ),
                ),
              ),

            // 4. Debug Overlay - Moved to bottom left for better visibility
            if (kDebugMode)
              Positioned(
                bottom: _selectedVenue != null ? 220 : 110,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'V: ${provider.venues.length} | M: ${_markerIcons.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _initializeCamera(DiscoveryProvider provider) {
    if (_cameraInitialized || _mapController == null) return;

    LatLng? target;
    if (provider.currentPosition != null) {
      target = LatLng(
        provider.currentPosition!.latitude,
        provider.currentPosition!.longitude,
      );
    } else if (provider.venues.isNotEmpty) {
      target = LatLng(
        provider.venues.first.latitude,
        provider.venues.first.longitude,
      );
    }

    if (target != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(target, 14));
      _cameraInitialized = true;
    }
  }

  Widget _buildMapAction(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.gray700, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _goToCurrentLocation(DiscoveryProvider provider) async {
    if (provider.currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            provider.currentPosition!.latitude,
            provider.currentPosition!.longitude,
          ),
        ),
      );
    } else {
      await provider.updateLocation();
      if (provider.currentPosition != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              provider.currentPosition!.latitude,
              provider.currentPosition!.longitude,
            ),
          ),
        );
      }
    }
  }

  Set<Marker> _buildMarkers(DiscoveryProvider provider) {
    return provider.venues.map((venue) {
      final customIcon = _markerIcons[venue.id];
      final isSelected = _selectedVenue?.id == venue.id;

      return Marker(
        markerId: MarkerId(venue.id),
        position: LatLng(venue.latitude, venue.longitude),
        infoWindow: InfoWindow(title: venue.name),
        icon:
            customIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueRose : BitmapDescriptor.hueRed,
            ),
        anchor: const Offset(0.5, 1.0),
        onTap: () => _onMarkerTapped(venue),
      );
    }).toSet();
  }
}
