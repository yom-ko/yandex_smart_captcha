# Yandex SmartCaptcha

[![Pub Version](https://img.shields.io/badge/dynamic/json?color=e97436&label=pub.dev&query=$.latest.version&url=https://pub.dev/api/packages/yandex_smart_captcha&style=flat)](https://pub.dev/packages/yandex_smart_captcha) [![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg?style=flat)](https://pub.dev/documentation/yandex_smart_captcha/latest) [![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg?style=flat)](https://opensource.org/licenses/MIT)

This package makes it easy to integrate a Yandex SmartCaptcha into Flutter mobile apps. To learn more about the Yandex SmartCaptcha service, visit its [official page](https://yandex.cloud/en/services/smartcaptcha).

This package was inspired by [flutter_yandex_smartcaptcha](https://pub.dev/packages/flutter_yandex_smartcaptcha), but it offers several improvements, including bug fixes, slightly better performance, enhanced documentation, and a much [cleaner API](https://pub.dev/documentation/yandex_smart_captcha/latest/yandex_smart_captcha).

## Motivation

One day at work, I urgently needed to integrate a Yandex CAPTCHA into a mobile app, and the `flutter_yandex_smartcaptcha` package came to the rescue. However, I discovered a serious bug and reported it to the author. When they didn’t respond, I decided to create a similar package myself and learn how to publish packages on pub.dev in the process. The end of the magnificent story.

## Screenshots

1. SmartCaptcha in a simple test screen:

<div>
  <img
    src="https://raw.githubusercontent.com/yom-ko/yandex_smart_captcha/refs/heads/main/assets/images/screen_1.webp"
    alt="The initial state of the Yandex SmartCaptcha container with the 'I’m not a robot' checkbox."
    width="250">
  <img
    src="https://raw.githubusercontent.com/yom-ko/yandex_smart_captcha/refs/heads/main/assets/images/screen_2.webp"
    alt="The initial state of the Yandex SmartCaptcha pop-up, featuring a challenge for the user to solve."
    width="250">
  <img
    src="https://raw.githubusercontent.com/yom-ko/yandex_smart_captcha/refs/heads/main/assets/images/screen_3.webp"
    alt="The state of the Yandex SmartCaptcha container with the 'I’m not a robot' box checked, after the user successfully solved the challenge."
    width="250">
</div><br/>

2. SmartCaptcha in a real-world application:

<div>
  <img
    src="https://raw.githubusercontent.com/yom-ko/yandex_smart_captcha/refs/heads/main/assets/images/screen_laz_1.webp"
    alt="The initial state of the Yandex SmartCaptcha container with the 'I’m not a robot' checkbox, as seen in a real-world application."
    width="250">
  <img
    src="https://raw.githubusercontent.com/yom-ko/yandex_smart_captcha/refs/heads/main/assets/images/screen_laz_2.webp"
    alt="The initial state of the Yandex SmartCaptcha pop-up, featuring a challenge for the user to solve in a real-world application."
    width="250">
</div>
