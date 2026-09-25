class Product {
  final String id;
  final String name;
  final String category;
  final double purchasePrice;
  final double salePrice;
  final double quantity;
  final double minStock;
  final String notes;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.minStock,
    this.notes = '',
    required this.createdAt,
  });

  Product copyWith({
    String? name,
    String? category,
    double? purchasePrice,
    double? salePrice,
    double? quantity,
    double? minStock,
    String? notes,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'quantity': quantity,
        'minStock': minStock,
        'notes': notes,
        'createdAt': createdAt,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? '',
        purchasePrice: (json['purchasePrice'] as num).toDouble(),
        salePrice: (json['salePrice'] as num).toDouble(),
        quantity: (json['quantity'] as num).toDouble(),
        minStock: (json['minStock'] as num).toDouble(),
        notes: json['notes'] as String? ?? '',
        createdAt: json['createdAt'] as String,
      );
}

class Sale {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final double salePrice;
  final double purchasePrice;
  final double total;
  final double profit;
  final String date;
  final String notes;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.salePrice,
    required this.purchasePrice,
    required this.total,
    required this.profit,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'salePrice': salePrice,
        'purchasePrice': purchasePrice,
        'total': total,
        'profit': profit,
        'date': date,
        'notes': notes,
      };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        salePrice: (json['salePrice'] as num).toDouble(),
        purchasePrice: (json['purchasePrice'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        profit: (json['profit'] as num).toDouble(),
        date: json['date'] as String,
        notes: json['notes'] as String? ?? '',
      );
}

class Purchase {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final double purchasePrice;
  final double total;
  final String supplier;
  final String date;
  final String notes;

  Purchase({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.total,
    this.supplier = '',
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'purchasePrice': purchasePrice,
        'total': total,
        'supplier': supplier,
        'date': date,
        'notes': notes,
      };

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        purchasePrice: (json['purchasePrice'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        supplier: json['supplier'] as String? ?? '',
        date: json['date'] as String,
        notes: json['notes'] as String? ?? '',
      );
}

/// Result of an operation that can fail with a message (mirrors the
/// `{ ok, message }` return shape used by addSale/updateSale in the
/// original TypeScript context).
class OpResult {
  final bool ok;
  final String? message;
  const OpResult(this.ok, [this.message]);
}
