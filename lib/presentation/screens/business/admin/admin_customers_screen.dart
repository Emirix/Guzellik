import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../presentation/providers/customer_provider.dart';
import '../../../../data/models/customer.dart';
import '../../../widgets/common/business_bottom_nav.dart';
import '../../../../presentation/providers/app_state_provider.dart';
import '../../../widgets/business/customer_form_sheet.dart';
import '../../../widgets/business/customer_detail_sheet.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().fetchCustomers();
      context.read<AppStateProvider>().setBottomNavIndex(1);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CustomerFormSheet(),
    );
  }

  void _showCustomerDetailSheet(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerDetailSheet(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildCustomerList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerSheet,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      bottomNavigationBar: const BusinessBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Müşterilerim',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  return Text(
                    'Toplam ${provider.customers.length} müşteri',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'İsim veya numara ile ara...',
            hintStyle: TextStyle(
              color: AppColors.secondary.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredCustomers = provider.searchCustomers(_searchQuery);

        if (filteredCustomers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: AppColors.secondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'Henüz müşteri bulunmuyor'
                      : 'Arama sonucu bulunamadı',
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Split into "Today" and "All" if needed, but for simplicity we list all.
        // The design has "Bugün Eklenenler" and "Tüm Müşteriler".
        // Let's implement that logic.
        final today = DateTime.now();
        final todayCustomers = filteredCustomers.where((c) {
          return c.createdAt.year == today.year &&
              c.createdAt.month == today.month &&
              c.createdAt.day == today.day;
        }).toList();

        final otherCustomers = filteredCustomers.where((c) {
          return !(c.createdAt.year == today.year &&
              c.createdAt.month == today.month &&
              c.createdAt.day == today.day);
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          children: [
            if (todayCustomers.isNotEmpty) ...[
              _buildSectionHeader('Bugün Eklenenler'),
              ...todayCustomers.map((c) => _buildCustomerCard(c)),
              const SizedBox(height: 16),
            ],
            if (otherCustomers.isNotEmpty) ...[
              _buildSectionHeader('Tüm Müşteriler'),
              ...otherCustomers.map((c) => _buildCustomerCard(c)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final initials = AvatarUtils.getInitials(customer.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCustomerDetailSheet(customer),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
