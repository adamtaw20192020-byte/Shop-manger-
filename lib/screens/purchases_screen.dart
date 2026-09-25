import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme/app_colors.dart';
import '../widgets/formatters.dart';
import '../widgets/shop_ui.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});
  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
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
    final filtered = shop.purchases.where((p) => p.productName.contains(query)).toList();
    final totalAmount = shop.purchases.fold<double>(0, (sum, p) => sum + p.total);
    final totalUnits = shop.purchases.fold<double>(0, (sum, p) => sum + p.quantity);

    return ShopScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        children: [
          ShopHeader(
            title: 'المشتريات',
            subtitle: '${shop.purchases.length} عملية توريد',
            action: ShopIconButton(icon: Icons.add, tone: IconTone.green, label: 'إضافة شراء', onPressed: () => _openForm(context)),
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
                    decoration: const InputDecoration(hintText: 'ابحث في عمليات الشراء', border: InputBorder.none, isDense: true),
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
                    decoration: BoxDecoration(color: AppColors.purchaseBg, borderRadius: BorderRadius.circular(9)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(formatMoney(totalAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.amberDeep)),
                        const SizedBox(height: 5),
                        const Text('إجمالي المشتريات', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
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
                        const Text('وحدة مستلمة', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text('سجل المشتريات',
              textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.foreground)),
          const SizedBox(height: 11),
          if (filtered.isEmpty)
            const ShopEmptyState(icon: Icons.local_shipping, title: 'لا توجد مشتريات مطابقة', text: 'أضف عملية شراء جديدة أو غيّر كلمة البحث.')
          else
            ...filtered.map((purchase) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _TransactionCard(
                    name: purchase.productName,
                    meta: '${_trimNum(purchase.quantity)} × ${formatMoney(purchase.purchasePrice)} · ${formatDateTime(purchase.date)}',
                    extra: purchase.supplier.isEmpty ? 'بدون مورد' : purchase.supplier,
                    total: formatMoney(purchase.total),
                    onEdit: () => _openForm(context, purchase),
                    onDelete: () => showConfirmDelete(
                      context: context,
                      title: 'حذف عملية الشراء؟',
                      message: 'سيتم خصم الكمية الموردة من المخزون.',
                      onConfirm: () => context.read<ShopState>().deletePurchase(purchase.id),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, [Purchase? purchase]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => _PurchaseForm(purchase: purchase),
    );
  }
}

String _trimNum(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

class _TransactionCard extends StatelessWidget {
  final String name;
  final String meta;
  final String extra;
  final String total;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TransactionCard({
    required this.name,
    required this.meta,
    required this.extra,
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
            decoration: BoxDecoration(color: AppColors.purchaseBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.south_west, size: 19, color: AppColors.purchaseText),
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
                Text(extra, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
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

class _PurchaseForm extends StatefulWidget {
  final Purchase? purchase;
  const _PurchaseForm({this.purchase});
  @override
  State<_PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<_PurchaseForm> {
  String? _productId;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _supplier;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final p = widget.purchase;
    _productId = p?.productId;
    _quantity = TextEditingController(text: p != null ? _trimNum(p.quantity) : '1');
    _price = TextEditingController(text: p != null ? _trimNum(p.purchasePrice) : '');
    _supplier = TextEditingController(text: p?.supplier ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _supplier.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final editing = widget.purchase != null;
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
                      child: Text(editing ? 'تعديل عملية شراء' : 'إضافة عملية شراء',
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
                        if (item != null) _price.text = _trimNum(item.purchasePrice);
                      });
                    },
                  ),
                ),
                ShopField(label: 'الكمية', controller: _quantity, keyboardType: TextInputType.number, placeholder: 'اكتب الكمية'),
                ShopField(label: 'سعر الشراء للوحدة', controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), placeholder: 'اكتب السعر'),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  constraints: const BoxConstraints(minHeight: 74),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: AppColors.purchaseBg, borderRadius: BorderRadius.circular(9)),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي الشراء', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                      Text(formatMoney(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.amberDeep)),
                    ],
                  ),
                ),
                ShopField(label: 'المورد (اختياري)', controller: _supplier, placeholder: 'اسم المورد'),
                ShopField(label: 'ملاحظات (اختياري)', controller: _notes, multiline: true, placeholder: 'أضف ملاحظة قصيرة'),
                ShopPrimaryButton(
                  title: editing ? 'حفظ التعديلات' : 'حفظ عملية الشراء',
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
    final input = PurchaseInput(
      productId: _productId!,
      quantity: quantity,
      purchasePrice: price,
      supplier: _supplier.text,
      date: widget.purchase?.date ?? DateTime.now().toIso8601String(),
      notes: _notes.text,
    );
    final shop = context.read<ShopState>();
    if (widget.purchase != null) {
      shop.updatePurchase(widget.purchase!.id, input);
    } else {
      shop.addPurchase(input);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.purchase != null ? 'تم تحديث الشراء والمخزون.' : 'تم تسجيل الشراء وزيادة المخزون.')),
    );
  }
}
