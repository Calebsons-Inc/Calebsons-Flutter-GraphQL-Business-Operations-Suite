import 'package:flutter/material.dart';

import '../../graphql/mutations.dart';
import '../../main.dart';
import '../../models/order.dart';

/// Detail view for a single order, with status update action.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  static const _statuses = [
    'PENDING',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
  ];
  bool _updating = false;

  Future<void> _updateStatus(Order order, String status) async {
    final state = AppScope.of(context);
    setState(() => _updating = true);
    try {
      final data = await state.client.query(
        updateOrderStatusMutation,
        variables: {'id': order.id, 'status': status},
      );
      final updated = data['updateOrderStatus'] as Map<String, dynamic>?;
      if (updated != null) {
        state.replaceOrder(order.copyWith(status: updated['status'] as String));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final order = state.orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => Order(
        id: widget.orderId,
        customerName: 'Unknown',
        status: 'UNKNOWN',
        total: 0,
        createdAt: '',
        items: const [],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(order.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(order.customerName,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Placed ${order.createdAt}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Status: ${order.status}'),
              const Spacer(),
              if (_updating)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                DropdownButton<String>(
                  value: _statuses.contains(order.status)
                      ? order.status
                      : _statuses.first,
                  items: [
                    for (final s in _statuses)
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (value) {
                    if (value != null) _updateStatus(order, value);
                  },
                ),
            ],
          ),
          const Divider(height: 32),
          Text('Line items',
              style: Theme.of(context).textTheme.titleMedium),
          for (final item in order.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.name),
              subtitle: Text('${item.sku} · qty ${item.quantity}'),
              trailing: Text('\$${item.price.toStringAsFixed(2)}'),
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
