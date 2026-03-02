import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/helpers/service_locator.dart';

void main() {
  setUpAll(() {
    setupServiceLocator();
  });

  testWidgets('Login screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BitBrainsApp());
    await tester.pumpAndSettle(); // Wait for navigation

    // Verify that our Login screen is shown.
    expect(find.text('BitBrains'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
