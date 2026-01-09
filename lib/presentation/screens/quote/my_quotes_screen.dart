import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text(
          'Teklif Taleplerim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.pink.shade50, height: 1),
        ),
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, _) {
          if (quoteProvider.isLoadingQuotes && quoteProvider.myQuotes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quoteProvider.quotesError != null &&
              quoteProvider.myQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.pink.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text('Hata oluştu: ${quoteProvider.quotesError}'),
                  TextButton(
                    onPressed: () => quoteProvider.fetchMyQuotes(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (quoteProvider.myQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.request_quote_outlined,
                      size: 64,
                      color: Colors.pink.shade200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Henüz teklif talebiniz yok',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hizmet almak için hemen teklif isteyin.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pushNamed('quote-request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Yeni Teklif İste',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => quoteProvider.fetchMyQuotes(),
            color: Colors.pink,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: quoteProvider.myQuotes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final quote = quoteProvider.myQuotes[index];
                return QuoteCard(quote: quote);
              },
            ),
          );
        },
      ),
    );
  }
}
