import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/venue.dart';
import '../../../providers/admin_cover_photo_provider.dart';

class AdminCoverPhotoScreen extends StatefulWidget {
  final Venue venue;

  const AdminCoverPhotoScreen({super.key, required this.venue});

  @override
  State<AdminCoverPhotoScreen> createState() => _AdminCoverPhotoScreenState();
}

class _AdminCoverPhotoScreenState extends State<AdminCoverPhotoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCoverPhotoProvider>().init(widget.venue);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (!mounted) return;
      context.read<AdminCoverPhotoProvider>().uploadCustomPhoto(
        File(pickedFile.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapak Fotoğrafı Yönetimi'),
        centerTitle: true,
      ),
      body: Consumer<AdminCoverPhotoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categoryPhotos.isEmpty) {
            // PERF: Loading indicator'ı RepaintBoundary ile izole et
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          }

          return Column(
            children: [
              _buildHeader(provider),
              Expanded(child: _buildPhotoGrid(provider)),
              _buildFooter(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AdminCoverPhotoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mevcut Kapak Fotoğrafı',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // PERF: Preview image'ı RepaintBoundary ile izole et
          RepaintBoundary(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: provider.selectedPhotoUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            provider.selectedPhotoUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: provider.selectedPhotoUrl == null
                    ? const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hazır Fotoğraflar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Özel Yükle'),
              ),
            ],
          ),
          Text(
            'İşletmeniz için profesyonel hazır fotoğraflardan birini seçin.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(AdminCoverPhotoProvider provider) {
    if (provider.categoryPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text('Bu kategoriye özel hazır fotoğraf bulunamadı.'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: provider.categoryPhotos.length,
      itemBuilder: (context, index) {
        final url = provider.categoryPhotos[index];
        final isSelected = provider.selectedPhotoUrl == url;

        // PERF: Her grid item'ı RepaintBoundary ile izole et
        // GridView'de birçok image var, hepsi birbirini repaint ettiriyor
        return RepaintBoundary(
          child: GestureDetector(
            onTap: () async => await provider.selectPhoto(url),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // PERF: CachedNetworkImage'ı da RepaintBoundary ile sar
                  RepaintBoundary(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(AdminCoverPhotoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    final success = await provider.saveCoverPhoto();
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kapak fotoğrafı güncellendi'),
                        ),
                      );
                      Navigator.pop(context);
                    } else if (provider.error != null && mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(provider.error!)));
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isLoading
                ? const RepaintBoundary(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : const Text(
                    'Değişiklikleri Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
