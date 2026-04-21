import 'package:flutter/material.dart';

import 'core/graphql_client.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/orders/orders_screen.dart';
import 'graphql/queries.dart';
import 'models/inventory_item.dart';
import 'models/order.dart';

/// Root ChangeNotifier that holds the GraphQL client and cached data.
///
/// Kept intentionally small: screens read from here via [ListenableBuilder]
/// and call [refreshOrders] / [refreshInventory] to repopulate.
class AppState extends ChangeNotifier {
  AppState({GraphQLClient? client})
      : client = client ?? GraphQLClient(backend: GraphQLBackend.mock);

  final GraphQLClient client;

  List<Order> orders = const [];
  List<InventoryItem> inventory = const [];

  bool loadingOrders = false;
  bool loadingInventory = false;
  String? lastError;

  Future<void> refreshOrders() async {
    loadingOrders = true;
    lastError = null;
    notifyListeners();
    try {
      final data = await client.query(getOrdersQuery);
      final list = (data['getOrders'] as List).cast<Map<String, dynamic>>();
      orders = list.map(Order.fromJson).toList();
    } catch (e) {
      lastError = e.toString();
    } finally {
      loadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> refreshInventory() async {
    loadingInventory = true;
    lastError = null;
    notifyListeners();
    try {
      final data = await client.query(getInventoryQuery);
      final list = (data['getInventory'] as List).cast<Map<String, dynamic>>();
      inventory = list.map(InventoryItem.fromJson).toList();
    } catch (e) {
      lastError = e.toString();
    } finally {
      loadingInventory = false;
      notifyListeners();
    }
  }

  void replaceOrder(Order updated) {
    orders = [
      for (final o in orders) if (o.id == updated.id) updated else o,
    ];
    notifyListeners();
  }
}

/// Lightweight InheritedWidget so screens can reach [AppState] without any
/// third-party state management package.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this widget.');
    return scope!.notifier!;
  }
}

void main() {
  final state = AppState();
  // Warm the caches so screens show content immediately.
  state.refreshOrders();
  state.refreshInventory();

  runApp(AppScope(state: state, child: const CalebsonsApp()));
}

class CalebsonsApp extends StatelessWidget {
  const CalebsonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calebsons Business Operations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)),
        useMaterial3: true,
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    OrdersScreen(),
    InventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
        ],
      ),
    );
  }
}
