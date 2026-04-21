import 'dart:convert';
import 'dart:io';

/// Resolver for all InventoryItem-related GraphQL fields.
///
/// Reads from `backend/data/inventory.json`.
class InventoryResolver {
  InventoryResolver(this.dataPath);

  final String dataPath;

  Future<List<Map<String, dynamic>>> _readAll() async {
    final file = File(dataPath);
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Query: getInventory
  Future<List<Map<String, dynamic>>> getInventory() async {
    return _readAll();
  }
}
