import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'src/captcha_web_page.dart';

export 'package:yandex_smart_captcha/yandex_smart_captcha.dart';

enum CaptchaUILanguage {
  ru,
  en,
  be,
  kk,
  tt,
  uk,
  uz,
  tr,
}

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

final class CaptchaConfig {
  /// A client key specified in the application hosting the widget.
  final String siteKey;

  /// If true, the user will ALWAYS see a challenge! Use this option only for debugging and testing.
  final bool testMode;

  /// If true, the captcha will run in WebView mode, improving the accuracy of assessing captcha
  /// completion on mobile devices.
  final bool webView;

  /// The language for the captcha widget UI: `ru` | `en` | `be` | `kk` | `tt` | `uk` | `uz` | `tr`
  final CaptchaUILanguage language;

  /// If true, the captcha will run in invisible mode — without the "I’m not a robot" button on the page.
  /// Only users whose requests are deemed suspicious by SmartCaptcha will see the challenge.
  final bool invisible;

  /// If true and invisible mode is enabled, the shield with a link to the Data Processing document will be hidden.
  final bool hideShield;

  /// If invisible mode is enabled, specifies the position of the shield with a link to the Data Processing document:
  /// `top-left` | `center-left` | `bottom-left` | `top-right` | `center-right` | `bottom-right`.
  final CaptchaShieldPosition shieldPosition;

  /// The background color of the captcha widget.
  final Color? backgroundColor;

  const CaptchaConfig({
    required this.siteKey,
    this.testMode = false,
    this.webView = true,
    this.language = CaptchaUILanguage.ru,
    this.invisible = false,
    this.hideShield = false,
    this.shieldPosition = CaptchaShieldPosition.bottomRight,
    this.backgroundColor,
  });
}

final class CaptchaController {
  InAppWebViewController? _inAppWebViewController;
  VoidCallback? _onControllerReady;

  /// Returns true if the controller is ready.
  bool get isReady => _inAppWebViewController != null;

  /// Starts user validation and is commonly used to trigger the invisible CAPTCHA test
  /// during specific events, such as when the user clicks the Submit button on a form.
  Future<dynamic> execute() async {
    return _inAppWebViewController?.evaluateJavascript(
        source: 'window.smartCaptcha.execute()');
  }

  /// Removes CAPTCHA widgets and any listeners they create.
  Future<dynamic> destroy() async {
    return _inAppWebViewController?.evaluateJavascript(
        source: 'window.smartCaptcha.destroy()');
  }

  /// Sets a callback to be called when the controller is ready.
  // ignore: use_setters_to_change_properties
  void setReadyCallback(VoidCallback readyCallback) {
    _onControllerReady = readyCallback;
  }

  void _setController(InAppWebViewController controller) {
    _inAppWebViewController = controller;
    _onControllerReady?.call();
  }
}

class YandexSmartCaptcha extends StatefulWidget {
  /// The configuration for the CAPTCHA widget.
  final CaptchaConfig config;

  /// The controller for the CAPTCHA widget.
  final CaptchaController? controller;

  /// Called when the CAPTCHA challenge is shown.
  final VoidCallback? onChallengeShown;

  /// Called when the CAPTCHA challenge is hidden.
  final VoidCallback? onChallengeHidden;

  /// Called when a network error occurs.
  final VoidCallback? onNetworkError;

  /// Called when a JavaScript error occurs.
  final VoidCallback? onJavaScriptError;

  /// Called when a token is received after a successful CAPTCHA test is completed.
  final Function(String) onTokenReceived;

  /// Called when a navigation request is made. To block the request, return false from the callback
  /// (otherwise, return true).
  final bool Function(String url)? onNavigationRequest;

  /// A widget to display while the CAPTCHA is loading.
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
  late final CaptchaWebPage _captchaWebPage;
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
    _captchaWebPage = CaptchaWebPage(
      siteKey: config.siteKey,
      testMode: config.testMode,
      webView: config.webView,
      language: config.language.name,
      invisible: config.invisible,
      hideShield: config.hideShield,
      shieldPosition: config.shieldPosition.id,
    );
  }

  @override
  void dispose() {
    _captchaController?._inAppWebViewController?.dispose();
    super.dispose();
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
          initialData: InAppWebViewInitialData(data: _captchaWebPage.data),
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
            debugPrint('YandexSmartCaptcha js console message:$consoleMessage');
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
