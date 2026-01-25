import 'package:flutter/material.dart';
import '../../common/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/venue_photo.dart';
import '../../../../core/utils/icon_utils.dart';

class PhotosTab extends StatefulWidget {
  final Venue venue;

  const PhotosTab({super.key, required this.venue});

  @override
  State<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<PhotosTab> {
  String? _selectedCategorySlug;
  final ScrollController _scrollController = ScrollController();
  bool _showArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollListener());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final bool canScroll = _scrollController.position.maxScrollExtent > 0;
    final bool isAtEnd =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 20;

    if (_showArrow != (canScroll && !isAtEnd)) {
      setState(() {
        _showArrow = canScroll && !isAtEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allPhotosWithMeta = [];

    for (var url in widget.venue.heroImages) {
      allPhotosWithMeta.add({
        'url': url,
        'slug': 'hero',
        'displayName': 'Kapak',
        'icon': 'stars',
      });
    }

    if (widget.venue.galleryPhotos != null) {
      for (var photo in widget.venue.galleryPhotos!) {
        String? slug;
        String? name;
        String? icon;

        if (photo.category != null) {
          slug = photo.category!.toJson();
          name = photo.category!.displayName;
          icon = slug;
        } else if (photo.categoryName != null) {
          name = photo.categoryName;
          slug = name;
          icon = 'tag';
        }

        allPhotosWithMeta.add({
          'url': photo.url,
          'slug': slug ?? 'other',
          'displayName': name ?? 'Diğer',
          'icon': icon,
        });
      }
    }

    if (allPhotosWithMeta.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.photo_library_outlined,
          title: 'Fotoğraf Bulunamadı',
          message: 'Bu mekan için henüz fotoğraf yüklenmemiş.',
        ),
      );
    }

    final Map<String, Map<String, dynamic>> uniqueCategories = {
      'all': {'name': 'Tümü', 'icon': 'category'},
    };
    for (var item in allPhotosWithMeta) {
      uniqueCategories[item['slug'] as String] = {
        'name': item['displayName'] as String,
        'icon': item['icon'],
      };
    }

    final filteredPhotos =
        _selectedCategorySlug == null || _selectedCategorySlug == 'all'
        ? allPhotosWithMeta
        : allPhotosWithMeta
              .where((p) => p['slug'] == _selectedCategorySlug)
              .toList();

    return Column(
      children: [
        if (uniqueCategories.length > 2)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Stack(
              children: [
                ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: uniqueCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final slug = uniqueCategories.keys.elementAt(index);
                    final data = uniqueCategories.values.elementAt(index);
                    final isSelected = (_selectedCategorySlug ?? 'all') == slug;

                    return ChoiceChip(
                      showCheckmark: false, // Tik işaretini kaldırır
                      avatar: Icon(
                        IconUtils.getCategoryIcon(data['icon'] as String?),
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      label: Text(data['name'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategorySlug = slug;
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.gray700,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray200,
                        ),
                      ),
                      elevation: isSelected ? 2 : 0,
                    );
                  },
                ),
                if (_showArrow)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: filteredPhotos.isEmpty
              ? const Center(child: Text('Bu kategoride fotoğraf bulunamadı.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredPhotos.length,
                  itemBuilder: (context, index) {
                    final photoUrl = filteredPhotos[index]['url'] as String;
                    final allUrls = filteredPhotos
                        .map((e) => e['url'] as String)
                        .toList();

                    return _PhotoCard(
                      imageUrl: photoUrl,
                      onTap: () => _openPhotoViewer(context, allUrls, index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openPhotoViewer(BuildContext context, List<String> photos, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _PhotoViewerPage(photos: photos, initialIndex: index),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _PhotoCard({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.gray200,
                  child: const Icon(
                    Icons.broken_image,
                    size: 32,
                    color: AppColors.gray400,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoViewerPage extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerPage({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(widget.photos[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_currentIndex + 1} / ${widget.photos.length}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
