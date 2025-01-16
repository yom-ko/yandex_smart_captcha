import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'src/web_captcha_data.dart';

export 'package:yandex_smart_captcha/yandex_smart_captcha.dart';

/// The supported languages for the Web SmartCaptcha widget's UI.
enum CaptchaUILanguage {
  /// Russian
  ru,

  /// English
  en,

  /// Belarusian
  be,

  /// Kazakh
  kk,

  /// Tatar
  tt,

  /// Ukrainian
  uk,

  /// Uzbek
  uz,

  /// Turkish
  tr,
}

/// The supported positions for the shield that includes a link
/// to the Data Processing document (when invisible mode is enabled).
enum CaptchaShieldPosition {
  topLeft('top-left'),
  centerLeft('center-left'),
  bottomLeft('bottom-left'),
  topRight('top-right'),
  centerRight('center-right'),
  bottomRight('bottom-right');

  const CaptchaShieldPosition(this.id);

  final String id;

  @override
  String toString() => id;
}

/// The configuration for the [YandexSmartCaptcha] widget.
/// Most options apply to the underlying Web SmartCaptcha hosted in the WebView.
/// For more information, see the [Yandex SmartCaptcha documentation](https://yandex.cloud/en/docs/smartcaptcha/concepts/widget-methods#methods).
final class CaptchaConfig {
  /// A client-side key passed to the underlying Web SmartCaptcha widget.<br />
  /// Corresponding JavaScript parameter – `sitekey`.
  final String siteKey;

  /// If true, the user will ALWAYS see a challenge. Use this option only for debugging or testing.<br />
  /// Corresponding JavaScript parameter – `test`.
  final bool testMode;

  /// The language of the Web SmartCaptcha widget UI. For some languages, this setting may also determine
  /// the CAPTCHA challenge language (typically switching it to English).<br />
  /// Supported values: `ru` | `en` | `be` | `kk` | `tt` | `uk` | `uz` | `tr`<br />
  /// Corresponding JavaScript parameter – `hl`.
  final CaptchaUILanguage language;

  /// If true, the CAPTCHA runs in invisible mode – without the 'I’m not a robot' button on the page.
  /// Only users whose requests are deemed suspicious by Yandex SmartCaptcha will see a challenge.<br />
  /// Corresponding JavaScript parameter – `invisible`.
  final bool invisible;

  /// If true and invisible mode is enabled, the shield with a link to the Data Processing document is hidden.
  /// WARNING: You MUST inform users that their data is processed by SmartCaptcha. If you hide the notice shield,
  /// ensure there is another way to notify users about data processing.<br />
  /// Corresponding JavaScript parameter – `hideShield`.
  final bool hideShield;

  /// If invisible mode is enabled, this option specifies the position of the shield with a link to the Data Processing document.<br />
  /// Supported values: `top-left` | `center-left` | `bottom-left` | `top-right` | `center-right` | `bottom-right`.<br />
  /// Corresponding JavaScript parameter – `shieldPosition`.
  final CaptchaShieldPosition shieldPosition;

  /// If true, the CAPTCHA runs in special WebView mode, improving the accuracy of the test assessment on mobile
  /// devices. This package is designed for Flutter, so this option should typically be set to `true`.<br />
  /// Corresponding JavaScript parameter – `webview`.
  final bool webView;

  /// The background color of the YandexSmartCaptcha widget.
  final Color? backgroundColor;

  const CaptchaConfig({
    required this.siteKey,
    this.testMode = false,
    this.language = CaptchaUILanguage.ru,
    this.invisible = false,
    this.hideShield = false,
    this.shieldPosition = CaptchaShieldPosition.bottomRight,
    this.webView = true,
    this.backgroundColor,
  });
}

/// The controller for the [YandexSmartCaptcha] widget.
/// It is primarily designed to manage the underlying Web SmartCaptcha hosted in the WebView.
final class CaptchaController {
  InAppWebViewController? _inAppWebViewController;
  VoidCallback? _onControllerReady;

  /// Returns true if the underlying WebView controller is fully initialized and ready.
  bool get isReady => _inAppWebViewController != null;

  /// Starts user validation and is commonly used to trigger the invisible CAPTCHA test
  /// during events like when the user clicks the submit button on a form.
  Future<dynamic> execute() async {
    return _inAppWebViewController?.evaluateJavascript(
        source: 'window.smartCaptcha.execute()');
  }

  /// Removes the Web SmartCaptcha JavaScript widgets hosted in the WebView,
  /// along with any listeners they create.
  Future<dynamic> destroy() async {
    return _inAppWebViewController?.evaluateJavascript(
        source: 'window.smartCaptcha.destroy()');
  }

  /// Sets a callback to be invoked when the underlying WebView controller is ready.
  // ignore: use_setters_to_change_properties
  void setReadyCallback(VoidCallback readyCallback) {
    _onControllerReady = readyCallback;
  }

  void _setController(InAppWebViewController controller) {
    _inAppWebViewController = controller;
    _onControllerReady?.call();
  }
}

/// The Flutter widget for Yandex SmartCaptcha.
/// It essentially wraps the WebView that executes the Web SmartCaptcha HTML/JavaScript code.
class YandexSmartCaptcha extends StatefulWidget {
  /// The configuration for the [YandexSmartCaptcha] widget.
  final CaptchaConfig config;

  /// The controller for the [YandexSmartCaptcha] widget.
  final CaptchaController? controller;

  /// Called when the CAPTCHA challenge popup is shown.
  final VoidCallback? onChallengeShown;

  /// Called when the CAPTCHA challenge popup is hidden.
  final VoidCallback? onChallengeHidden;

  /// Called when a network error is encountered.
  final VoidCallback? onNetworkError;

  /// Called when a JavaScript error is encountered.
  final VoidCallback? onJavaScriptError;

  /// Called when a token is received after the user successfully completes a CAPTCHA test.
  /// The callback receives the token string as an argument. WARNING: In rare cases, if something goes
  /// completely wrong, the string may be empty, so check accordingly.
  final Function(String token) onTokenReceived;

  /// Called when a navigation request is made in the underlying WebView. Return `false` from the callback
  /// to block the request; otherwise, return `true` to allow it.
  final bool Function(String url)? onNavigationRequest;

  /// A widget to display while the Web SmartCaptcha is loading.
  final Widget? loadingIndicator;

  const YandexSmartCaptcha({
    required this.config,
    required this.onTokenReceived,
    this.controller,
    this.onChallengeHidden,
    this.onChallengeShown,
    this.onNetworkError,
    this.onJavaScriptError,
    this.onNavigationRequest,
    this.loadingIndicator,
    super.key,
  });

  @override
  State<YandexSmartCaptcha> createState() => _YandexSmartCaptchaState();
}

class _YandexSmartCaptchaState extends State<YandexSmartCaptcha> {
  late final WebCaptcha _webCaptcha;
  late final CaptchaController? _captchaController;

  final _captchaLoaded = ValueNotifier<bool>(false);

  final settings = InAppWebViewSettings(
    transparentBackground: true,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
  );

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    _captchaController = widget.controller;
    _webCaptcha = WebCaptcha(
      siteKey: config.siteKey,
      testMode: config.testMode,
      language: config.language.name,
      invisible: config.invisible,
      hideShield: config.hideShield,
      shieldPosition: config.shieldPosition.id,
      webView: config.webView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.config.backgroundColor != null)
          SizedBox.expand(
            child: ColoredBox(color: widget.config.backgroundColor!),
          ),
        if (widget.loadingIndicator != null) ...[
          ValueListenableBuilder(
            valueListenable: _captchaLoaded,
            builder: (_, loaded, __) =>
                loaded ? const SizedBox.shrink() : widget.loadingIndicator!,
          ),
        ],
        InAppWebView(
          initialSettings: settings,
          initialData: InAppWebViewInitialData(data: _webCaptcha.html),
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url.toString();
            final callbackResult =
                widget.onNavigationRequest?.call(url) ?? true;
            return callbackResult
                ? NavigationActionPolicy.ALLOW
                : NavigationActionPolicy.CANCEL;
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint(
                'YandexSmartCaptcha JS console message: $consoleMessage');
          },
          onWebViewCreated: (controller) {
            _captchaController?._setController(controller);

            controller
              ..addJavaScriptHandler(
                  handlerName: 'onNetworkError',
                  callback: (args) {
                    widget.onNetworkError?.call();
                  })
              ..addJavaScriptHandler(
                  handlerName: 'onJavaScriptError',
                  callback: (args) {
                    widget.onJavaScriptError?.call();
                  })
              ..addJavaScriptHandler(
                  handlerName: 'onChallengeShown',
                  callback: (args) {
                    widget.onChallengeShown?.call();
                  })
              ..addJavaScriptHandler(
                  handlerName: 'onChallengeHidden',
                  callback: (args) {
                    widget.onChallengeHidden?.call();
                  })
              ..addJavaScriptHandler(
                  handlerName: 'onCaptchaLoaded',
                  callback: (args) {
                    _captchaLoaded.value = true;
                  })
              ..addJavaScriptHandler(
                  handlerName: 'onTokenReceived',
                  callback: (args) {
                    final maybeToken =
                        args.isNotEmpty ? args.first.toString() : '';
                    widget.onTokenReceived.call(maybeToken);
                  });
          },
        ),
      ],
    );
  }
}
