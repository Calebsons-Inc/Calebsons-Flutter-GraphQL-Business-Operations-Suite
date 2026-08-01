import 'package:flutter/material.dart';

import '../../graphql/mutations.dart';
import '../../main.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_chrome.dart';

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

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(order.id),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: ContentWidth(
          child: ListView(
            children: [
              FadeIn(
                child: Text(
                  order.customerName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 6),
              FadeIn(
                delay: const Duration(milliseconds: 40),
                child: Text(
                  'Placed ${order.createdAt}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: InteractiveRow(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            StatusPill(status: order.status),
                          ],
                        ),
                      ),
                      if (_updating)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _statuses.contains(order.status)
                                ? order.status
                                : _statuses.first,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              for (final s in _statuses)
                                DropdownMenuItem(value: s, child: Text(s)),
                            ],
                            onChanged: (value) {
                              if (value != null) _updateStatus(order, value);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Line items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < order.items.length; i++) ...[
                FadeIn(
                  delay: Duration(milliseconds: 140 + (i * 40)),
                  child: InteractiveRow(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items[i].name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${order.items[i].sku} · qty ${order.items[i].quantity}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${order.items[i].price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                if (i != order.items.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 220),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
