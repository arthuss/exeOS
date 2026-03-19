import 'package:flutter_test/flutter_test.dart';

import 'package:exeos/main.dart';

void main() {
  testWidgets('renders exeOS home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ExeOsBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('exeOS'), findsWidgets);
    expect(find.text('Web catalog for animated wallpapers'), findsOneWidget);
    expect(find.text('Full catalog'), findsOneWidget);
    expect(find.text('Preview catalog'), findsOneWidget);
  });
}
