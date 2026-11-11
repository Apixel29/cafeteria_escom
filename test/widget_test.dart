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

    // Avanzar el tiempo para resolver la animación y el temporizador del SplashScreen
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    // Verificar que CafeteriaApp se monta exitosamente
    expect(find.byType(CafeteriaApp), findsOneWidget);
  });
}
