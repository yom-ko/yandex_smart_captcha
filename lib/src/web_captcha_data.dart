// https://yandex.cloud/en/docs/smartcaptcha/concepts/widget-methods#methods

final class WebCaptcha {
  final String _clientKey;
  final bool _alwaysShowChallenge;
  final String _language;
  final bool _invisibleMode;
  final bool _hideDPNBadge;
  final String _dpnBadgePosition;
  final bool _webViewMode;
  final double _initialContentScale;
  final String _userScalableContent;
  final double _maximumContentScale;

  late final String html;

  WebCaptcha({
    required String clientKey,
    required bool alwaysShowChallenge,
    required String language,
    required bool invisibleMode,
    required bool hideDPNBadge,
    required String dpnBadgePosition,
    required bool webViewMode,
    required double initialContentScale,
    required String userScalableContent,
    required double maximumContentScale,
  })  : _clientKey = clientKey,
        _alwaysShowChallenge = alwaysShowChallenge,
        _language = language,
        _invisibleMode = invisibleMode,
        _hideDPNBadge = hideDPNBadge,
        _dpnBadgePosition = dpnBadgePosition,
        _webViewMode = webViewMode,
        _initialContentScale = initialContentScale,
        _userScalableContent = userScalableContent,
        _maximumContentScale = maximumContentScale {
    html = '''
<!doctype html>
<html lang="$_language">

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="
  width=device-width,
  initial-scale=$_initialContentScale,
  user-scalable=$_userScalableContent,
  maximum-scale=$_maximumContentScale" />
  <title></title>
  <script src="https://smartcaptcha.yandexcloud.net/captcha.js?render=onload&onload=onLoadFunction"
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
