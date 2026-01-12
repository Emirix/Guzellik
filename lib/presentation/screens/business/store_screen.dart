import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/business_provider.dart';
import '../../providers/credit_provider.dart';
import '../../widgets/common/business_bottom_nav.dart';
import '../../../data/models/credit_package.dart';

/// Store screen for business features marketplace
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final businessProvider = context.read<BusinessProvider>();
    final venue = businessProvider.businessVenue;
    if (venue != null) {
      await context.read<CreditProvider>().loadCreditData(venue.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mağaza',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : const Color(0xFF1B0E11),
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: isDark ? Colors.white : const Color(0xFF1B0E11),
            ),
            onPressed: () {
              // TODO: Navigate to transaction history
            },
          ),
        ],
      ),
      bottomNavigationBar: const BusinessBottomNav(),
      body: Consumer2<CreditProvider, BusinessProvider>(
        builder: (context, creditProvider, businessProvider, _) {
          if (creditProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final venueId = businessProvider.businessVenue?.id;
          if (venueId == null) {
            return const Center(child: Text('İşletme bilgisi bulunamadı'));
          }

          return RefreshIndicator(
            onRefresh: () => creditProvider.loadCreditData(venueId),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  _buildBalanceCard(creditProvider.balance),

                  // Showcase Section
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'Kredilerinizle işletmenizi büyütün',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B0E11),
                      ),
                    ),
                  ),
                  _buildShowcaseGrid(),

                  // Packages Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kredi Paketi Satın Al',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B0E11),
                          ),
                        ),
                        Text(
                          'TÜMÜNÜ GÖR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPackageList(
                    creditProvider.packages,
                    venueId,
                    creditProvider,
                  ),

                  // Info Footer
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                    child: Text(
                      'Krediler iade edilemez ve 12 ay süresince geçerlidir.\nSorularınız için destek ekibi ile iletişime geçin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A4C5F),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(int balance) {
    final formatter = NumberFormat('#,###', 'tr_TR');

    return Container(
      margin: const EdgeInsets.all(20),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA1axTMop_4pXYaOtob1VwhUwfXdcLBNjva00RNrZSgCfB-oS_fQJpOyAdLzXWfIRAY2hQLUaxYNuUkECCuyvHHZNeVe8i-m7lqZm5lMUYI6e9-xiSkoE0iHXEY9UzY_4HjbtirtJ0s7cxUnJhIgCzUAonamwRkVJ6lwVv_1VlY8ChFNJcO_0g_FsgeE7-lYKNbCOUN8jibmL9GED8GMaUz9lK2A-hyyfEywaYEVwSpEoO5c6qdr_vxPtZBLADJ7SmtH1yLNtwybA',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'GOLD İŞLETME',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${formatter.format(balance)} Kredi',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mevcut Kredi Bakiyesi',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Quick scroll to packages could be implemented here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    'Yükle',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcaseGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildShowcaseItem(
            icon: Icons.location_on,
            title: 'Öne Çık',
            desc: 'Haritada ve listelerde en üstte görünün',
          ),
          const SizedBox(height: 12),
          _buildShowcaseItem(
            icon: Icons.notifications_active,
            title: 'Bildirim Gönder',
            desc: 'Tüm takipçilerinize anlık mesaj gönderin',
          ),
          const SizedBox(height: 12),
          _buildShowcaseItem(
            icon: Icons.campaign,
            title: 'Kampanya Tanıtımı',
            desc: 'Özel tekliflerinizi binlerce yeni müşteriye ulaştırın',
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF66BB6A),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageList(
    List<CreditPackage> packages,
    String venueId,
    CreditProvider provider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final package = packages[index];
        return _buildPackageCard(package, venueId, provider);
      },
    );
  }

  Widget _buildPackageCard(
    CreditPackage package,
    String venueId,
    CreditProvider provider,
  ) {
    bool isPopular = package.isPopular;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.primary : const Color(0xFFE7CFD5),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'EN POPÜLER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B0E11),
                        ),
                      ),
                      Text(
                        package.description ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A4C5F),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${package.price.toInt()} TL',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: provider.isPurchasing
                      ? null
                      : () => _handlePurchase(
                          context,
                          venueId,
                          package,
                          provider,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Satın Al',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    String venueId,
    CreditPackage package,
    CreditProvider provider,
  ) async {
    final success = await provider.purchasePackage(venueId, package);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${package.name} başarıyla satın alındı!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
