import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/quote_request.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/quote/quote_card.dart';

class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({super.key});

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().fetchMyQuotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'Teklif Taleplerim',
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
        body: Consumer<QuoteProvider>(
          builder: (context, quoteProvider, _) {
            if (quoteProvider.isLoadingQuotes &&
                quoteProvider.myQuotes.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (quoteProvider.quotesError != null &&
                quoteProvider.myQuotes.isEmpty) {
              return _buildErrorState(quoteProvider);
            }

            final activeQuotes = quoteProvider.myQuotes
                .where((q) => q.status == QuoteStatus.active)
                .toList();
            final closedQuotes = quoteProvider.myQuotes
                .where((q) => q.status == QuoteStatus.closed)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildStats(quoteProvider),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                  ),
                  child: TabBar(
                    indicator: UnderlineTabIndicator(
                      borderSide: const BorderSide(
                        width: 3.0,
                        color: AppColors.primary,
                      ),
                      insets: const EdgeInsets.symmetric(horizontal: 40.0),
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.gray500,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    tabs: const [
                      Tab(text: 'Aktif Talepler'),
                      Tab(text: 'Kapatılanlar'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildQuoteList(
                        quoteProvider,
                        activeQuotes,
                        'Taleplerin',
                      ),
                      _buildQuoteList(
                        quoteProvider,
                        closedQuotes,
                        'Arşivlenen Taleplerim',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamed('quote-request'),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Yeni Teklif İste',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteList(
    QuoteProvider provider,
    List<QuoteRequest> quotes,
    String title,
  ) {
    if (quotes.isEmpty && !provider.isLoadingQuotes) {
      return _buildEmptyState(isClosed: title.contains('Arşiv'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMyQuotes(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...quotes.map(
            (quote) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Opacity(
                opacity: quote.status == QuoteStatus.closed ? 0.8 : 1.0,
                child: QuoteCard(quote: quote),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStats(QuoteProvider provider) {
    final activeCount = provider.myQuotes
        .where((q) => q.status == QuoteStatus.active)
        .length;
    final totalOffers = provider.myQuotes.fold(
      0,
      (sum, q) => sum + q.responseCount,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Aktif Talep',
            activeCount.toString(),
            Icons.chat_bubble_outline_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Gelen Teklif',
            totalOffers.toString(),
            Icons.local_offer_outlined,
            Colors.amber.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isClosed = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isClosed ? Icons.archive_outlined : Icons.request_quote_rounded,
                size: 60,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isClosed ? 'Kapatılan Talebin Yok' : 'Henüz Talebin Yok',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isClosed
                  ? 'Kapatılmış veya süresi dolmuş bir talebin bulunmuyor.'
                  : 'Hayalindeki hizmet için hemen bir teklif iste, en iyi salonlardan yanıt al.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(QuoteProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 24),
            const Text(
              'Bir Şeyler Yanlış Gitti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.quotesError ?? 'Bilinmeyen bir hata oluştu',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray600),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => provider.fetchMyQuotes(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
