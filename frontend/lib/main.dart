import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/graphql_client.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/orders/orders_screen.dart';
import 'graphql/queries.dart';
import 'models/inventory_item.dart';
import 'models/order.dart';
import 'theme/app_theme.dart';
import 'widgets/app_chrome.dart';

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

  bool authenticated = false;
  bool loadingOrders = false;
  bool loadingInventory = false;
  String? lastError;

  void signIn() {
    authenticated = true;
    notifyListeners();
  }

  void signOut() {
    authenticated = false;
    notifyListeners();
  }

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
      title: 'Calebsons Flutter',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: state.authenticated
          ? const RootShell(key: ValueKey('app'))
          : const AuthScreen(key: ValueKey('auth')),
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

  static const _destinations = <_Dest>[
    _Dest(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _Dest(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _Dest(
      label: 'Inventory',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
  ];

  late final _screens = <Widget>[
    const DashboardScreen(),
    const OrdersScreen(),
    const InventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.medium;

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: wide
            ? Row(
                children: [
                  _BrandRail(
                    index: _index,
                    destinations: _destinations,
                    onSelect: (i) => setState(() => _index = i),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(_index),
                        child: _screens[_index],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const _MobileTopBar(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(_index),
                        child: _screens[_index],
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                ],
              ),
      ),
    );
  }
}

class _Dest {
  const _Dest({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _BrandRail extends StatelessWidget {
  const _BrandRail({
    required this.index,
    required this.destinations,
    required this.onSelect,
  });

  final int index;
  final List<_Dest> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.chalk.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calebsons',
            style: GoogleFonts.fraunces(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              height: 1.05,
            ),
          ),
          Text(
            'Flutter',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < destinations.length; i++) ...[
            _RailItem(
              label: destinations[i].label,
              icon: index == i
                  ? destinations[i].selectedIcon
                  : destinations[i].icon,
              selected: index == i,
              onTap: () => onSelect(i),
            ),
            if (i != destinations.length - 1) const SizedBox(height: 6),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: () => AppScope.of(context).signOut(),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign out'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calebsons',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Flutter',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => AppScope.of(context).signOut(),
              icon: const Icon(Icons.logout_rounded),
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.mist : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.tealDeep : AppColors.muted,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.tealDeep : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
