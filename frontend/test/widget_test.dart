import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App boots and shows the Dashboard tab', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      AppScope(state: state, child: const CalebsonsApp()),
    );
    await tester.pump();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Inventory'), findsWidgets);
  });
}
