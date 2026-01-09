import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/quote_request.dart';
import '../../../data/models/quote_response.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/quote/quote_response_card.dart';

class QuoteDetailScreen extends StatefulWidget {
  final QuoteRequest quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  List<QuoteResponse>? _responses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final responses = await context.read<QuoteProvider>().getResponses(
      widget.quote.id,
    );
    if (mounted) {
      setState(() {
        _responses = responses;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Talep Detayı',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadResponses,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequestInfoCard(),
              const SizedBox(height: 32),
              _buildStatusHeader(),
              const SizedBox(height: 16),
              _buildResponsesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TALEP BİLGİLERİ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '#${widget.quote.id.substring(0, 8)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRowV2(
            Icons.spa_rounded,
            'Hizmetler',
            widget.quote.services.map((s) => s.name).join(', '),
          ),
          const SizedBox(height: 20),
          _buildInfoRowV2(
            Icons.calendar_today_rounded,
            'Tercih Edilen Zaman',
            widget.quote.preferredDate != null
                ? '${DateFormat('d MMMM EEEE', 'tr_TR').format(widget.quote.preferredDate!)}${widget.quote.preferredTimeSlot != null ? ' • ${widget.quote.preferredTimeSlot}' : ''}'
                : 'Farketmez',
          ),
          if (widget.quote.notes != null && widget.quote.notes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildInfoRowV2(
              Icons.notes_rounded,
              'Notlarım',
              widget.quote.notes!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRowV2(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.gray400,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    final isActive = widget.quote.status == QuoteStatus.active;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gelen Teklifler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isLoading
                  ? 'Kontrol ediliyor...'
                  : _responses != null && _responses!.isNotEmpty
                  ? '${_responses!.length} Salon Yanıt Verdi'
                  : 'Henüz yanıt gelmedi',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (isActive)
          Container(
            height: 40,
            child: TextButton.icon(
              onPressed: () async {
                final confirmed = await _showCloseDialog();
                if (confirmed && mounted) {
                  await context.read<QuoteProvider>().closeQuote(
                    widget.quote.id,
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text(
                'Talebi Kapat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                backgroundColor: AppColors.error.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResponsesList() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_responses == null || _responses!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.gray100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Teklifler Hazırlanıyor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'En iyi salonlar talebini inceliyor. Yeni bir teklif geldiğinde sana bildirim göndereceğiz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _responses!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          QuoteResponseCard(response: _responses![index]),
    );
  }

  Future<bool> _showCloseDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: const Text(
              'Talebi Kapat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Bu talebi kapatmak istediğinize emin misiniz? Artık yeni teklif alamazsınız.',
              style: TextStyle(height: 1.5),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'VAZGEÇ',
                  style: TextStyle(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'KAPAT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
