// https://yandex.cloud/en/docs/smartcaptcha/concepts/widget-methods#methods

final class WebCaptcha {
  final String _clientKey;
  final bool _alwaysShowChallenge;
  final String _language;
  final bool _invisibleMode;
  final bool _hideDPNBadge;
  final String _dpnBadgePosition;
  final bool _webViewMode;

  late final String html;

  WebCaptcha({
    required String clientKey,
    bool alwaysShowChallenge = false,
    String language = 'ru',
    bool invisibleMode = false,
    bool hideDPNBadge = false,
    String dpnBadgePosition = 'bottom-right',
    bool webViewMode = true,
  })  : _clientKey = clientKey,
        _alwaysShowChallenge = alwaysShowChallenge,
        _language = language,
        _invisibleMode = invisibleMode,
        _hideDPNBadge = hideDPNBadge,
        _dpnBadgePosition = dpnBadgePosition,
        _webViewMode = webViewMode {
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
          test: $_alwaysShowChallenge,
          hl: '$_language',
          invisible: $_invisibleMode,
          hideShield: $_hideDPNBadge,
          shieldPosition: '$_dpnBadgePosition',
          webview: $_webViewMode,
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
        window.flutter_inappwebview.callHandler('onNetworkError');
      }
    }

    function resultCallback(token) {
      window.flutter_inappwebview.callHandler('onChallengeSolved', token);
    }
  </script>
  <div id="captcha-container" style="height: 100px"></div>
</body>

</html>''';
  }
}
