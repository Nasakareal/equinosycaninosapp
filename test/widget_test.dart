import 'package:flutter_test/flutter_test.dart';

import 'package:equinos_caninos_app/main.dart';

void main() {
  testWidgets('boots the app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
