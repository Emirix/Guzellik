import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/admin_services_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../widgets/common/business_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/venue_service.dart';
import 'service_edit_screen.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  Future<void> _loadServices() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.currentVenue?.id;
    if (venueId != null) {
      await context.read<AdminServicesProvider>().initialize(venueId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Hizmet Yönetimi',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadServices,
          ),
        ],
      ),
      bottomNavigationBar: const BusinessBottomNav(),
      body: Consumer<AdminServicesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          final services = provider.venueServices;

          return Column(
            children: [
              _buildStatsHeader(services),
              Expanded(
                child: services.isEmpty
                    ? _buildEmptyState()
                    : Theme(
                        data: ThemeData(canvasColor: Colors.transparent),
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: services.length,
                          onReorder: (oldIndex, newIndex) {
                            _handleReorder(oldIndex, newIndex, services);
                          },
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return _ServiceCard(
                              key: ValueKey(service.id),
                              service: service,
                              onEdit: () => _editService(service),
                              onToggleActive: () => _toggleActive(service),
                              onDelete: () => _deleteService(service),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewService,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'YENİ HİZMET EKLE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(List<VenueService> services) {
    final activeCount = services.where((s) => s.isActive).length;
    final inactiveCount = services.length - activeCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Toplam', '${services.length}', Colors.grey[700]!),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem('Aktif', '$activeCount', Colors.green),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem('Pasif', '$inactiveCount', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadServices,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: StadiumBorder(),
            ),
            child: const Text(
              'TEKRAR DENE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz Hizmetiniz Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hemen ilk hizmetinizi ekleyerek\nrandevu almaya başlayın.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex, List<VenueService> services) {
    if (newIndex > oldIndex) newIndex -= 1;
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.currentVenue?.id;
    if (venueId == null) return;

    final reorderedIds = List<String>.from(services.map((s) => s.id));
    final item = reorderedIds.removeAt(oldIndex);
    reorderedIds.insert(newIndex, item);

    context.read<AdminServicesProvider>().reorderServices(
      venueId,
      reorderedIds,
    );
  }

  void _addNewService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ServiceEditScreen()),
    );
  }

  void _editService(VenueService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceEditScreen(service: service),
      ),
    );
  }

  Future<void> _toggleActive(VenueService service) async {
    try {
      await context.read<AdminServicesProvider>().updateService(
        service.id,
        isActive: !service.isActive,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              service.isActive ? 'Hizmet gizlendi' : 'Hizmet yayına alındı',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: service.isActive ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _deleteService(VenueService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hizmeti Sil'),
        content: Text(
          '${service.displayName} listeden kalıcı olarak kaldırılacak.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İPTAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'SİL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<AdminServicesProvider>().deleteService(service.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hizmet silindi'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final VenueService service;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _ServiceCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: 0, // List uses actual index
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: service.isActive
                                    ? Colors.black87
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.serviceCategory ?? 'Kategori Belirtilmemiş',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.access_time_filled_rounded,
                            '${service.effectiveDuration} dk',
                            Colors.blue[50]!,
                            Colors.blue[700]!,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.payments_rounded,
                            '${service.effectivePrice.toStringAsFixed(0)} ₺',
                            AppColors.gold.withOpacity(0.1),
                            AppColors.gold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: service.isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service.isActive ? 'AKTİF' : 'PASİF',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: service.isActive ? Colors.green : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'toggle') onToggleActive();
        if (val == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        _buildPopupItem('Düzenle', Icons.edit_rounded, 'edit', Colors.black87),
        _buildPopupItem(
          service.isActive ? 'Pasife Al' : 'Yayına Al',
          service.isActive
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          'toggle',
          Colors.black87,
        ),
        const PopupMenuDivider(),
        _buildPopupItem(
          'Sil',
          Icons.delete_outline_rounded,
          'delete',
          Colors.redAccent,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    IconData icon,
    String value,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
