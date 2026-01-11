import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/business_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AdminWorkingHoursScreen extends StatefulWidget {
  const AdminWorkingHoursScreen({super.key});

  @override
  State<AdminWorkingHoursScreen> createState() =>
      _AdminWorkingHoursScreenState();
}

class _AdminWorkingHoursScreenState extends State<AdminWorkingHoursScreen> {
  final Map<String, String> _days = {
    'monday': 'Pazartesi',
    'tuesday': 'Salı',
    'wednesday': 'Çarşamba',
    'thursday': 'Perşembe',
    'friday': 'Cuma',
    'saturday': 'Cumartesi',
    'sunday': 'Pazar',
  };

  late Map<String, dynamic> _workingHours;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final venue = context.read<BusinessProvider>().currentVenue;
    _workingHours = Map<String, dynamic>.from(venue?.workingHours ?? {});
    _fillMissingDays();
  }

  void _fillMissingDays() {
    for (var key in _days.keys) {
      if (!_workingHours.containsKey(key) || _workingHours[key] == null) {
        _workingHours[key] = '09:00 - 19:00'; // Default
      }
    }
  }

  Future<void> _selectTimeRange(String dayKey) async {
    final currentVal = _workingHours[dayKey] as String;
    if (currentVal == 'Kapalı') {
      _toggleClosed(dayKey);
      return;
    }

    final parts = currentVal.split(' - ');
    final startTimeStr = parts[0];
    final endTimeStr = parts[1];

    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: _parseTime(startTimeStr),
      helpText: '${_days[dayKey]} Açılış Saati',
    );

    if (start == null) return;

    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: _parseTime(endTimeStr),
      helpText: '${_days[dayKey]} Kapanış Saati',
    );

    if (end == null) return;

    setState(() {
      _workingHours[dayKey] = '${_formatTime(start)} - ${_formatTime(end)}';
    });
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _toggleClosed(String dayKey) {
    setState(() {
      if (_workingHours[dayKey] == 'Kapalı') {
        _workingHours[dayKey] = '09:00 - 19:00';
      } else {
        _workingHours[dayKey] = 'Kapalı';
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final success = await context.read<BusinessProvider>().updateWorkingHours(
      _workingHours,
    );
    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çalışma saatleri güncellendi')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hata oluştu, lütfen tekrar deneyin')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Çalışma Saatleri',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/business/admin');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Haftalık Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İşletmenizin açık olduğu saatleri güncelleyerek müşterilerinizin doğru bilgiye ulaşmasını sağlayın.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ..._days.keys.map((key) => _buildDayTile(key)),
            const SizedBox(height: 40),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(String dayKey) {
    final value = _workingHours[dayKey] as String;
    final isClosed = value == 'Kapalı';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _days[dayKey]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _selectTimeRange(dayKey),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: isClosed ? Colors.redAccent : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text(
                'Kapalı',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Switch.adaptive(
                value: isClosed,
                onChanged: (_) => _toggleClosed(dayKey),
                activeColor: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'AYARLARI KAYDET',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
