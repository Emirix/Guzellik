import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A beautiful, searchable dropdown widget for location selection
class SearchableLocationDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? value;
  final List<SearchableDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(T?)? validator;

  const SearchableLocationDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
  });

  @override
  State<SearchableLocationDropdown<T>> createState() =>
      _SearchableLocationDropdownState<T>();
}

class _SearchableLocationDropdownState<T>
    extends State<SearchableLocationDropdown<T>> {
  String? _errorText;

  String? _getSelectedLabel() {
    if (widget.value == null) return null;
    try {
      return widget.items
          .firstWhere((item) => item.value == widget.value)
          .label;
    } catch (e) {
      return null;
    }
  }

  void _showSearchModal() {
    if (!widget.enabled) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchModal<T>(
        title: widget.label,
        items: widget.items,
        selectedValue: widget.value,
        onSelected: (value) {
          widget.onChanged?.call(value);
          setState(() {
            _errorText = widget.validator?.call(value);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _getSelectedLabel();
    final hasValue = selectedLabel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B0E11),
              ),
            ),
          ),

        // Dropdown Button
        GestureDetector(
          onTap: _showSearchModal,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _errorText != null
                    ? Colors.red
                    : hasValue
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : const Color(0xFFE6D1D6),
                width: hasValue ? 1.5 : 1,
              ),
              boxShadow: hasValue
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Prefix Icon
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    color: hasValue
                        ? AppColors.primary
                        : const Color(0xFF955062).withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],

                // Value or Hint
                Expanded(
                  child: Text(
                    selectedLabel ?? widget.hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasValue
                          ? const Color(0xFF1B0E11)
                          : const Color(0xFF955062).withValues(alpha: 0.5),
                      fontWeight: hasValue
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Trailing Icon
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.enabled
                      ? const Color(0xFF955062)
                      : Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        // Error Text
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              _errorText!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

/// Search Modal for location selection
class _SearchModal<T> extends StatefulWidget {
  final String title;
  final List<SearchableDropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;

  const _SearchModal({
    required this.title,
    required this.items,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_SearchModal<T>> createState() => _SearchModalState<T>();
}

class _SearchModalState<T> extends State<_SearchModal<T>> {
  final _searchController = TextEditingController();
  List<SearchableDropdownItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => item.label.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6D1D6)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Ara...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _filterItems('');
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Items List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sonuç bulunamadı',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item.value == widget.selectedValue;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF1B0E11),
                          ),
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : null,
                        onTap: () {
                          widget.onSelected(item.value);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Item for SearchableLocationDropdown
class SearchableDropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;

  const SearchableDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
  });
}
