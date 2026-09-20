import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme/app_colors.dart';
import '../widgets/formatters.dart';
import '../widgets/shop_ui.dart';

enum _Sort { name, stock, price }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  _Sort _sort = _Sort.name;

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
    var filtered = shop.products.where((p) => '${p.name} ${p.category}'.contains(query)).toList();
    switch (_sort) {
      case _Sort.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _Sort.stock:
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case _Sort.price:
        filtered.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
    }

    return ShopScreen(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              children: [
                ShopHeader(
                  title: 'الأصناف',
                  subtitle: '${shop.products.length} أصناف في المحل',
                  action: ShopIconButton(icon: Icons.add, tone: IconTone.green, label: 'إضافة صنف', onPressed: () => _openForm(context)),
                ),
                Container(
                  height: 49,
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
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن صنف أو تصنيف',
                            hintTextDirection: TextDirection.rtl,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${filtered.length} نتيجة', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      Material(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(7),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(7),
                          onTap: () => setState(() {
                            _sort = _sort == _Sort.name ? _Sort.stock : (_sort == _Sort.stock ? _Sort.price : _Sort.name);
                          }),
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tune, size: 15, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _sort == _Sort.name ? 'ترتيب الاسم' : (_sort == _Sort.stock ? 'الأقل مخزونًا' : 'الأعلى سعرًا'),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  const ShopEmptyState(icon: Icons.inventory_2, title: 'لا توجد أصناف', text: 'أضف الأصناف التي تبيعها لتبدأ متابعة المخزون.')
                else
                  Column(
                    children: filtered
                        .map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _ProductCard(product: p, onEdit: () => _openForm(context, p))))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, [Product? product]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(27))),
      builder: (ctx) => _ProductForm(product: product),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  const _ProductCard({required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final low = product.quantity <= product.minStock;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: low ? AppColors.lowStockBorder : AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(color: low ? AppColors.lowStockBg : AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.inventory_2, size: 20, color: low ? AppColors.amberDeeper : AppColors.primary),
              ),
              const Spacer(),
              ShopIconButton(icon: Icons.edit_outlined, label: 'تعديل الصنف', onPressed: onEdit),
              const SizedBox(width: 6),
              ShopIconButton(
                icon: Icons.delete_outline,
                tone: IconTone.danger,
                label: 'حذف الصنف',
                onPressed: () => showConfirmDelete(
                  context: context,
                  title: 'حذف الصنف؟',
                  message: 'لن يمكن استعادة الصنف بعد حذفه.',
                  onConfirm: () => context.read<ShopState>().deleteProduct(product.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(product.name, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.foreground)),
          const SizedBox(height: 4),
          Text(product.category.isEmpty ? 'بدون تصنيف' : product.category,
              textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          Container(
            margin: const EdgeInsets.only(top: 13),
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _Stat(label: 'البيع', value: formatMoney(product.salePrice)),
                _Stat(label: 'الشراء', value: formatMoney(product.purchasePrice)),
                _Stat(
                  label: 'المخزون',
                  value: _trimNum(product.quantity),
                  color: low ? AppColors.amberDeeper : AppColors.primary,
                ),
              ],
            ),
          ),
          if (low)
            Container(
              margin: const EdgeInsets.only(top: 11),
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFEEE1BF), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: const [
                    Icon(Icons.error_outline, size: 12, color: Color(0xFFA87019)),
                    SizedBox(width: 4),
                    Text('مخزون منخفض', style: TextStyle(color: Color(0xFFA87019), fontWeight: FontWeight.w600, fontSize: 10)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _trimNum(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.foreground)),
        ],
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _salePrice;
  late final TextEditingController _quantity;
  late final TextEditingController _minStock;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _purchasePrice = TextEditingController(text: p != null ? _trimNum(p.purchasePrice) : '');
    _salePrice = TextEditingController(text: p != null ? _trimNum(p.salePrice) : '');
    _quantity = TextEditingController(text: p != null ? _trimNum(p.quantity) : '0');
    _minStock = TextEditingController(text: p != null ? _trimNum(p.minStock) : '3');
    _notes = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _purchasePrice.dispose();
    _salePrice.dispose();
    _quantity.dispose();
    _minStock.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
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
                      child: Text(editing ? 'تعديل صنف' : 'إضافة صنف جديد',
                          textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19, color: AppColors.foreground)),
                    ),
                    ShopIconButton(icon: Icons.close, label: 'إغلاق', onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 10),
                ShopField(label: 'اسم الصنف', controller: _name, placeholder: 'اكتب اسم الصنف'),
                ShopField(label: 'التصنيف', controller: _category, placeholder: 'اكتب التصنيف'),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(child: ShopField(label: 'سعر الشراء', controller: _purchasePrice, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 10),
                    Expanded(child: ShopField(label: 'سعر البيع', controller: _salePrice, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(child: ShopField(label: 'الكمية الحالية', controller: _quantity, keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: ShopField(label: 'الحد الأدنى', controller: _minStock, keyboardType: TextInputType.number)),
                  ],
                ),
                ShopField(label: 'ملاحظات (اختياري)', controller: _notes, multiline: true, placeholder: 'تفاصيل تساعدك في إدارة الصنف'),
                ShopPrimaryButton(
                  title: editing ? 'حفظ التعديلات' : 'إضافة الصنف',
                  icon: Icons.check,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _name.text.trim();
    final purchasePrice = double.tryParse(_purchasePrice.text) ?? -1;
    final salePrice = double.tryParse(_salePrice.text) ?? -1;
    final quantity = double.tryParse(_quantity.text) ?? -1;
    final minStock = double.tryParse(_minStock.text) ?? -1;
    if (name.isEmpty || purchasePrice < 0 || salePrice < 0 || quantity < 0 || minStock < 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('بيانات غير صحيحة'),
          content: const Text('أدخل اسمًا وأرقامًا صحيحة.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسنًا'))],
        ),
      );
      return;
    }
    final input = ProductInput(
      name: name,
      category: _category.text.trim(),
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      quantity: quantity,
      minStock: minStock,
      notes: _notes.text,
    );
    final shop = context.read<ShopState>();
    final editing = widget.product;
    if (editing != null) {
      shop.updateProduct(editing.id, input);
    } else {
      shop.addProduct(input);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(editing != null ? 'تم تحديث بيانات الصنف.' : 'تمت إضافة الصنف للمخزون.')),
    );
  }
}
