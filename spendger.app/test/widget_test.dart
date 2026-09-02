import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendger/app/app.dart';

void main() {
  testWidgets('Spendger app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpendgerApp(),
      ),
    );

    // Initial splash screen renders SPENDGER
    expect(find.text('SPENDGER'), findsOneWidget);

    // Fast-forward animation & timer
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify main shell renders
    expect(find.text('Spendger'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
  });
}
