import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/inventory_item.dart';

/// Inventory levels per SKU with low-stock highlighting.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final inventory = state.inventory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.refreshInventory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.refreshInventory,
        child: state.loadingInventory && inventory.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: inventory.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) => _InventoryTile(item: inventory[i]),
              ),
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isLowStock
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          item.isLowStock ? Icons.warning_amber : Icons.inventory_2_outlined,
          color: color,
        ),
      ),
      title: Text(item.name),
      subtitle: Text('SKU ${item.sku} · \$${item.price.toStringAsFixed(2)}'),
      trailing: Text(
        '${item.quantity}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
