import 'package:flutter/material.dart';
import '../../widgets/common/business_bottom_nav.dart';

/// Store screen for business features marketplace
/// Currently shows "Coming Soon" placeholders
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mağaza',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BusinessBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Premium Özellikler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B0E11),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İşletmenizi büyütmek için özel özellikler',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
            ),
            const SizedBox(height: 24),

            // Feature Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                _FeatureCard(
                  icon: Icons.star,
                  title: 'Öne Çıkma',
                  description: 'Arama sonuçlarında üstte görün',
                  price: '₺99/ay',
                  comingSoon: true,
                ),
                _FeatureCard(
                  icon: Icons.campaign,
                  title: 'Kampanya Ekleme',
                  description: 'Sınırsız kampanya oluşturun',
                  price: '₺149/ay',
                  comingSoon: true,
                ),
                _FeatureCard(
                  icon: Icons.notifications_active,
                  title: 'Bildirim Gönderme',
                  description: 'Takipçilerinize bildirim gönderin',
                  price: '₺79/ay',
                  comingSoon: true,
                ),
                _FeatureCard(
                  icon: Icons.analytics,
                  title: 'Gelişmiş Analitik',
                  description: 'Detaylı raporlar ve istatistikler',
                  price: '₺199/ay',
                  comingSoon: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String price;
  final bool comingSoon;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B4BC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFE8B4BC), size: 24),
              ),
              if (comingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Yakında',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B0E11),
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B6B6B),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),

          // Price
          Text(
            price,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE8B4BC),
            ),
          ),
        ],
      ),
    );
  }
}
