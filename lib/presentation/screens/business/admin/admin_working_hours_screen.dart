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
        actions: [
          Consumer<AdminWorkingHoursProvider>(
            builder: (context, provider, _) => IconButton(
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle, color: AppColors.primary),
              onPressed: provider.isLoading ? null : _saveChanges,
            ),
          ),
        ],
      ),
      body: Consumer<AdminWorkingHoursProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.workingHours.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _days.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final day = _days[index];
              final label = _dayLabels[day]!;
              final hours =
                  provider.workingHours[day] ??
                  {'open': true, 'start': '09:00', 'end': '20:00'};
              final isOpen = hours['open'] ?? false;

              return Container(
                decoration: BoxDecoration(
                  color: isOpen ? Colors.white : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOpen
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isOpen
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Day Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: isOpen
                                      ? AppColors.primary.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isOpen
                                  ? Icons.schedule_rounded
                                  : Icons.block_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Day Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B0E11),
                                  ),
                                ),
                                if (!isOpen)
                                  Text(
                                    'Kapalı',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Switch
                          Transform.scale(
                            scale: 0.9,
                            child: Switch.adaptive(
                              value: isOpen,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                final newHours = Map<String, dynamic>.from(
                                  hours,
                                );
                                newHours['open'] = value;
                                provider.updateDayHours(day, newHours);
                              },
                            ),
                          ),

                          // Menu Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) {
                                if (value == 'apply_all') _applyToAll(day);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'apply_all',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.content_copy_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Tüm günlere uygula'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time Selection (only if open)
                    if (isOpen) ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTimeButton(
                                context,
                                label: 'Açılış',
                                time: (hours['start'] ?? '09:00').toString(),
                                icon: Icons.wb_sunny_rounded,
                                onTap: () => _selectTime(day, true),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildTimeButton(
                                context,
                                label: 'Kapanış',
                                time: (hours['end'] ?? '20:00').toString(),
                                icon: Icons.nightlight_round,
                                onTap: () => _selectTime(day, false),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildTimeButton(
    BuildContext context, {
    required String label,
    required String time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B0E11),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
