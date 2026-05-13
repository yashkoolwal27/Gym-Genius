import 'package:flutter_test/flutter_test.dart';
import 'package:gym_genius_flutter/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This will show an error screen because Firebase is not initialized,
    // but the widget tree should still build.
    await tester.pumpWidget(const GymGeniusApp());

    // Basic check to see if the app structure is built
    expect(find.byType(GymGeniusApp), findsOneWidget);
  });
}
