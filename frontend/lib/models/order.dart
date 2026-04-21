/// Represents a single line item inside an [Order].
class OrderItem {
  const OrderItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String sku;
  final String name;
  final int quantity;
  final double price;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      sku: json['sku'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}

/// Business order as exposed by the GraphQL API.
class Order {
  const Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String customerName;
  final String status;
  final double total;
  final String createdAt;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      items: rawItems.map(OrderItem.fromJson).toList(),
    );
  }

  Order copyWith({String? status}) => Order(
        id: id,
        customerName: customerName,
        status: status ?? this.status,
        total: total,
        createdAt: createdAt,
        items: items,
      );
}
