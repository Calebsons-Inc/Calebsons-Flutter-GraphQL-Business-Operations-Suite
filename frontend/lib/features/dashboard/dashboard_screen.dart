import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/inventory_item.dart';
import '../../models/order.dart';

/// High-level operational overview: order volume, revenue, and stock alerts.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.orders;
    final inventory = state.inventory;

    final openOrders =
        orders.where((o) => o.status != 'DELIVERED').length;
    final revenue = orders.fold<double>(0, (sum, o) => sum + o.total);
    final lowStock = inventory.where((i) => i.isLowStock).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              state.refreshOrders();
              state.refreshInventory();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            state.refreshOrders(),
            state.refreshInventory(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MetricRow(
              metrics: [
                _Metric(label: 'Orders', value: '${orders.length}'),
                _Metric(label: 'Open', value: '$openOrders'),
                _Metric(
                  label: 'Revenue',
                  value: '\$${revenue.toStringAsFixed(0)}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Low stock', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (state.loadingInventory && lowStock.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (lowStock.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('All inventory levels are healthy.'),
                ),
              )
            else
              ...lowStock.map(_LowStockTile.new),
            const SizedBox(height: 24),
            Text('Recent orders',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (state.loadingOrders && orders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...orders.take(3).map(_RecentOrderTile.new),
            if (state.lastError != null) ...[
              const SizedBox(height: 16),
              Text(
                state.lastError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metrics});
  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in metrics) ...[
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.label,
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(m.value,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ),
          ),
          if (m != metrics.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _LowStockTile extends StatelessWidget {
  const _LowStockTile(this.item);
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Colors.orange),
        title: Text(item.name),
        subtitle: Text('SKU ${item.sku}'),
        trailing: Text('${item.quantity} left'),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile(this.order);
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(order.customerName),
        subtitle: Text('${order.id} · ${order.status}'),
        trailing: Text('\$${order.total.toStringAsFixed(2)}'),
      ),
    );
  }
}
