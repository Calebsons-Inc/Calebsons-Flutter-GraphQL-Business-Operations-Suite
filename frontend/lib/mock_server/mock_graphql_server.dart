/// In-memory mock implementation of the backend GraphQL API.
///
/// This lets the Flutter app run end-to-end without starting a real server,
/// which is useful for development, widget tests, and offline demos. The
/// mock honours the exact same operations as a real GraphQL backend.
class MockGraphQLServer {
  MockGraphQLServer._();

  static final MockGraphQLServer instance = MockGraphQLServer._();

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-1001',
      'customerName': 'Acme Industrial Supply',
      'status': 'PENDING',
      'total': 4280.50,
      'createdAt': '2026-04-12T14:02:00Z',
      'items': [
        {'sku': 'SKU-100', 'name': 'Industrial Bearing Kit', 'quantity': 12, 'price': 220.00},
        {'sku': 'SKU-204', 'name': 'Lubricant Drum 55gal', 'quantity': 2, 'price': 820.25},
      ],
    },
    {
      'id': 'ORD-1002',
      'customerName': 'Northside Manufacturing',
      'status': 'SHIPPED',
      'total': 1899.99,
      'createdAt': '2026-04-14T09:17:00Z',
      'items': [
        {'sku': 'SKU-310', 'name': 'CNC Tooling Set', 'quantity': 1, 'price': 1899.99},
      ],
    },
    {
      'id': 'ORD-1003',
      'customerName': 'Harbor Freight Dynamics',
      'status': 'PROCESSING',
      'total': 655.00,
      'createdAt': '2026-04-18T18:45:00Z',
      'items': [
        {'sku': 'SKU-100', 'name': 'Industrial Bearing Kit', 'quantity': 1, 'price': 220.00},
        {'sku': 'SKU-415', 'name': 'Safety Glove Pack', 'quantity': 29, 'price': 15.00},
      ],
    },
    {
      'id': 'ORD-1004',
      'customerName': 'Vertex Aerospace',
      'status': 'DELIVERED',
      'total': 12400.00,
      'createdAt': '2026-04-02T11:00:00Z',
      'items': [
        {'sku': 'SKU-501', 'name': 'Precision Gauge', 'quantity': 4, 'price': 3100.00},
      ],
    },
  ];

  final List<Map<String, dynamic>> _inventory = [
    {'id': 'INV-100', 'name': 'Industrial Bearing Kit', 'sku': 'SKU-100', 'quantity': 48, 'price': 220.00},
    {'id': 'INV-204', 'name': 'Lubricant Drum 55gal', 'sku': 'SKU-204', 'quantity': 9, 'price': 820.25},
    {'id': 'INV-310', 'name': 'CNC Tooling Set', 'sku': 'SKU-310', 'quantity': 3, 'price': 1899.99},
    {'id': 'INV-415', 'name': 'Safety Glove Pack', 'sku': 'SKU-415', 'quantity': 420, 'price': 15.00},
    {'id': 'INV-501', 'name': 'Precision Gauge', 'sku': 'SKU-501', 'quantity': 2, 'price': 3100.00},
    {'id': 'INV-620', 'name': 'Hydraulic Hose 10ft', 'sku': 'SKU-620', 'quantity': 76, 'price': 88.40},
    {'id': 'INV-735', 'name': 'Pneumatic Regulator', 'sku': 'SKU-735', 'quantity': 14, 'price': 245.00},
  ];

  /// Executes a GraphQL document using the same dispatch rules as a real
  /// server: the top-level field name is extracted and variables carry args.
  Future<Map<String, dynamic>> execute(
    String query,
    Map<String, dynamic> variables,
  ) async {
    // Simulate network latency so loading states exercise the UI.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final fieldName = _extractTopLevelField(query);
    switch (fieldName) {
      case 'getOrders':
        return {
          'data': {'getOrders': List<Map<String, dynamic>>.from(_orders)},
        };
      case 'getOrderById':
        final id = variables['id'] as String?;
        final match = _orders.firstWhere(
          (o) => o['id'] == id,
          orElse: () => <String, dynamic>{},
        );
        return {
          'data': {'getOrderById': match.isEmpty ? null : match},
        };
      case 'getInventory':
        return {
          'data': {'getInventory': List<Map<String, dynamic>>.from(_inventory)},
        };
      case 'updateOrderStatus':
        final id = variables['id'] as String?;
        final status = variables['status'] as String?;
        Map<String, dynamic>? updated;
        for (final order in _orders) {
          if (order['id'] == id) {
            order['status'] = status;
            updated = order;
            break;
          }
        }
        return {
          'data': {'updateOrderStatus': updated},
        };
      default:
        return {
          'errors': [
            {'message': 'Unknown field: $fieldName'},
          ],
        };
    }
  }

  String? _extractTopLevelField(String query) {
    final match = RegExp(r'\{\s*([A-Za-z_][A-Za-z0-9_]*)').firstMatch(query);
    return match?.group(1);
  }
}
