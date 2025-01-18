import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:yandex_smart_captcha/yandex_smart_captcha.dart';

void main() {
  patrolTest('Full test', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    expect($(MyApp), findsOne);
    expect($(MyHomePage), findsOne);
    expect($(YandexSmartCaptcha), findsOne);

    final executeButton = $('Execute');

    expect(executeButton, findsOneWidget);

    await $.pump(const Duration(seconds: 2));

    await executeButton.tap();

    final destroyButton = $('Destroy');

    expect(destroyButton, findsOneWidget);

    await $.pump(const Duration(seconds: 4));

    await destroyButton.tap();

    await $.pump(const Duration(seconds: 2));
  });
}
