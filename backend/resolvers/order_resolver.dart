import 'dart:convert';
import 'dart:io';

/// Resolver for all Order-related GraphQL fields.
///
/// Reads from and writes to `backend/data/orders.json`, which acts as the
/// simulated database for this minimum working example.
class OrderResolver {
  OrderResolver(this.dataPath);

  final String dataPath;

  Future<List<Map<String, dynamic>>> _readAll() async {
    final file = File(dataPath);
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _writeAll(List<Map<String, dynamic>> orders) async {
    final file = File(dataPath);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(orders));
  }

  /// Query: getOrders
  Future<List<Map<String, dynamic>>> getOrders() async {
    return _readAll();
  }

  /// Query: getOrderById(id: ID!)
  Future<Map<String, dynamic>?> getOrderById(String id) async {
    final orders = await _readAll();
    for (final order in orders) {
      if (order['id'] == id) return order;
    }
    return null;
  }

  /// Mutation: updateOrderStatus(id: ID!, status: String!)
  Future<Map<String, dynamic>?> updateOrderStatus(
    String id,
    String status,
  ) async {
    final orders = await _readAll();
    Map<String, dynamic>? updated;
    for (final order in orders) {
      if (order['id'] == id) {
        order['status'] = status;
        updated = order;
        break;
      }
    }
    if (updated != null) {
      await _writeAll(orders);
    }
    return updated;
  }
}
