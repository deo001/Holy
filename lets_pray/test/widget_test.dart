import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_pray/main.dart';

void main() {
  testWidgets('App loads and renders bottom navigation smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LetsPrayApp(),
      ),
    );

    // Verify bottom navigation bar is rendered
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
