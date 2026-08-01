import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/auth_screen.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App boots on the auth screen', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      AppScope(state: state, child: const CalebsonsApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Business Operations Suite'), findsOneWidget);
    expect(find.text('Sign in to manage orders and inventory'), findsOneWidget);
    expect(find.text(DemoAuth.email), findsWidgets);
    expect(find.text(DemoAuth.password), findsWidgets);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('Demo credentials sign in to the Dashboard', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      AppScope(state: state, child: const CalebsonsApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Inventory'), findsWidgets);
  });
}
