import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme/app_colors.dart';
import '../widgets/formatters.dart';
import '../widgets/shop_ui.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    if (shop.loading) return const ShopScreen(child: ShopLoadingState());

    final today = DateTime.now();
    bool isToday(String iso) {
      final d = DateTime.parse(iso);
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }

    final todaySales = shop.sales.where((s) => isToday(s.date)).toList();
    final todayPurchases = shop.purchases.where((p) => isToday(p.date)).toList();
    final salesTotal = todaySales.fold<double>(0, (sum, s) => sum + s.total);
    final purchaseTotal = todayPurchases.fold<double>(0, (sum, p) => sum + p.total);
    final profit = todaySales.fold<double>(0, (sum, s) => sum + s.profit);
    final lowStock = shop.products.where((p) => p.quantity <= p.minStock).toList();

    final activity = [
      ...shop.sales.map((s) => _Activity(kind: 'sale', id: s.id, productName: s.productName, date: s.date, total: s.total)),
      ...shop.purchases.map((p) => _Activity(kind: 'purchase', id: p.id, productName: p.productName, date: p.date, total: p.total)),
    ]..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    final recent = activity.take(4).toList();

    return ShopScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 108),
        children: [
          ShopHeader(
            title: 'الطيور السعيدة 2',
            subtitle: 'لوحة التحكم اليومية',
            action: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.star, color: Colors.white, size: 22),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 23),
            constraints: const BoxConstraints(minHeight: 145),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.foreground, borderRadius: BorderRadius.circular(12)),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  margin: const EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.insights, color: AppColors.foreground, size: 26),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('ملخص اليوم', style: TextStyle(color: Color(0xFFB8D9BE), fontWeight: FontWeight.w600, fontSize: 12)),
                      SizedBox(height: 6),
                      Text('كل شيء تحت السيطرة',
                          textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 21)),
                      SizedBox(height: 8),
                      Text('تابع حركة المحل ومخزونك بسرعة.',
                          textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFB8C9BC), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const ShopSectionTitle(title: 'نظرة سريعة'),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              ShopStatCard(label: 'مبيعات اليوم', value: formatMoney(salesTotal), icon: Icons.trending_up),
              const SizedBox(width: 10),
              ShopStatCard(label: 'مشتريات اليوم', value: formatMoney(purchaseTotal), icon: Icons.shopping_bag, tone: StatTone.soft),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              ShopStatCard(label: 'الربح اليوم', value: formatMoney(profit), icon: Icons.emoji_events, tone: StatTone.dark),
              const SizedBox(width: 10),
              ShopStatCard(label: 'عدد الأصناف', value: '${shop.products.length}', icon: Icons.inventory_2, tone: StatTone.amber),
            ],
          ),
          const SizedBox(height: 23),
          const ShopSectionTitle(title: 'اختصارات'),
          Column(
            children: [
              _Shortcut(icon: Icons.shopping_cart, title: 'المبيعات', color: const Color(0xFFE8E2D2), onTap: () => onNavigate(1)),
              const SizedBox(height: 9),
              _Shortcut(icon: Icons.local_shipping, title: 'المشتريات', color: const Color(0xFFEFE9DC), onTap: () => onNavigate(2)),
              const SizedBox(height: 9),
              _Shortcut(icon: Icons.inventory_2, title: 'الأصناف', color: const Color(0xFFE3EBE3), onTap: () => onNavigate(3)),
              const SizedBox(height: 9),
              _Shortcut(icon: Icons.bar_chart, title: 'التقارير', color: const Color(0xFFE9E1D3), onTap: () => onNavigate(4)),
            ],
          ),
          const SizedBox(height: 23),
          if (lowStock.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 23),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(9)),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: const Color(0xFFEADBB5), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.warning_amber, size: 18, color: Color(0xFFBB7B16)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('تنبيه المخزون', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.foreground)),
                        const SizedBox(height: 3),
                        Text('${lowStock.length} أصناف وصلت للحد الأدنى وتحتاج متابعة.',
                            textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Color(0xFF8F651F))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onNavigate(3),
                    icon: const Icon(Icons.chevron_left, color: Color(0xFFBB7B16)),
                  ),
                ],
              ),
            ),
          ShopSectionTitle(
            title: 'آخر العمليات',
            action: Text('${shop.sales.length + shop.purchases.length} عملية', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
          if (recent.isEmpty)
            const ShopEmptyState(icon: Icons.inbox, title: 'لا توجد عمليات بعد', text: 'أضف أول عملية بيع أو شراء لتظهر هنا.')
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: recent.map((item) {
                  final isSale = item.kind == 'sale';
                  return Container(
                    constraints: const BoxConstraints(minHeight: 70),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: isSale ? AppColors.secondary : AppColors.purchaseBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(isSale ? Icons.north_east : Icons.south_west, size: 17, color: isSale ? AppColors.primary : AppColors.purchaseText),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.foreground)),
                              const SizedBox(height: 4),
                              Text('${isSale ? 'عملية بيع' : 'عملية شراء'} · ${formatDateTime(item.date)}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                        Text(formatMoney(item.total),
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: isSale ? AppColors.primary : AppColors.foreground)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _Activity {
  final String kind;
  final String id;
  final String productName;
  final String date;
  final double total;
  _Activity({required this.kind, required this.id, required this.productName, required this.date, required this.total});
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _Shortcut({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.foreground)),
              ),
              const Icon(Icons.chevron_left, size: 16, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
