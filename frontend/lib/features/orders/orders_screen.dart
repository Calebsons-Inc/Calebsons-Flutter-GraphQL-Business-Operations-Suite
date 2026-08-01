import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_chrome.dart';
import 'order_details_screen.dart';

/// Browsable list of all orders.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.orders;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: state.refreshOrders,
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
                        title: 'Orders',
                        subtitle: 'Track fulfillment from pending to delivered.',
                        trailing: RefreshChip(onPressed: state.refreshOrders),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (state.loadingOrders && orders.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (orders.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No orders yet.')),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width <
                          Breakpoints.compact
                      ? 16
                      : MediaQuery.sizeOf(context).width < Breakpoints.medium
                          ? 24
                          : 32,
                ),
                sliver: SliverList.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Breakpoints.contentMax,
                      ),
                      child: FadeIn(
                        delay: Duration(milliseconds: 40 * i.clamp(0, 8)),
                        child: _OrderRow(order: orders[i]),
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return InteractiveRow(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailsScreen(orderId: order.id),
        ),
      ),
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
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(order.id, style: Theme.of(context).textTheme.bodySmall),
                    StatusPill(status: order.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
