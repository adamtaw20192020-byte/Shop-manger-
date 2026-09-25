import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme/app_colors.dart';
import '../widgets/formatters.dart';
import '../widgets/shop_ui.dart';

enum _Range { day, week, month, custom }

const _rangeLabel = {
  _Range.day: 'اليوم',
  _Range.week: 'هذا الأسبوع',
  _Range.month: 'هذا الشهر',
  _Range.custom: 'مخصص',
};

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  _Range _range = _Range.month;
  final _from = TextEditingController();
  final _to = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    if (shop.loading) return const ShopScreen(child: ShopLoadingState());

    final today = DateTime.now();
    DateTime start;
    switch (_range) {
      case _Range.day:
        start = DateTime(today.year, today.month, today.day);
        break;
      case _Range.week:
        start = today.subtract(const Duration(days: 6));
        break;
      case _Range.month:
        start = DateTime(today.year, today.month, 1);
        break;
      case _Range.custom:
        start = _from.text.isNotEmpty ? DateTime.tryParse('${_from.text}T00:00:00') ?? DateTime(1970) : DateTime(1970);
        break;
    }
    final end = (_range == _Range.custom && _to.text.isNotEmpty) ? (DateTime.tryParse('${_to.text}T23:59:59') ?? today) : today;

    final filteredSales = shop.sales.where((s) {
      final d = DateTime.parse(s.date);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
    final filteredPurchases = shop.purchases.where((p) {
      final d = DateTime.parse(p.date);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();

    final salesTotal = filteredSales.fold<double>(0, (sum, s) => sum + s.total);
    final purchasesTotal = filteredPurchases.fold<double>(0, (sum, p) => sum + p.total);
    final profitTotal = filteredSales.fold<double>(0, (sum, s) => sum + s.profit);
    final costTotal = filteredSales.fold<double>(0, (sum, s) => sum + s.quantity * s.purchasePrice);
    final max = [salesTotal, purchasesTotal, profitTotal, 1.0].reduce((a, b) => a > b ? a : b);

    return ShopScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        children: [
          const ShopHeader(title: 'التقارير', subtitle: 'قراءة واضحة لأداء المحل'),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              textDirection: TextDirection.rtl,
              children: _Range.values
                  .map((r) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.5),
                          child: Material(
                            color: _range == r ? AppColors.primary : AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() => _range = r),
                              child: Container(
                                height: 39,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _range == r ? AppColors.primary : AppColors.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_rangeLabel[r]!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _range == r ? Colors.white : AppColors.mutedForeground,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          if (_range == _Range.custom)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(child: ShopField(label: 'من (YYYY-MM-DD)', controller: _from, placeholder: '2026-01-01')),
                  const SizedBox(width: 9),
                  Expanded(child: ShopField(label: 'إلى (YYYY-MM-DD)', controller: _to, placeholder: '2026-01-31')),
                ],
              ),
            ),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              ShopStatCard(label: 'إجمالي المبيعات', value: formatMoney(salesTotal), icon: Icons.trending_up),
              const SizedBox(width: 10),
              ShopStatCard(label: 'صافي الربح', value: formatMoney(profitTotal), icon: Icons.emoji_events, tone: StatTone.dark),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              ShopStatCard(label: 'إجمالي المشتريات', value: formatMoney(purchasesTotal), icon: Icons.shopping_bag, tone: StatTone.amber),
              const SizedBox(width: 10),
              ShopStatCard(label: 'تكلفة البضاعة', value: formatMoney(costTotal), icon: Icons.layers, tone: StatTone.soft),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('مؤشرات الفترة · ${_rangeLabel[_range]}',
                textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.foreground)),
          ),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                _MetricBar(label: 'المبيعات', value: salesTotal, max: max, color: AppColors.primary),
                _MetricBar(label: 'المشتريات', value: purchasesTotal, max: max, color: const Color(0xFFC18A32)),
                _MetricBar(label: 'الربح', value: profitTotal, max: max, color: const Color(0xFF182B20)),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('مقارنة إجمالية للفترة المحددة', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                    Icon(Icons.bar_chart, size: 19, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text('ملخص العمليات',
                textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.foreground)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                _BreakdownRow(label: 'عدد عمليات البيع', value: '${filteredSales.length} عمليات', icon: Icons.shopping_cart),
                _BreakdownRow(label: 'عدد عمليات الشراء', value: '${filteredPurchases.length} عمليات', icon: Icons.local_shipping),
                _BreakdownRow(
                  label: 'متوسط قيمة البيع',
                  value: formatMoney(filteredSales.isNotEmpty ? salesTotal / filteredSales.length : 0),
                  icon: Icons.attach_money,
                ),
                _BreakdownRow(
                  label: 'هامش الربح',
                  value: '${salesTotal != 0 ? (profitTotal / salesTotal * 100).round() : 0}%',
                  icon: Icons.percent,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;
  const _MetricBar({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio = value == 0 ? 0.0 : (value / max).clamp(0.05, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatMoney(value), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.foreground)),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 10,
              color: AppColors.secondary,
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: ratio,
                alignment: Alignment.centerRight,
                child: Container(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;
  const _BreakdownRow({required this.label, required this.value, required this.icon, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.foreground)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }
}
