import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/admin_gallery_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/venue_photo.dart';
import '../../../../data/models/photo_category_tag.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../widgets/common/business_bottom_nav.dart';

class AdminGalleryScreen extends StatefulWidget {
  const AdminGalleryScreen({super.key});

  @override
  State<AdminGalleryScreen> createState() => _AdminGalleryScreenState();
}

class _AdminGalleryScreenState extends State<AdminGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _deletingPhotoId; // Track which photo is being deleted

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  Future<void> _loadPhotos() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.currentVenue?.id;
    if (venueId != null) {
      await Future.wait([
        context.read<AdminGalleryProvider>().fetchPhotos(venueId),
        context.read<AdminGalleryProvider>().fetchCategories(),
      ]);
    }
  }

  Future<void> _pickImage() async {
    final provider = context.read<AdminGalleryProvider>();
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.currentVenue?.id;

    if (venueId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşletme bilgisi bulunamadı.')),
      );
      return;
    }

    if (!provider.canAddMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimum 10 fotoğraf yükleyebilirsiniz.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final XFile? image;
    try {
      image = await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Galeri hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Galeri açılırken hata oluştu: $e')),
        );
      }
      return;
    }

    if (image == null) return;
    if (!mounted) return;

    if (provider.categories.isEmpty) {
      try {
        await provider.fetchCategories();
      } catch (e) {
        debugPrint('Kategori yükleme hatası: $e');
      }
    }

    String? selectedCategoryId;
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      selectedCategoryId = await showModalBottomSheet<String>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Kategori Seçin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildCategoryItem(
                      context: context,
                      title: 'Etiketsiz Devam Et',
                      icon: Icons.not_interested,
                      onTap: () => Navigator.pop(context, null),
                      isNone: true,
                    ),
                    ...provider.categories.map((category) {
                      return _buildCategoryItem(
                        context: context,
                        title: category.name,
                        icon: IconUtils.getCategoryIcon(
                          category.icon ?? category.slug,
                        ),
                        onTap: () => Navigator.pop(context, category.id),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    try {
      final File imageFile = File(image.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Fotoğraf yükleniyor...'),
              ],
            ),
            duration: Duration(minutes: 1),
          ),
        );
      }

      await provider.uploadPhoto(
        venueId,
        imageFile,
        categoryId: selectedCategoryId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf başarıyla yüklendi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        final userId = businessProvider.businessVenue?.ownerId;
        if (userId != null) {
          await businessProvider.refreshVenue(userId);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorDialog('Fotoğraf yüklenirken bir hata oluştu: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
        tooltip: 'Fotoğraf Ekle',
      ),
      appBar: AppBar(
        title: const Text(
          'Galeri Yönetimi',
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
            onPressed: _loadPhotos,
          ),
        ],
      ),
      bottomNavigationBar: const BusinessBottomNav(),
      body: Consumer<AdminGalleryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.photos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.error != null && provider.photos.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          final photos = provider.photos;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Galeri (${photos.length}/10)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (provider.canAddMore)
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Ekle'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              if (photos.isEmpty)
                Expanded(child: _buildEmptyState())
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      String? categoryName;
                      if (photo.categoryId != null) {
                        try {
                          categoryName = provider.categories
                              .firstWhere((c) => c.id == photo.categoryId)
                              .name;
                        } catch (_) {}
                      }

                      return _PhotoCard(
                        photo: photo,
                        categoryName: categoryName,
                        isDeleting: _deletingPhotoId == photo.id,
                        onDelete: () => _deletePhoto(photo.id),
                        onSetHero: () => _setHero(photo.id),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
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
            onPressed: _loadPhotos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.collections_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz Görsel Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İşletmenizi tanıtan görseller ekleyerek\nmüşterilerin ilgisini çekin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
            label: const Text(
              'FOTOĞRAF EKLE',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotoğrafı Sil'),
        content: const Text('Bu fotoğraf galeriden kalıcı olarak silinecek.'),
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
      setState(() {
        _deletingPhotoId = photoId;
      });

      try {
        await context.read<AdminGalleryProvider>().deletePhoto(photoId);

        if (mounted) {
          final businessProvider = context.read<BusinessProvider>();
          final userId = businessProvider.businessVenue?.ownerId;
          if (userId != null) {
            await businessProvider.refreshVenue(userId);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _deletingPhotoId = null;
          });
        }
      }
    }
  }

  Future<void> _setHero(String photoId) async {
    try {
      await context.read<AdminGalleryProvider>().setAsHero(photoId);

      if (mounted) {
        final businessProvider = context.read<BusinessProvider>();
        final userId = businessProvider.businessVenue?.ownerId;
        if (userId != null) {
          await businessProvider.refreshVenue(userId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kapak fotoğrafı güncellendi')),
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

  Widget _buildCategoryItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isNone = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isNone ? AppColors.gray600 : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isNone ? AppColors.gray600 : AppColors.black,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final VenuePhoto photo;
  final String? categoryName;
  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onSetHero;

  const _PhotoCard({
    required this.photo,
    this.categoryName,
    this.isDeleting = false,
    required this.onDelete,
    required this.onSetHero,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel =
        categoryName ??
        photo.categoryName ??
        (photo.category != null ? photo.category!.displayName : null);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            photo.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Deleting Overlay
        if (isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Siliniyor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (!isDeleting && (photo.isHeroImage || displayLabel != null))
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (photo.isHeroImage)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Kapak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (displayLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      displayLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (!isDeleting)
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
