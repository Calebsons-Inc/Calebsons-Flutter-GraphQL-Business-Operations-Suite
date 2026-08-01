import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/inventory_item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_chrome.dart';

/// Inventory levels per SKU with low-stock highlighting.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final inventory = state.inventory;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: state.refreshInventory,
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
                        title: 'Inventory',
                        subtitle: 'Quantities and pricing across every SKU.',
                        trailing:
                            RefreshChip(onPressed: state.refreshInventory),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (state.loadingInventory && inventory.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (inventory.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No inventory items.')),
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
                  itemCount: inventory.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Breakpoints.contentMax,
                      ),
                      child: FadeIn(
                        delay: Duration(milliseconds: 40 * i.clamp(0, 8)),
                        child: _InventoryRow(item: inventory[i]),
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

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final low = item.isLowStock;
    final tone = low ? AppColors.alert : AppColors.tealDeep;
    final soft = low ? AppColors.alertSoft : AppColors.mist;

    return InteractiveRow(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              low ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
              color: tone,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'SKU ${item.sku} · \$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: tone,
                    ),
              ),
              Text(
                low ? 'Low' : 'In stock',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
