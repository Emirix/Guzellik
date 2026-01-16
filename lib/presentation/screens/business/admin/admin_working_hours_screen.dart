import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/admin_working_hours_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/venue_details_provider.dart';

class AdminWorkingHoursScreen extends StatefulWidget {
  const AdminWorkingHoursScreen({super.key});

  @override
  State<AdminWorkingHoursScreen> createState() =>
      _AdminWorkingHoursScreenState();
}

class _AdminWorkingHoursScreenState extends State<AdminWorkingHoursScreen> {
  bool _isInitialized = false;

  final List<String> _days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final Map<String, String> _dayLabels = {
    'monday': 'Pazartesi',
    'tuesday': 'Salı',
    'wednesday': 'Çarşamba',
    'thursday': 'Perşembe',
    'friday': 'Cuma',
    'saturday': 'Cumartesi',
    'sunday': 'Pazar',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.businessVenue?.id;

    if (venueId != null) {
      await context.read<AdminWorkingHoursProvider>().loadWorkingHours(venueId);
    }
  }

  Future<void> _saveChanges() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.businessVenue?.id;

    if (venueId == null) return;

    final provider = context.read<AdminWorkingHoursProvider>();
    try {
      await provider.saveWorkingHours(venueId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çalışma saatleri kaydedildi')),
        );
        // Refresh business venue data
        await businessProvider.refreshVenue(venueId);

        // Also refresh venue details provider if it exists
        try {
          final venueDetailsProvider = context.read<VenueDetailsProvider>();
          await venueDetailsProvider.loadVenueDetails(venueId);
        } catch (e) {
          // VenueDetailsProvider might not be available in this context
          debugPrint('VenueDetailsProvider not available: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectTime(String day, bool isStart) async {
    final provider = context.read<AdminWorkingHoursProvider>();
    final currentHours = provider.workingHours[day] ?? {};
    final currentTimeStr = isStart
        ? currentHours['start']
        : currentHours['end'];

    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    if (currentTimeStr != null) {
      final parts = (currentTimeStr as String).split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B0E11),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final newDayHours = Map<String, dynamic>.from(currentHours);
      if (isStart) {
        newDayHours['start'] = timeStr;
      } else {
        newDayHours['end'] = timeStr;
      }
      provider.updateDayHours(day, newDayHours);
    }
  }

  void _applyToAll(String sourceDay) {
    final provider = context.read<AdminWorkingHoursProvider>();
    final sourceHours = provider.workingHours[sourceDay];
    if (sourceHours != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tüm Günlere Uygula'),
          content: Text(
            '${_dayLabels[sourceDay]} gününün saatlerini tüm haftaya kopyalamak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                provider.applyToAllDays(sourceHours);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saatler tüm günlere uygulandı'),
                  ),
                );
              },
              child: const Text('Uygula'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Çalışma Saatleri',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1B0E11),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AdminWorkingHoursProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.workingHours.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _days.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final day = _days[index];
              final label = _dayLabels[day]!;
              final hours =
                  provider.workingHours[day] ??
                  {'open': true, 'start': '09:00', 'end': '20:00'};
              final isOpen = hours['open'] ?? false;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // Day Name
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B0E11),
                            ),
                          ),
                        ),

                        // Switch
                        Switch.adaptive(
                          value: isOpen,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            final newHours = Map<String, dynamic>.from(hours);
                            newHours['open'] = value;
                            provider.updateDayHours(day, newHours);
                          },
                        ),

                        // Menu Button
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppColors.gray600,
                            size: 20,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder: (context) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.content_copy,
                                        color: AppColors.primary,
                                      ),
                                      title: const Text('Tüm günlere uygula'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _applyToAll(day);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Time Selection (only if open)
                    if (isOpen) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeButton(
                              context,
                              label: 'Açılış',
                              time: (hours['start'] ?? '09:00').toString(),
                              onTap: () => _selectTime(day, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeButton(
                              context,
                              label: 'Kapanış',
                              time: (hours['end'] ?? '20:00').toString(),
                              onTap: () => _selectTime(day, false),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        'Kapalı',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<AdminWorkingHoursProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Kaydet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(
    BuildContext context, {
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B0E11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
