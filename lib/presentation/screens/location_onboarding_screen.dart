import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/location_onboarding_provider.dart';
import '../providers/discovery_provider.dart';
import '../widgets/discovery/location_selection_bottom_sheet.dart';
import '../widgets/discovery/location_service_request_bottom_sheet.dart';

/// Screen that handles location onboarding flow
/// Shows loading, GPS request, and triggers manual selection when needed
class LocationOnboardingScreen extends StatefulWidget {
  final Widget child;

  const LocationOnboardingScreen({super.key, required this.child});

  @override
  State<LocationOnboardingScreen> createState() =>
      _LocationOnboardingScreenState();
}

class _LocationOnboardingScreenState extends State<LocationOnboardingScreen>
    with WidgetsBindingObserver {
  bool _hasShownManualSelection = false;
  bool _hasShownServiceRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start location check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check location status when back from settings
      final provider = context.read<LocationOnboardingProvider>();
      if (provider.state == OnboardingState.showingServiceRequest) {
        provider.checkLocationStatus();
      }
    }
  }

  Future<void> _checkLocation() async {
    final provider = context.read<LocationOnboardingProvider>();
    await provider.checkLocationStatus();
  }

  void _showManualSelectionSheet() {
    if (_hasShownManualSelection) return;
    _hasShownManualSelection = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PopScope(
        canPop: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) =>
              const LocationSelectionBottomSheet(isOnboarding: true),
        ),
      ),
    ).then((_) {
      _hasShownManualSelection = false;
    });
  }

  void _showServiceRequestSheet() {
    if (_hasShownServiceRequest) return;
    _hasShownServiceRequest = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const LocationServiceRequestBottomSheet(),
    ).then((_) {
      _hasShownServiceRequest = false;

      // If the sheet was closed and state is still showingServiceRequest,
      // it means the user explicitly closed it or navigated back without enabling.
      // We handle fallback logic in the sheet buttons, but this is a safety.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationOnboardingProvider>(
      builder: (context, provider, _) {
        // Always show the child (main app)
        // The onboarding logic will trigger overlays if needed
        return Stack(
          children: [
            widget.child,

            // Show a non-blocking or slightly dimmed overlay if location is being fetched automatically
            if (provider.state == OnboardingState.fetchingGPS ||
                provider.state == OnboardingState.checkingLocation)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),

            // Handle state changes in build but trigger sheets in post-frame
            _handleState(provider),
          ],
        );
      },
    );
  }

  Widget _handleState(LocationOnboardingProvider provider) {
    if (provider.state == OnboardingState.showingManual) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showManualSelectionSheet();
      });
    }

    if (provider.state == OnboardingState.showingServiceRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showServiceRequestSheet();
      });
    }

    // If onboarding just finished, and we haven't synced with DiscoveryProvider yet
    if (provider.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final discoveryProvider = context.read<DiscoveryProvider>();
        // Only update if location actually changed or isn't set yet in discovery
        if (provider.selectedLocation != null) {
          final loc = provider.selectedLocation!;
          if (discoveryProvider.manualCity != loc.provinceName ||
              discoveryProvider.manualDistrict != loc.districtName) {
            discoveryProvider.updateManualLocation(
              city: loc.provinceName,
              district: loc.districtName,
              provinceId: loc.provinceId,
              latitude: loc.latitude,
              longitude: loc.longitude,
            );
          }
        }
      });
    }
    return const SizedBox.shrink();
  }
}
