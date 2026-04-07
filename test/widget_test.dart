import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:exeos/main.dart';

void main() {
  testWidgets('renders exeOS home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ExeOsBootstrap(authAvailable: false));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
