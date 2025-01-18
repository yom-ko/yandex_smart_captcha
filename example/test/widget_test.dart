import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yandex_smart_captcha/yandex_smart_captcha.dart';

import 'mock_webview_platform.dart';

void main() {
  final mockWebViewDependencies = MockWebViewDependencies();
  setUp(mockWebViewDependencies.init);

  testWidgets('Test', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOne);
    expect(find.byType(MyHomePage), findsOne);
    expect(find.byType(YandexSmartCaptcha), findsOne);

    final executeButton = find.widgetWithText(ElevatedButton, 'Execute');

    expect(executeButton, findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    await tester.tap(executeButton);

    final destroyButton = find.widgetWithText(ElevatedButton, 'Destroy');

    expect(destroyButton, findsOneWidget);

    await tester.pump(const Duration(seconds: 4));

    await tester.tap(destroyButton);

    await tester.pump(const Duration(seconds: 2));
  });
}
