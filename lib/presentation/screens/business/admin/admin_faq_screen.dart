import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/business_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AdminFaqScreen extends StatefulWidget {
  const AdminFaqScreen({super.key});

  @override
  State<AdminFaqScreen> createState() => _AdminFaqScreenState();
}

class _AdminFaqScreenState extends State<AdminFaqScreen> {
  late List<Map<String, String>> _faqList;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final venue = context.read<BusinessProvider>().businessVenue;
    _faqList = (venue?.faq ?? [])
        .map(
          (item) => {
            'question': item['question']?.toString() ?? '',
            'answer': item['answer']?.toString() ?? '',
          },
        )
        .toList();
  }

  void _addFaq() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeni Soru Ekle',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B0E11),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                hintText: 'Soru',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Cevap',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (questionController.text.isNotEmpty &&
                      answerController.text.isNotEmpty) {
                    setState(() {
                      _faqList.add({
                        'question': questionController.text,
                        'answer': answerController.text,
                      });
                      _isDirty = true;
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'SORUYU LİSTEYE EKLE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFaq(int index) {
    setState(() {
      _faqList.removeAt(index);
      _isDirty = true;
    });
  }

  void _updateFaq(int index, String key, String value) {
    setState(() {
      _faqList[index][key] = value;
      _isDirty = true;
    });
  }

  Future<void> _saveFaq() async {
    final success = await context.read<BusinessProvider>().updateFaq(_faqList);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sıkça Sorulan Sorular güncellendi')),
      );
      setState(() => _isDirty = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Sıkça Sorulan Sorular',
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isDirty)
            TextButton(
              onPressed: _saveFaq,
              child: const Text(
                'KAYDET',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _faqList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqList.length,
              itemBuilder: (context, index) {
                return _buildFaqItem(index);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFaq,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'YENİ SORU EKLE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _removeFaq(index),
              ),
            ],
          ),
          TextField(
            onChanged: (val) => _updateFaq(index, 'question', val),
            controller: TextEditingController(text: _faqList[index]['question'])
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: _faqList[index]['question']!.length),
              ),
            decoration: const InputDecoration(
              hintText: 'Soru metnini giriniz...',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 14),
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Divider(),
          TextField(
            onChanged: (val) => _updateFaq(index, 'answer', val),
            controller: TextEditingController(text: _faqList[index]['answer'])
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: _faqList[index]['answer']!.length),
              ),
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Cevap metnini giriniz...',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 14),
            ),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          Icon(
            Icons.question_answer_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz Soru Eklenmemiş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Müşterilerinizin merak edebileceği\nsoruları buraya ekleyebilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
