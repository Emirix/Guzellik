import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../venue/venue_card.dart';

class DiscoveryMapView extends StatefulWidget {
  const DiscoveryMapView({super.key});

  @override
  State<DiscoveryMapView> createState() => _DiscoveryMapViewState();
}

class _DiscoveryMapViewState extends State<DiscoveryMapView> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 15,
    tilt: 30.0, // Reduced tilt for better marker positioning
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // 1. Google Map
            GoogleMap(
              initialCameraPosition: provider.currentPosition != null
                  ? CameraPosition(
                      target: LatLng(
                        provider.currentPosition!.latitude,
                        provider.currentPosition!.longitude,
                      ),
                      zoom: 15,
                      tilt: 30.0, // Reduced tilt for better marker positioning
                    )
                  : _initialPosition,
              onMapCreated: (controller) async {
                _mapController = controller;
                final style = await DefaultAssetBundle.of(
                  context,
                ).loadString('assets/maps/silver_style.json');
                _mapController!.setMapStyle(style);
              },
              markers: _buildMarkers(provider),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
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
                  const SizedBox(height: 12),
                  _buildMapAction(Icons.layers, () {}),
                ],
              ),
            ),

            // 3. Bottom Carousel
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.venues.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 300,
                        child: VenueCard(
                          venue: provider.venues[index],
                          type: VenueCardType.vertical,
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  provider.venues[index].latitude,
                                  provider.venues[index].longitude,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
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
      return Marker(
        markerId: MarkerId(venue.id),
        position: LatLng(venue.latitude, venue.longitude),
        infoWindow: InfoWindow(title: venue.name, snippet: venue.description),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        anchor: const Offset(
          0.5,
          1.0,
        ), // Bottom center of marker at coordinates
        onTap: () {
          context.pushNamed(
            'venue-details',
            pathParameters: {'id': venue.id},
            extra: venue,
          );
        },
      );
    }).toSet();
  }
}
