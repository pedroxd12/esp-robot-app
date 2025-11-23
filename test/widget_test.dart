import 'package:flutter_test/flutter_test.dart';

import 'package:cuchau/main.dart';

void main() {
  testWidgets('LineBot Pro app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CuchauApp());

    // Verify that the connection screen is displayed
    expect(find.text('LineBot Pro'), findsOneWidget);
  });
}
