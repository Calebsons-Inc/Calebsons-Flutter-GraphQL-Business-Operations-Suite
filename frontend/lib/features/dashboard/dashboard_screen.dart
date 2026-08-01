import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/inventory_item.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_chrome.dart';

/// High-level operational overview: order volume, revenue, and stock alerts.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.orders;
    final inventory = state.inventory;

    final openOrders = orders.where((o) => o.status != 'DELIVERED').length;
    final revenue = orders.fold<double>(0, (sum, o) => sum + o.total);
    final lowStock = inventory.where((i) => i.isLowStock).toList();
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.compact;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: () async {
          await Future.wait([
            state.refreshOrders(),
            state.refreshInventory(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    FadeIn(
                      child: PageHeader(
                        title: 'Dashboard',
                        subtitle: 'A live look at orders and stock health.',
                        trailing: RefreshChip(
                          onPressed: () {
                            state.refreshOrders();
                            state.refreshInventory();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeIn(
                      delay: const Duration(milliseconds: 60),
                      child: _MetricStrip(
                        wide: wide,
                        metrics: [
                          _Metric(label: 'Orders', value: '${orders.length}'),
                          _Metric(label: 'Open', value: '$openOrders'),
                          _Metric(
                            label: 'Revenue',
                            value: '\$${revenue.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeIn(
                      delay: const Duration(milliseconds: 120),
                      child: Text(
                        'Low stock',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.loadingInventory && lowStock.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (lowStock.isEmpty)
                      FadeIn(
                        delay: const Duration(milliseconds: 140),
                        child: InteractiveRow(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.okSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.ok,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All inventory levels are healthy.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...[
                        for (var i = 0; i < lowStock.length; i++) ...[
                          FadeIn(
                            delay: Duration(milliseconds: 140 + (i * 40)),
                            child: _LowStockRow(item: lowStock[i]),
                          ),
                          if (i != lowStock.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    const SizedBox(height: 32),
                    FadeIn(
                      delay: const Duration(milliseconds: 180),
                      child: Text(
                        'Recent orders',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.loadingOrders && orders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      for (final entry
                          in orders.take(3).toList().asMap().entries) ...[
                        FadeIn(
                          delay: Duration(
                            milliseconds: 200 + (entry.key * 40),
                          ),
                          child: _RecentOrderRow(order: entry.value),
                        ),
                        if (entry.key < orders.take(3).length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                    if (state.lastError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.lastError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.metrics, required this.wide});
  final List<_Metric> metrics;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final m in metrics) _MetricCell(metric: m),
    ];

    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i != children.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F6F6A), Color(0xFF134E4A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return InteractiveRow(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.alertSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: AppColors.alert,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'SKU ${item.sku}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${item.quantity} left',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.alert,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderRow extends StatelessWidget {
  const _RecentOrderRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return InteractiveRow(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      order.id,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    StatusPill(status: order.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${order.total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
