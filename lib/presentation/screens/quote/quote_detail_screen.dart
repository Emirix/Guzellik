import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/quote_request.dart';
import '../../../data/models/quote_response.dart';
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
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: Text(
          'Talep Detayı',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRequestInfo(),
            _buildStatusHeader(),
            _buildResponsesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3E8EA))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TALEP BİLGİLERİ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade300,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '#${widget.quote.id.substring(0, 8)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.spa_outlined,
            'Hizmetler',
            widget.quote.services.map((s) => s.name).join(', '),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Tercih Edilen Zaman',
            '${DateFormat('d MMMM EEEE', 'tr_TR').format(widget.quote.preferredDate)} • ${widget.quote.preferredTimeSlot}',
          ),
          if (widget.quote.notes != null && widget.quote.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.notes, 'Notlarım', widget.quote.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.pink.shade200),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TEKLİFLER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isLoading
                    ? 'Yükleniyor...'
                    : '${_responses?.length ?? 0} Salon Teklif Verdi',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isActive)
            TextButton.icon(
              onPressed: () async {
                final confirmed = await _showCloseDialog();
                if (confirmed && mounted) {
                  await context.read<QuoteProvider>().closeQuote(
                    widget.quote.id,
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Talebi Kapat'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsesList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(),
      );
    }

    if (_responses == null || _responses!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Henüz teklif gelmedi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Salonlar talebinizi inceliyor. Teklif geldiğinde bildirim alacaksınız.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            title: const Text('Talebi Kapat'),
            content: const Text(
              'Bu talebi kapatmak istediğinize emin misiniz? Artık yeni teklif alamazsınız.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('VAZGEÇ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('KAPAT', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
