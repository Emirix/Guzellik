import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/customer.dart';
import '../../providers/customer_provider.dart';
import 'customer_form_sheet.dart';

class CustomerDetailSheet extends StatefulWidget {
  final Customer customer;

  const CustomerDetailSheet({super.key, required this.customer});

  @override
  State<CustomerDetailSheet> createState() => _CustomerDetailSheetState();
}

class _CustomerDetailSheetState extends State<CustomerDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editCustomer(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerFormSheet(customer: widget.customer),
    );
  }

  void _deleteCustomer(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
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

    if (confirmed == true && context.mounted) {
      final provider = context.read<CustomerProvider>();
      final success = await provider.deleteCustomer(widget.customer.id);
      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Müşteri silindi')));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Silme işlemi başarısız oldu',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildProfileHeader(context),
          const SizedBox(height: 16),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildInfoTab(), _buildAppointmentsTab()],
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

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildIconButton(
                Icons.edit,
                AppColors.primary,
                () => _editCustomer(context),
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                Icons.delete,
                AppColors.error,
                () => _deleteCustomer(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.customer.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFamily: 'Outfit',
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _makePhoneCall(widget.customer.phone),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    widget.customer.phone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.secondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Müşteri Bilgileri'),
          Tab(text: 'Randevular'),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          _buildInfoCard(
            icon: Icons.cake,
            label: 'DOĞUM TARİHİ',
            value: widget.customer.birthDate != null
                ? DateFormat(
                    'dd MMMM yyyy',
                    'tr_TR',
                  ).format(widget.customer.birthDate!)
                : 'Belirtilmedi',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.person_outline,
            label: 'CİNSİYET',
            value: widget.customer.gender == 0
                ? 'Kadın'
                : widget.customer.gender == 1
                ? 'Erkek'
                : 'Belirtilmedi',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.sticky_note_2,
            label: 'ÖZEL NOTLAR',
            value: widget.customer.notes ?? 'Not bulunmuyor',
            isLongText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Geçmiş Randevular',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tümü',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAppointmentItem(
            title: 'Cilt Bakımı',
            date: '12 Ekim 2023',
            price: '₺1.250',
            icon: Icons.spa,
          ),
          _buildAppointmentItem(
            title: 'Manikür',
            date: '28 Eylül 2023',
            price: '₺450',
            icon: Icons.brush,
            iconColor: Colors.orange,
          ),
          _buildAppointmentItem(
            title: 'Lazer Epilasyon',
            date: '15 Eylül 2023',
            price: '₺2.500',
            icon: Icons.content_cut,
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isLongText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: isLongText
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLongText ? 14 : 15,
                    fontWeight: isLongText ? FontWeight.w500 : FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem({
    required String title,
    required String date,
    required String price,
    required IconData icon,
    Color iconColor = AppColors.primary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
