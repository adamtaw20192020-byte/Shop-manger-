import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme/app_colors.dart';
import '../widgets/formatters.dart';
import '../widgets/shop_ui.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    if (shop.loading) return const ShopScreen(child: ShopLoadingState());

    final query = _search.text.trim();
    final filtered = shop.sales.where((s) => s.productName.contains(query)).toList();
    final totalAmount = shop.sales.fold<double>(0, (sum, s) => sum + s.total);
    final totalUnits = shop.sales.fold<double>(0, (sum, s) => sum + s.quantity);

    return ShopScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        children: [
          ShopHeader(
            title: 'المبيعات',
            subtitle: '${shop.sales.length} عملية مسجلة',
            action: ShopIconButton(icon: Icons.add, tone: IconTone.green, label: 'إضافة بيع', onPressed: () => _openForm(context)),
          ),
          Container(
            height: 49,
            margin: const EdgeInsets.only(bottom: 13),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(Icons.search, size: 18, color: AppColors.mutedForeground),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(hintText: 'ابحث في عمليات البيع', border: InputBorder.none, isDense: true),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 81),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(9)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(formatMoney(totalAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.primary)),
                        const SizedBox(height: 5),
                        const Text('إجمالي المبيعات', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 81),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_trimNum(totalUnits), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.foreground)),
                        const SizedBox(height: 5),
                        const Text('وحدة مباعة', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text('سجل المبيعات',
              textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.foreground)),
          const SizedBox(height: 11),
          if (filtered.isEmpty)
            const ShopEmptyState(icon: Icons.shopping_cart, title: 'لا توجد مبيعات مطابقة', text: 'أضف عملية بيع جديدة أو غيّر كلمة البحث.')
          else
            ...filtered.map((sale) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _TransactionCard(
                    icon: Icons.north_east,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.secondary,
                    name: sale.productName,
                    meta: '${_trimNum(sale.quantity)} × ${formatMoney(sale.salePrice)} · ${formatDateTime(sale.date)}',
                    extra: 'ربح ${formatMoney(sale.profit)}',
                    extraColor: AppColors.primary,
                    total: formatMoney(sale.total),
                    onEdit: () => _openForm(context, sale),
                    onDelete: () => showConfirmDelete(
                      context: context,
                      title: 'حذف عملية البيع؟',
                      message: 'سيتمت إعادة الكمية المباعة إلى المخزون.',
                      onConfirm: () => context.read<ShopState>().deleteSale(sale.id),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, [Sale? sale]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => _SaleForm(sale: sale),
    );
  }
}

String _trimNum(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

class _TransactionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String name;
  final String meta;
  final String extra;
  final Color extraColor;
  final String total;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TransactionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.name,
    required this.meta,
    required this.extra,
    required this.extraColor,
    required this.total,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.foreground)),
                const SizedBox(height: 5),
                Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                const SizedBox(height: 4),
                Text(extra, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: extraColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(total, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.foreground)),
              const SizedBox(height: 9),
              Row(
                children: [
                  ShopIconButton(icon: Icons.edit_outlined, label: 'تعديل', onPressed: onEdit),
                  const SizedBox(width: 5),
                  ShopIconButton(icon: Icons.delete_outline, tone: IconTone.danger, label: 'حذف', onPressed: onDelete),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaleForm extends StatefulWidget {
  final Sale? sale;
  const _SaleForm({this.sale});
  @override
  State<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<_SaleForm> {
  String? _productId;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final s = widget.sale;
    _productId = s?.productId;
    _quantity = TextEditingController(text: s != null ? _trimNum(s.quantity) : '1');
    _price = TextEditingController(text: s != null ? _trimNum(s.salePrice) : '');
    _notes = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final editing = widget.sale != null;
    final selected = shop.products.where((p) => p.id == _productId).cast<Product?>().firstWhere((_) => true, orElse: () => null);
    final total = (double.tryParse(_quantity.text) ?? 0) * (double.tryParse(_price.text) ?? 0);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(editing ? 'تعديل عملية بيع' : 'إضافة عملية بيع',
                          textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19, color: AppColors.foreground)),
                    ),
                    ShopIconButton(icon: Icons.close, label: 'إغلاق', onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 10),
                ShopSelectField(
                  label: 'الصنف',
                  value: selected?.name,
                  onTap: () => showProductPicker(
                    context: context,
                    items: shop.products.map((p) => PickerItem(id: p.id, name: p.name, quantity: p.quantity)).toList(),
                    selectedId: _productId,
                    onSelect: (id) {
                      setState(() {
                        _productId = id;
                        final item = shop.products.where((p) => p.id == id).cast<Product?>().firstWhere((_) => true, orElse: () => null);
                        if (item != null) _price.text = _trimNum(item.salePrice);
                      });
                    },
                  ),
                ),
                ShopField(label: 'الكمية', controller: _quantity, keyboardType: TextInputType.number, placeholder: 'اكتب الكمية'),
                ShopField(label: 'سعر البيع للوحدة', controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), placeholder: 'اكتب السعر'),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  constraints: const BoxConstraints(minHeight: 74),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(9)),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي العملية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                      Text(formatMoney(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
                ShopField(label: 'ملاحظات (اختياري)', controller: _notes, multiline: true, placeholder: 'أضف ملاحظة قصيرة'),
                ShopPrimaryButton(
                  title: editing ? 'حفظ التعديلات' : 'حفظ عملية البيع',
                  icon: Icons.check,
                  onPressed: () => _submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final quantity = double.tryParse(_quantity.text) ?? -1;
    final price = double.tryParse(_price.text) ?? -1;
    if (_productId == null || quantity <= 0 || price < 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('بيانات غير صحيحة'),
          content: const Text('اختر صنفًا وأدخل كمية وسعرًا صحيحين.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا'))],
        ),
      );
      return;
    }
    final input = SaleInput(
      productId: _productId!,
      quantity: quantity,
      salePrice: price,
      date: widget.sale?.date ?? DateTime.now().toIso8601String(),
      notes: _notes.text,
    );
    final shop = context.read<ShopState>();
    final result = widget.sale != null ? shop.updateSale(widget.sale!.id, input) : shop.addSale(input);
    if (result.ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.sale != null ? 'تم تحديث عملية البيع والمخزون.' : 'تم تسجيل البيع وخصم الكمية.')),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذر الحفظ'),
          content: Text(result.message ?? ''),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا'))],
        ),
      );
    }
  }
}
