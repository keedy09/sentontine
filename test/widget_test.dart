import 'package:flutter_test/flutter_test.dart';
import 'package:sentontine/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login page is displayed
    expect(find.text('SenTontine'), findsOneWidget);
  });
}
