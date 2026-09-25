import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

const _storageKey = 'al_tuyour_shop_manager_v1';

String _makeId(String prefix) {
  final rand = Random();
  final suffix = List.generate(6, (_) => '0123456789abcdefghijklmnopqrstuvwxyz'[rand.nextInt(36)]).join();
  return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_$suffix';
}

List<Product> _initialProducts() {
  final now = DateTime.now().toIso8601String();
  final seed = <List<String>>[
    ['p1', 'خلطة اسبانية', 'أعلاف'],
    ['p2', 'بريقة سادة', 'أعلاف'],
    ['p3', 'خلطة جوارح', 'أعلاف'],
    ['p4', 'دخن', 'حبوب'],
    ['p5', 'قرطم', 'حبوب'],
    ['p6', 'علف قطط', 'قطط'],
    ['p7', 'علب قطط', 'قطط'],
  ];
  return seed
      .map((row) => Product(
            id: row[0],
            name: row[1],
            category: row[2],
            purchasePrice: 0,
            salePrice: 0,
            quantity: 0,
            minStock: 0,
            notes: '',
            createdAt: now,
          ))
      .toList();
}

/// Input shape for creating/updating a product (everything but id/createdAt).
class ProductInput {
  final String name;
  final String category;
  final double purchasePrice;
  final double salePrice;
  final double quantity;
  final double minStock;
  final String notes;
  const ProductInput({
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.minStock,
    this.notes = '',
  });
}

class SaleInput {
  final String productId;
  final double quantity;
  final double salePrice;
  final String date;
  final String notes;
  const SaleInput({
    required this.productId,
    required this.quantity,
    required this.salePrice,
    required this.date,
    this.notes = '',
  });
}

class PurchaseInput {
  final String productId;
  final double quantity;
  final double purchasePrice;
  final String supplier;
  final String date;
  final String notes;
  const PurchaseInput({
    required this.productId,
    required this.quantity,
    required this.purchasePrice,
    this.supplier = '',
    required this.date,
    this.notes = '',
  });
}

/// Central app state. This is a line-for-line port of ShopContext.tsx:
/// same storage key, same seed data, same stock-adjustment rules on
/// add/update/delete for sales and purchases.
class ShopState extends ChangeNotifier {
  List<Product> products = [];
  List<Sale> sales = [];
  List<Purchase> purchases = [];
  bool loading = true;

  ShopState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        final parsedProducts = (parsed['products'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        final parsedSales =
            (parsed['sales'] as List).map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
        final parsedPurchases = (parsed['purchases'] as List)
            .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
            .toList();

        const oldExampleNames = ['خلطة طيور استوائية', 'قفص متوسط أبيض', 'بذور دوار الشمس', 'فيتامين طيور'];
        const oldExampleOperationIds = ['s1', 's2', 's3', 'b1', 'b2', 'b3'];
        final isSeedOnly = parsedProducts.any((p) => oldExampleNames.contains(p.name)) ||
            [...parsedSales.map((s) => s.id), ...parsedPurchases.map((p) => p.id)]
                .any((id) => oldExampleOperationIds.contains(id));

        if (isSeedOnly) {
          products = _initialProducts();
          sales = [];
          purchases = [];
        } else {
          products = parsedProducts;
          sales = parsedSales;
          purchases = parsedPurchases;
        }
      } catch (_) {
        products = _initialProducts();
        sales = [];
        purchases = [];
      }
    } else {
      products = _initialProducts();
      sales = [];
      purchases = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (loading) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'products': products.map((p) => p.toJson()).toList(),
        'sales': sales.map((s) => s.toJson()).toList(),
        'purchases': purchases.map((p) => p.toJson()).toList(),
      }),
    );
  }

  void _commit() {
    notifyListeners();
    _persist();
  }

  // ---------------- Products ----------------

  void addProduct(ProductInput input) {
    products = [
      Product(
        id: _makeId('p'),
        name: input.name,
        category: input.category,
        purchasePrice: input.purchasePrice,
        salePrice: input.salePrice,
        quantity: input.quantity,
        minStock: input.minStock,
        notes: input.notes,
        createdAt: DateTime.now().toIso8601String(),
      ),
      ...products,
    ];
    _commit();
  }

  void updateProduct(String id, ProductInput input) {
    products = products
        .map((p) => p.id == id
            ? p.copyWith(
                name: input.name,
                category: input.category,
                purchasePrice: input.purchasePrice,
                salePrice: input.salePrice,
                quantity: input.quantity,
                minStock: input.minStock,
                notes: input.notes,
              )
            : p)
        .toList();
    _commit();
  }

  void deleteProduct(String id) {
    products = products.where((p) => p.id != id).toList();
    _commit();
  }

  // ---------------- Sales ----------------

  OpResult addSale(SaleInput input) {
    final product = products.where((p) => p.id == input.productId).cast<Product?>().firstWhere((_) => true, orElse: () => null);
    if (product == null) return const OpResult(false, 'اختر صنفًا صالحًا');
    if (input.quantity <= 0 || input.salePrice < 0) return const OpResult(false, 'تحقق من الكمية والسعر');
    if (product.quantity < input.quantity) {
      return OpResult(false, 'المخزون المتاح ${_fmtNum(product.quantity)} فقط');
    }
    final purchasePrice = product.purchasePrice;
    final sale = Sale(
      id: _makeId('s'),
      productId: input.productId,
      productName: product.name,
      quantity: input.quantity,
      salePrice: input.salePrice,
      purchasePrice: purchasePrice,
      total: input.quantity * input.salePrice,
      profit: input.quantity * (input.salePrice - purchasePrice),
      date: input.date,
      notes: input.notes,
    );
    sales = [sale, ...sales];
    products = products
        .map((p) => p.id == product.id ? p.copyWith(quantity: p.quantity - input.quantity) : p)
        .toList();
    _commit();
    return const OpResult(true);
  }

  OpResult updateSale(String id, SaleInput input) {
    final previous = sales.where((s) => s.id == id).cast<Sale?>().firstWhere((_) => true, orElse: () => null);
    final product = products.where((p) => p.id == input.productId).cast<Product?>().firstWhere((_) => true, orElse: () => null);
    if (previous == null || product == null) return const OpResult(false, 'تعذر العثور على العملية');
    final available = product.quantity + (previous.productId == product.id ? previous.quantity : 0);
    if (input.quantity <= 0 || available < input.quantity) {
      return OpResult(false, 'المخزون المتاح ${_fmtNum(available)} فقط');
    }
    final purchasePrice = product.purchasePrice;
    final next = Sale(
      id: id,
      productId: input.productId,
      productName: product.name,
      quantity: input.quantity,
      salePrice: input.salePrice,
      purchasePrice: purchasePrice,
      total: input.quantity * input.salePrice,
      profit: input.quantity * (input.salePrice - purchasePrice),
      date: input.date,
      notes: input.notes,
    );
    sales = sales.map((s) => s.id == id ? next : s).toList();
    products = products.map((p) {
      if (previous.productId == product.id && p.id == product.id) {
        return p.copyWith(quantity: p.quantity + previous.quantity - input.quantity);
      }
      if (p.id == previous.productId) return p.copyWith(quantity: p.quantity + previous.quantity);
      if (p.id == product.id) return p.copyWith(quantity: p.quantity - input.quantity);
      return p;
    }).toList();
    _commit();
    return const OpResult(true);
  }

  void deleteSale(String id) {
    final sale = sales.where((s) => s.id == id).cast<Sale?>().firstWhere((_) => true, orElse: () => null);
    if (sale == null) return;
    sales = sales.where((s) => s.id != id).toList();
    products = products
        .map((p) => p.id == sale.productId ? p.copyWith(quantity: p.quantity + sale.quantity) : p)
        .toList();
    _commit();
  }

  // ---------------- Purchases ----------------

  void addPurchase(PurchaseInput input) {
    final product = products.where((p) => p.id == input.productId).cast<Product?>().firstWhere((_) => true, orElse: () => null);
    if (product == null) return;
    final purchase = Purchase(
      id: _makeId('b'),
      productId: input.productId,
      productName: product.name,
      quantity: input.quantity,
      purchasePrice: input.purchasePrice,
      total: input.quantity * input.purchasePrice,
      supplier: input.supplier,
      date: input.date,
      notes: input.notes,
    );
    purchases = [purchase, ...purchases];
    products = products
        .map((p) => p.id == product.id
            ? p.copyWith(quantity: p.quantity + input.quantity, purchasePrice: input.purchasePrice)
            : p)
        .toList();
    _commit();
  }

  void updatePurchase(String id, PurchaseInput input) {
    final previous = purchases.where((p) => p.id == id).cast<Purchase?>().firstWhere((_) => true, orElse: () => null);
    final product = products.where((p) => p.id == input.productId).cast<Product?>().firstWhere((_) => true, orElse: () => null);
    if (previous == null || product == null) return;
    final next = Purchase(
      id: id,
      productId: input.productId,
      productName: product.name,
      quantity: input.quantity,
      purchasePrice: input.purchasePrice,
      total: input.quantity * input.purchasePrice,
      supplier: input.supplier,
      date: input.date,
      notes: input.notes,
    );
    purchases = purchases.map((p) => p.id == id ? next : p).toList();
    products = products.map((p) {
      if (previous.productId == product.id && p.id == product.id) {
        return p.copyWith(quantity: p.quantity - previous.quantity + input.quantity, purchasePrice: input.purchasePrice);
      }
      if (p.id == previous.productId) return p.copyWith(quantity: p.quantity - previous.quantity);
      if (p.id == product.id) {
        return p.copyWith(quantity: p.quantity + input.quantity, purchasePrice: input.purchasePrice);
      }
      return p;
    }).toList();
    _commit();
  }

  void deletePurchase(String id) {
    final purchase = purchases.where((p) => p.id == id).cast<Purchase?>().firstWhere((_) => true, orElse: () => null);
    if (purchase == null) return;
    purchases = purchases.where((p) => p.id != id).toList();
    products = products
        .map((p) => p.id == purchase.productId ? p.copyWith(quantity: max(0.0, p.quantity - purchase.quantity)) : p)
        .toList();
    _commit();
  }

  String _fmtNum(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}
