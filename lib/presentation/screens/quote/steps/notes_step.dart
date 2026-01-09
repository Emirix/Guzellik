import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/quote_provider.dart';

class NotesStep extends StatefulWidget {
  final VoidCallback onBack;

  const NotesStep({super.key, required this.onBack});

  @override
  State<NotesStep> createState() => _NotesStepState();
}

class _NotesStepState extends State<NotesStep> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = context.read<QuoteProvider>().notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Talebinize özel not ekleyin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mekana iletmek istediğiniz özel bir istek veya detay var mı?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.pink.shade900.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                _buildNoteInput(),
                const SizedBox(height: 32),
                const Text(
                  'TALEP ÖZETİ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildSuccessInfo(),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.shade50, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _notesController,
            maxLines: 6,
            onChanged: (value) => context.read<QuoteProvider>().setNotes(value),
            decoration: InputDecoration(
              hintText: 'Özel Notlar / Mesajınız (Opsiyonel)...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              hintStyle: TextStyle(
                color: Colors.pink.shade900.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Icon(
              Icons.edit_note,
              color: Colors.pink.shade900.withOpacity(0.2),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final quoteProvider = context.watch<QuoteProvider>();
    final services = quoteProvider.selectedServices;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem(
            'Seçilen Hizmetler',
            services.map((s) => s.name).join(', '),
            Icons.flare,
            Colors.pink,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.pink.shade50, height: 1),
          ),
          _buildSummaryItem(
            'Tercih Edilen Zaman',
            quoteProvider.preferredDate != null
                ? '${DateFormat('d MMMM, EEEE', 'tr_TR').format(quoteProvider.preferredDate!)}${quoteProvider.preferredTimeSlot != null ? ' • ${quoteProvider.preferredTimeSlot}' : ''}'
                : 'Farketmez (Herhangi bir zaman)',
            Icons.calendar_today,
            Colors.amber.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade900.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Talebiniz uzman ekiplerimiz tarafından incelenecek ve en uygun fiyat teklifleri kısa süre içinde cebinize gelecek.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final quoteProvider = context.watch<QuoteProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.pink.shade50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                color: Colors.pink.shade900.withOpacity(0.4),
                size: 14,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Gönder butonuna basarak Kullanım Koşulları\'nı kabul etmiş olursunuz.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: quoteProvider.isCreating
                  ? null
                  : () async {
                      final success = await quoteProvider.createQuoteRequest();
                      if (success && mounted) {
                        context.go('/quote-success');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
              ),
              child: quoteProvider.isCreating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Teklifi Gönder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.send),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
