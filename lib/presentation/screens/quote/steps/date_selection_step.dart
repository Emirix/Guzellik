import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/quote_provider.dart';

class DateSelectionStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DateSelectionStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DateSelectionStep> createState() => _DateSelectionStepState();
}

class _DateSelectionStepState extends State<DateSelectionStep> {
  final DateTime _today = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = context.read<QuoteProvider>().preferredDate;
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = context.watch<QuoteProvider>();
    final isFlexible =
        quoteProvider.preferredDate == null &&
        quoteProvider.preferredTimeSlot == null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ne zaman hizmet almak istersiniz?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Size uygun olan gün ve saati belirleyin.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildFlexibleOption(isFlexible),
                const SizedBox(height: 32),
                Opacity(
                  opacity: isFlexible ? 0.5 : 1.0,
                  child: AbsorbPointer(
                    absorbing: isFlexible,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(),
                        const SizedBox(height: 16),
                        _buildHorizontalCalendar(),
                        const SizedBox(height: 32),
                        _buildTimeSlots(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
        _buildBottomBar(isFlexible),
      ],
    );
  }

  Widget _buildFlexibleOption(bool isFlexible) {
    return GestureDetector(
      onTap: () {
        if (!isFlexible) {
          context.read<QuoteProvider>().setPreferredDate(null);
          context.read<QuoteProvider>().setPreferredTimeSlot(null);
          setState(() => _selectedDate = null);
        } else {
          // If toggling back from flexible, select today
          final today = DateTime.now();
          context.read<QuoteProvider>().setPreferredDate(today);
          setState(() => _selectedDate = today);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFlexible ? Colors.pink.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFlexible ? Colors.pink : Colors.grey.shade200,
            width: isFlexible ? 2 : 1,
          ),
          boxShadow: isFlexible
              ? [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isFlexible ? Colors.pink : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: isFlexible ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zaman Farketmez (Opsiyonel)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'Esneğim, salonların her anına açığım.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isFlexible)
              const Icon(Icons.check_circle, color: Colors.pink)
            else
              const Icon(Icons.radio_button_off, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate ?? _today),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
      ],
    );
  }

  Widget _buildHorizontalCalendar() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Next 2 weeks
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = _today.add(Duration(days: index));
          final isSelected =
              _selectedDate != null &&
              DateUtils.isSameDay(date, _selectedDate!);
          final weekday = DateFormat('E', 'tr_TR').format(date);
          final day = date.day.toString();

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              context.read<QuoteProvider>().setPreferredDate(date);
            },
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade100,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade400,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      children: [
        _buildTimeCategory('Sabah', Icons.light_mode, Colors.amber, [
          '09:00',
          '10:00',
          '11:00',
        ]),
        const SizedBox(height: 32),
        _buildTimeCategory('Öğle', Icons.wb_sunny, Colors.orange, [
          '13:00',
          '14:00',
          '15:00',
          '16:00',
          '17:00',
        ]),
        const SizedBox(height: 32),
        _buildTimeCategory('Akşam', Icons.dark_mode, Colors.indigo, [
          '18:00',
          '19:00',
          '20:00',
        ]),
      ],
    );
  }

  Widget _buildTimeCategory(
    String title,
    IconData icon,
    Color color,
    List<String> slots,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: Colors.grey.shade100)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final selectedSlot = context
                .watch<QuoteProvider>()
                .preferredTimeSlot;
            final isSelected = selectedSlot == slot;

            return GestureDetector(
              onTap: () =>
                  context.read<QuoteProvider>().setPreferredTimeSlot(slot),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Seçtiğiniz tarih ve saat, salonlara tercihiniz olarak iletilecektir. Salonlar müsaitlik durumuna göre size özel tekliflerini sunacaktır.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isFlexible) {
    final selectedSlot = context.watch<QuoteProvider>().preferredTimeSlot;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SEÇİLEN RANDEVU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isFlexible
                        ? 'Fark etmez'
                        : '${DateFormat('d MMMM EEEE', 'tr_TR').format(_selectedDate ?? _today)}${selectedSlot != null ? ', $selectedSlot' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Text(
                '2/3 Adım',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  (isFlexible || selectedSlot != null || _selectedDate != null)
                  ? widget.onNext
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Devam Et',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
