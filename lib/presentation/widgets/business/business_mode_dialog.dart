import 'package:flutter/material.dart';
import '../../../core/enums/business_mode.dart';

/// Business mode selection dialog
/// Shown to users with business accounts after login
class BusinessModeSelectionDialog extends StatelessWidget {
  final VoidCallback onBusinessModeSelected;
  final VoidCallback onNormalModeSelected;

  const BusinessModeSelectionDialog({
    super.key,
    required this.onBusinessModeSelected,
    required this.onNormalModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8B4BC), Color(0xFFD4A5A5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.business_center,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Hesap Türü Seçin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B0E11),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'Bu hesap bir işletme hesabıdır. Nasıl devam etmek istersiniz?',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Business Mode Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onBusinessModeSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B4BC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.store, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      BusinessMode.business.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Normal Mode Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onNormalModeSelected,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8B4BC),
                  side: const BorderSide(color: Color(0xFFE8B4BC), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      BusinessMode.normal.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the dialog
  static Future<BusinessMode?> show(BuildContext context) async {
    return showDialog<BusinessMode>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BusinessModeSelectionDialog(
        onBusinessModeSelected: () {
          Navigator.of(context).pop(BusinessMode.business);
        },
        onNormalModeSelected: () {
          Navigator.of(context).pop(BusinessMode.normal);
        },
      ),
    );
  }
}
