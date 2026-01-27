import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/services/appointment_data_service.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/business_provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Future<Appointment> _appointmentFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  void _loadAppointment() {
    setState(() {
      _appointmentFuture = AppointmentDataService().getAppointmentById(
        widget.appointmentId,
      );
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await context.read<AppointmentProvider>().updateStatus(
        appointmentId: widget.appointmentId,
        status: newStatus,
      );
      _loadAppointment();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Durum güncellendi: ${newStatus == 'confirmed' ? 'Onaylandı' : 'Tamamlandı'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Randevuyu Sil',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu randevuyu kalıcı olarak silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AppointmentProvider>().deleteAppointment(
          widget.appointmentId,
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _openWhatsApp(String phone, String name, String time) async {
    final message =
        "Merhaba $name, bugün saat $time'daki randevunuzu hatırlatmak istedik. Görüşmek üzere!";
    final url =
        "https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _makeCall(String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Randevu Detayı',
          style: GoogleFonts.outfit(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteAppointment,
          ),
        ],
      ),
      body: FutureBuilder<Appointment>(
        future: _appointmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final appointment = snapshot.data!;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(appointment),
                    const SizedBox(height: 24),
                    _buildSectionLabel('MÜŞTERİ BİLGİLERİ'),
                    const SizedBox(height: 12),
                    _buildCustomerCard(appointment),
                    const SizedBox(height: 24),
                    _buildSectionLabel('HİZMET DETAYLARI'),
                    const SizedBox(height: 12),
                    _buildServicesCard(appointment),
                    const SizedBox(height: 24),
                    if (appointment.notes != null) ...[
                      _buildSectionLabel('NOTLAR'),
                      const SizedBox(height: 12),
                      _buildNotesCard(appointment.notes!),
                    ],
                  ],
                ),
              ),
              _buildBottomActions(appointment),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'dd MMMM yyyy, EEEE',
                    'tr_TR',
                  ).format(appointment.appointmentDate),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.startTime} - ${appointment.endTime} (${appointment.totalDurationMinutes} dk)',
                  style: GoogleFonts.inter(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(appointment.status),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  appointment.customerName?[0] ?? '?',
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.customerName ?? 'Bilinmeyen Müşteri',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      appointment.customerPhone ?? '-',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.phone_outlined,
                  label: 'Müşteriyi Ara',
                  color: AppColors.black,
                  onTap: () => _makeCall(appointment.customerPhone ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  color: AppColors.black,
                  onTap: () => _openWhatsApp(
                    appointment.customerPhone ?? '',
                    appointment.customerName ?? '',
                    appointment.startTime,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(Appointment appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          ...appointment.services.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.serviceName,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${s.serviceDurationMinutes} dk',
                          style: GoogleFonts.inter(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₺${s.servicePrice?.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '₺${appointment.totalPrice?.toStringAsFixed(0)}',
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

  Widget _buildNotesCard(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Text(
        notes,
        style: GoogleFonts.inter(
          color: AppColors.black,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomActions(Appointment appointment) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: _buildActionButtonsByStatus(appointment),
      ),
    );
  }

  Widget _buildActionButtonsByStatus(Appointment appointment) {
    if (appointment.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('cancelled'),
              style: _outlinedButtonStyle(AppColors.error),
              child: const Text('Reddet'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus('confirmed'),
              style: _elevatedButtonStyle(Colors.green),
              child: const Text('Onayla'),
            ),
          ),
        ],
      );
    }
    if (appointment.status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus('completed'),
          style: _elevatedButtonStyle(AppColors.primary),
          child: const Text('Tamamlandı Olarak İşaretle'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: Text(
        'Bu randevu ${appointment.statusText.toLowerCase()}.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status).toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Onaylı';
      case 'completed':
        return 'Bitti';
      case 'cancelled':
        return 'İptal';
      default:
        return 'Bekliyor';
    }
  }

  ButtonStyle _elevatedButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w800),
    );
  }

  ButtonStyle _outlinedButtonStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w800),
    );
  }
}
