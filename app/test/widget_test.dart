import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searlo_cafe/app.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SearloCafeApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Searlo Cafe'), findsOneWidget);
  });
}
