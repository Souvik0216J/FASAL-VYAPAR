// models/grocery_item.dart
class GroceryItem {
  bool get isNearlyExpired {
    return expiryDate.isBefore(DateTime.now().add(Duration(days: 3)));
  }
  final String id;
  final String name;
  final int quantity;
  final String ripeness;
  final DateTime expiryDate; // hi hello
  final bool isSold;

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.ripeness,
    required this.expiryDate,
    this.isSold = false,
  });

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      ripeness: map['ripeness'] ?? '',
      expiryDate:
          DateTime.parse(map['expiryDate'] ?? DateTime.now().toIso8601String()),
      isSold: map['isSold'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'ripeness': ripeness,
      'expiryDate': expiryDate.toIso8601String(),
      'isSold': isSold,
    };
  }

  GroceryItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? ripeness,
    DateTime? expiryDate,
    bool? isSold,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      ripeness: ripeness ?? this.ripeness,
      expiryDate: expiryDate ?? this.expiryDate,
      isSold: isSold ?? this.isSold,
    );
  }
}
