import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafeteria_escom/app.dart';

void main() {
  testWidgets('CafeteriaApp initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CafeteriaApp(),
      ),
    );

    // Let the splash screen timer and animations settle
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify CafeteriaApp builds successfully
    expect(find.byType(CafeteriaApp), findsOneWidget);
  });
}
