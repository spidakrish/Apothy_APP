// Basic Flutter widget test for Apothy app

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apothy/main.dart';

void main() {
  testWidgets('App loads and displays chat screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ApothyApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify the app loads (Chat is the default screen)
    expect(find.text('Apothy'), findsWidgets);
  });
}
