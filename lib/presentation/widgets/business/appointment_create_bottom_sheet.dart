import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/venue_service.dart';
import '../../../data/models/specialist.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/appointment_service.dart';
import '../../providers/customer_provider.dart';
import '../../providers/admin_services_provider.dart';
import '../../providers/admin_specialists_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/business_provider.dart';
import '../../../data/services/appointment_data_service.dart';

class AppointmentCreateBottomSheet extends StatefulWidget {
  final Customer? initialCustomer;

  const AppointmentCreateBottomSheet({super.key, this.initialCustomer});

  @override
  State<AppointmentCreateBottomSheet> createState() =>
      _AppointmentCreateBottomSheetState();
}

class _AppointmentCreateBottomSheetState
    extends State<AppointmentCreateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Customer? _selectedCustomer;
  final List<VenueService> _selectedServices = [];
  Specialist? _selectedSpecialist;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.initialCustomer;

    // Set start time to next 30 min interval for better UX
    final now = DateTime.now();
    if (now.minute < 30) {
      _startTime = TimeOfDay(hour: now.hour, minute: 30);
    } else {
      _startTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.currentVenue?.id;

    if (venueId == null) return;

    await Future.wait([
      if (widget.initialCustomer == null)
        context.read<CustomerProvider>().fetchCustomers(),
      context.read<AdminServicesProvider>().fetchVenueServices(venueId),
      context.read<AdminSpecialistsProvider>().fetchSpecialists(venueId),
    ]);
  }

  // Computed values
  int get _totalDuration {
    return _selectedServices.fold(
      0,
      (sum, service) => sum + service.effectiveDuration,
    );
  }

  double get _totalPrice {
    return _selectedServices.fold(
      0.0,
      (sum, service) => sum + service.effectivePrice,
    );
  }

  TimeOfDay _calculateEndTime(TimeOfDay start, int durationMinutes) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = startMinutes + durationMinutes;
    return TimeOfDay(hour: (endMinutes ~/ 60) % 24, minute: endMinutes % 60);
  }

  TimeOfDay get _endTime => _calculateEndTime(_startTime, _totalDuration);

  String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomer == null) {
      setState(() => _errorMessage = 'Lütfen bir müşteri seçin');
      return;
    }

    if (_selectedServices.isEmpty) {
      setState(() => _errorMessage = 'Lütfen en az bir hizmet seçin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final businessProvider = context.read<BusinessProvider>();
      final venueId = businessProvider.currentVenue?.id;

      if (venueId == null) throw Exception('Venue ID bulunamadı');

      // Check for conflicts
      final hasConflict = await AppointmentDataService().checkConflict(
        venueId: venueId,
        specialistId: _selectedSpecialist?.id,
        date: _selectedDate,
        startTime: _timeOfDayToString(_startTime),
        endTime: _timeOfDayToString(_endTime),
      );

      if (hasConflict) {
        setState(() {
          _errorMessage = _selectedSpecialist != null
              ? 'Bu uzmanın bu saatinde zaten randevu var!'
              : 'Bu saatte zaten bir randevu var!';
          _isLoading = false;
        });
        return;
      }

      // Create appointment
      final appointment = Appointment(
        id: '',
        venueId: venueId,
        customerId: _selectedCustomer!.id,
        specialistId: _selectedSpecialist?.id,
        appointmentDate: _selectedDate,
        startTime: _timeOfDayToString(_startTime),
        endTime: _timeOfDayToString(_endTime),
        totalDurationMinutes: _totalDuration,
        status: 'pending',
        totalPrice: _totalPrice,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        services: _selectedServices
            .asMap()
            .entries
            .map(
              (entry) => AppointmentService(
                id: '',
                appointmentId: '',
                serviceId: entry.value.id,
                sortOrder: entry.key,
                serviceName: entry.value.displayName,
                servicePrice: entry.value.effectivePrice,
                serviceDurationMinutes: entry.value.effectiveDuration,
              ),
            )
            .toList(),
      );

      final success = await context
          .read<AppointmentProvider>()
          .createAppointment(appointment);

      if (success && mounted) {
        // Refresh the list for the current selected date in provider
        final provider = context.read<AppointmentProvider>();
        await provider.fetchDailyAppointments(venueId, provider.selectedDate);

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Randevu başarıyla oluşturuldu',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hata: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: 20),
                    ],
                    _buildCustomerSection(),
                    const SizedBox(height: 24),
                    _buildServiceSection(),
                    const SizedBox(height: 24),
                    _buildSpecialistSection(),
                    const SizedBox(height: 24),
                    _buildDateTimeSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 32),
                    _buildPriceSummary(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 56,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Randevu Oluştur',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              Text(
                'Randevu bilgilerini giriniz',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD6D6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB71C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    if (widget.initialCustomer != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('MÜŞTERİ'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCustomer!.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        _selectedCustomer!.phone,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<Customer>(
          value: _selectedCustomer,
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: _inputDecoration('Müşteri Seçimi'),
          items: provider.customers.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text('${c.name} (${c.phone})'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCustomer = val),
        );
      },
    );
  }

  Widget _buildServiceSection() {
    return Consumer<AdminServicesProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildLabel('HİZMETLER'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showServicePicker(provider.venueServices),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(
                    'Ekle',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedServices.isEmpty)
              _buildEmptyPlaceholder('Henüz hizmet seçilmedi')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedServices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final service = _selectedServices[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.displayName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${service.effectiveDuration} dk • ₺${service.effectivePrice.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _selectedServices.removeAt(index);
                          }),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showServicePicker(List<VenueService> services) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hizmet Seçin',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = services[index];
                        final isSelected = _selectedServices.any(
                          (item) => item.id == s.id,
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            s.displayName,
                            style: GoogleFonts.inter(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.black,
                            ),
                          ),
                          subtitle: Text('${s.effectiveDuration} dakika'),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.gray300,
                                ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedServices.removeWhere(
                                  (item) => item.id == s.id,
                                );
                              } else {
                                _selectedServices.add(s);
                              }
                            });
                            setModalState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: _primaryButtonStyle(),
                      child: const Text('Tamam'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpecialistSection() {
    return Consumer<AdminSpecialistsProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<Specialist>(
          value: _selectedSpecialist,
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: _inputDecoration('Uzman Seçimi'),
          items: [
            const DropdownMenuItem<Specialist>(
              value: null,
              child: Text('Herhangi bir uzman'),
            ),
            ...provider.specialists.map((s) {
              return DropdownMenuItem(value: s, child: Text(s.name));
            }),
          ],
          onChanged: (val) => setState(() => _selectedSpecialist = val),
        );
      },
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('TARİH VE SAAT'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildSelectorTile(
                icon: Icons.calendar_today_outlined,
                value: DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('tr', 'TR'),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildSelectorTile(
                icon: Icons.access_time_outlined,
                value: _startTime.format(context),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) setState(() => _startTime = time);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return TextField(
      controller: _notesController,
      maxLines: 2,
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: _inputDecoration('Randevu Notları'),
    );
  }

  Widget _buildPriceSummary() {
    if (_selectedServices.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _summaryRow('Hizmet Sayısı', '${_selectedServices.length}'),
          const SizedBox(height: 8),
          _summaryRow('Toplam Süre', '$_totalDuration dk'),
          const SizedBox(height: 8),
          _summaryRow('Bitiş Saati', _timeOfDayToString(_endTime)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.gray200),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM TUTAR',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '₺${_totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveAppointment,
        style: _primaryButtonStyle(),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Randevuyu Kaydet',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check, color: Colors.white),
                ],
              ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.secondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200, width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: AppColors.secondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.secondary, fontSize: 14),
      floatingLabelStyle: GoogleFonts.inter(color: AppColors.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gray200, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.3),
    );
  }
}
