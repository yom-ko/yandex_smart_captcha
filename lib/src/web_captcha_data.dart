// https://yandex.cloud/en/docs/smartcaptcha/concepts/widget-methods#methods

final class WebCaptcha {
  final String _clientKey;
  final bool _testMode;
  final String _language;
  final bool _invisible;
  final bool _hideShield;
  final String _shieldPosition;
  final bool _webView;

  late final String html;

  WebCaptcha({
    required String clientKey,
    bool testMode = false,
    String language = 'ru',
    bool invisible = false,
    bool hideShield = false,
    String shieldPosition = 'bottom-right',
    bool webView = true,
  })  : _clientKey = clientKey,
        _testMode = testMode,
        _language = language,
        _invisible = invisible,
        _hideShield = hideShield,
        _shieldPosition = shieldPosition,
        _webView = webView {
    html = '''
<!doctype html>
<html lang="$_language">

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title></title>
  <script
    src="https://smartcaptcha.yandexcloud.net/captcha.js?render=onload&onload=onLoadFunction"
    defer></script>
</head>

<body>
  <script>
    function onLoadFunction() {
      if (window.smartCaptcha) {
        const widgetId = window.smartCaptcha.render('captcha-container', {
          sitekey: '$_clientKey',
          test: $_testMode,
          webview: $_webView,
          hl: '$_language',
          invisible: $_invisible,
          hideShield: $_hideShield,
          shieldPosition: '$_shieldPosition',
          callback: resultCallback
        });

        window.smartCaptcha.subscribe(
          widgetId,
          'network-error',
          () => { window.flutter_inappwebview.callHandler('onNetworkError'); }
        );

        window.smartCaptcha.subscribe(
          widgetId,
          'javascript-error',
          () => { window.flutter_inappwebview.callHandler('onJavaScriptError'); }
        );

        window.smartCaptcha.subscribe(
          widgetId,
          'challenge-visible',
          () => { window.flutter_inappwebview.callHandler('onChallengeShown'); }
        );

        window.smartCaptcha.subscribe(
          widgetId,
          'challenge-hidden',
          () => { window.flutter_inappwebview.callHandler('onChallengeHidden'); }
        );

        window.flutter_inappwebview.callHandler('onCaptchaLoaded');
      } else {
        window.flutter_inappwebview.callHandler('onJavaScriptError');
      }
    }

    function resultCallback(token) {
      window.flutter_inappwebview.callHandler('onTokenReceived', token);
    }
  </script>
  <div id="captcha-container" style="height: 100px"></div>
</body>

</html>''';
  }
}
