/// A single inventory record as returned by `getInventory`.
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
  });

  final String id;
  final String name;
  final String sku;
  final int quantity;
  final double price;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }

  bool get isLowStock => quantity < 10;
}
