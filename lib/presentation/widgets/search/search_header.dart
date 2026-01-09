import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/search_provider.dart';

/// Arama başlığı widget'ı
/// Geri butonu, arama input'u ve harita toggle'ı içerir
class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        // Build location text
        String? locationText;
        if (searchProvider.selectedProvince != null) {
          locationText = searchProvider.selectedProvince!;
          if (searchProvider.selectedDistrict != null) {
            locationText = '${searchProvider.selectedDistrict}, $locationText';
          }
        }

        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 12,
            16,
            12,
          ),
          decoration: const BoxDecoration(color: AppColors.background),
          child: Row(
            children: [
              // Back button (Rounded full from design)
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  context.read<AppStateProvider>().setBottomNavIndex(0);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gray100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.gray900,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Search input with location subtext (Rounded 2xl from design)
              Expanded(
                child: Container(
                  height: locationText != null ? 52 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onChanged: onChanged,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Hizmet veya mekan ara...',
                                hintStyle: TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                            if (locationText != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                locationText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: onClear,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.close,
                              color: AppColors.gray400,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Map toggle button (Rounded 2xl from design)
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  context.read<DiscoveryProvider>().setViewMode(
                    DiscoveryViewMode.map,
                  );
                  context.read<AppStateProvider>().setBottomNavIndex(0);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.map,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
