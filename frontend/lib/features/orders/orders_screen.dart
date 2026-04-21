import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/order.dart';
import 'order_details_screen.dart';

/// Browsable list of all orders.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.refreshOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.refreshOrders,
        child: state.loadingOrders && orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, i) => _OrderCard(order: orders[i]),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(order.customerName),
        subtitle: Text('${order.id} · ${order.status}'),
        trailing: Text('\$${order.total.toStringAsFixed(2)}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailsScreen(orderId: order.id),
          ),
        ),
      ),
    );
  }
}
