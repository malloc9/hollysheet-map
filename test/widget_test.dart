import 'package:flutter_test/flutter_test.dart';

import 'package:holysheet_map/app/app.dart';

void main() {
  testWidgets('App widget can be instantiated', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
