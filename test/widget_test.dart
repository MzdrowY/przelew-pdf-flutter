import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:przelew_pdf/app.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PrzelewPdfApp()),
    );
    expect(find.text('Polecenie przelewu PDF'), findsWidgets);
  });
}
