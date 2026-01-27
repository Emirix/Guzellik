import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/app_state_provider.dart';
import '../../../../data/models/appointment.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../widgets/common/business_bottom_nav.dart';
import '../../../widgets/business/appointment_create_bottom_sheet.dart';
import '../../../widgets/business/appointment_shimmer_loading.dart';
import '../../../widgets/common/guzellik_haritam_header.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
      context.read<AppStateProvider>().setBottomNavIndex(0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.currentVenue?.id;

    if (venueId != null) {
      await context.read<AppointmentProvider>().fetchDailyAppointments(
        venueId,
        _selectedDate,
      );
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAppointments();
  }

  void _showCreateAppointmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppointmentCreateBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const GuzellikHaritamHeader(
            backgroundColor: AppColors.backgroundLight,
          ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildHorizontalDatePicker(),
                Expanded(child: _buildTimelineView()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAppointmentBottomSheet,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      bottomNavigationBar: const BusinessBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Randevular',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Consumer<AppointmentProvider>(
                builder: (context, provider, _) {
                  return Text(
                    'Bugün için ${provider.appointments.length} randevu',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalDatePicker() {
    final today = DateTime.now();
    final dates = List.generate(
      14,
      (index) => today.add(Duration(days: index - 7)),
    );

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E', 'tr_TR').format(date).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.secondary.withOpacity(0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('d').format(date),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineView() {
    return Consumer2<AppointmentProvider, BusinessProvider>(
      builder: (context, appointmentProvider, businessProvider, _) {
        if (appointmentProvider.isLoading) {
          return const AppointmentShimmerLoading();
        }

        if (appointmentProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.secondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  appointmentProvider.errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          );
        }

        final venue = businessProvider.currentVenue;
        final dayNames = [
          'sunday',
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
        ];
        final selectedDayName = dayNames[_selectedDate.weekday % 7];
        final dayHours = venue?.workingHours[selectedDayName];

        bool isClosed = true;
        String startTimeStr = '09:00';
        String endTimeStr = '20:00';

        if (dayHours is Map<String, dynamic>) {
          isClosed = dayHours['open'] == false;
          startTimeStr = dayHours['start']?.toString() ?? '09:00';
          endTimeStr = dayHours['end']?.toString() ?? '20:00';
        }

        if (isClosed) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_busy_rounded,
                    size: 48,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'İzin Günü',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İşletme bugün kapalıdır.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.secondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        final appointments = appointmentProvider.appointments;
        return _buildTimelineList(appointments, startTimeStr, endTimeStr);
      },
    );
  }

  Widget _buildTimelineList(
    List<Appointment> appointments,
    String startHourStr,
    String endHourStr,
  ) {
    final startParts = startHourStr.split(':');
    final endParts = endHourStr.split(':');

    int startH = 9, startM = 0, endH = 20, endM = 0;
    if (startParts.length == 2) {
      startH = int.tryParse(startParts[0]) ?? 9;
      startM = int.tryParse(startParts[1]) ?? 0;
    }
    if (endParts.length == 2) {
      endH = int.tryParse(endParts[0]) ?? 20;
      endM = int.tryParse(endParts[1]) ?? 0;
    }

    final totalMin = (endH * 60 + endM) - (startH * 60 + startM);
    final slotCount = (totalMin / 15).ceil() + 1;

    final timeSlots = List.generate(slotCount, (index) {
      final totalSlotMin = (startH * 60 + startM) + (index * 15);
      return TimeOfDay(hour: totalSlotMin ~/ 60, minute: totalSlotMin % 60);
    });

    final now = DateTime.now();
    final isToday =
        DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(now);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final slotStartTime =
            '${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}';
        final nextSlotTime = index < timeSlots.length - 1
            ? '${timeSlots[index + 1].hour.toString().padLeft(2, '0')}:${timeSlots[index + 1].minute.toString().padLeft(2, '0')}'
            : '23:59';

        final bool isCurrentSlot =
            isToday &&
            timeSlot.hour == now.hour &&
            now.minute >= timeSlot.minute &&
            now.minute < (timeSlot.minute + 15);

        final startingApts = appointments
            .where(
              (apt) =>
                  apt.startTime.compareTo(slotStartTime) >= 0 &&
                  apt.startTime.compareTo(nextSlotTime) < 0,
            )
            .toList();

        final ongoingApts = appointments
            .where(
              (apt) =>
                  apt.startTime.compareTo(slotStartTime) < 0 &&
                  apt.endTime.compareTo(slotStartTime) > 0,
            )
            .toList();

        Widget slotWidget;
        if (startingApts.isNotEmpty) {
          slotWidget = Column(
            children: startingApts
                .map((apt) => _buildTimeSlot(apt.startTime, apt))
                .toList(),
          );
        } else if (ongoingApts.isNotEmpty) {
          slotWidget = _buildOccupiedSlot(slotStartTime);
        } else {
          slotWidget = _buildTimeSlot(
            slotStartTime,
            null,
            isLunchBreak: timeSlot.hour == 12 && timeSlot.minute == 0,
          );
        }

        if (isCurrentSlot) {
          return Column(children: [_buildCurrentTimeLine(), slotWidget]);
        }
        return slotWidget;
      },
    );
  }

  Widget _buildCurrentTimeLine() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupiedSlot(String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 1,
                height: 20,
                color: AppColors.primary.withOpacity(0.4),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 40,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
    String time,
    Appointment? appointment, {
    bool isLunchBreak = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: appointment != null
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: appointment != null
                      ? AppColors.black
                      : AppColors.gray500,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 1,
                height: 20,
                color: AppColors.primary.withOpacity(0.1),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: appointment != null
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appointment != null
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: appointment != null
                ? _buildAppointmentCard(appointment)
                : _buildEmptySlot(isLunchBreak: isLunchBreak),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot({bool isLunchBreak = false}) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.05)),
        ),
      ),
      child: Text(
        isLunchBreak ? 'Öğle Arası' : 'Boş Slot',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: isLunchBreak
              ? AppColors.gold.withOpacity(0.6)
              : AppColors.secondary.withOpacity(0.3),
          fontWeight: isLunchBreak ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'admin-appointment-detail',
        pathParameters: {'id': appointment.id},
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName ?? 'Müşteri',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.servicesDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(appointment.status, appointment.statusText),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${appointment.startTime} - ${appointment.endTime}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.specialistName != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: AppColors.secondary.withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            appointment.specialistName!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String statusText) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'confirmed':
        bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
        textColor = const Color(0xFF4CAF50);
        break;
      case 'completed':
        bgColor = const Color(0xFF2196F3).withOpacity(0.1);
        textColor = const Color(0xFF2196F3);
        break;
      case 'cancelled':
        bgColor = const Color(0xFFF44336).withOpacity(0.1);
        textColor = const Color(0xFFF44336);
        break;
      case 'no_show':
        bgColor = const Color(0xFF9E9E9E).withOpacity(0.1);
        textColor = const Color(0xFF9E9E9E);
        break;
      default:
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
