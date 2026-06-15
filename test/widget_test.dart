import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_buddy/main.dart';

void main() {
  testWidgets('renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('GYMBUDDY'), findsOneWidget);
    expect(find.text('Hemen Başla'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);

    final exception = tester.takeException();
    expect(exception == null || exception is NetworkImageLoadException, isTrue);
  });
}
