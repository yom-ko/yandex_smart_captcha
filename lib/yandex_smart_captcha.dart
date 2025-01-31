import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'src/web_captcha_data.dart';

export 'package:yandex_smart_captcha/yandex_smart_captcha.dart';

/// The supported languages for the Web SmartCaptcha widget UI.
enum CaptchaLanguage {
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

/// The supported positions for the badge that includes a link
/// to the Data Processing Notice (when invisible mode is enabled).
enum DPNBadgePosition {
  topLeft('top-left'),
  centerLeft('center-left'),
  bottomLeft('bottom-left'),
  topRight('top-right'),
  centerRight('center-right'),
  bottomRight('bottom-right');

  const DPNBadgePosition(this.id);

  final String id;

  @override
  String toString() => id;
}

/// The configuration for the [YandexSmartCaptcha] widget.
/// Most options apply to the underlying Web SmartCaptcha hosted in the WebView.
/// For more information, see the [Yandex SmartCaptcha documentation](https://yandex.cloud/en/docs/smartcaptcha/concepts/widget-methods#methods).
final class CaptchaConfig {
  /// A client-side key passed to the underlying Web SmartCaptcha.<br />
  /// Corresponding JavaScript parameter – `sitekey`.
  final String clientKey;

  /// If `true`, the user will ALWAYS see a challenge. Use this option only for debugging or testing.<br />
  /// Corresponding JavaScript parameter – `test`.
  final bool alwaysShowChallenge;

  /// The language for the Web SmartCaptcha UI. For languages other than Russian, this setting
  /// also affects the CAPTCHA challenge language (typically switching it to English).<br />
  /// Supported values: `ru` | `en` | `be` | `kk` | `tt` | `uk` | `uz` | `tr`<br />
  /// Corresponding JavaScript parameter – `hl`.
  final CaptchaLanguage language;

  /// If `true`, the CAPTCHA runs in invisible mode – without the 'I’m not a robot' checkbox.
  /// Only users whose requests are deemed suspicious by Yandex SmartCaptcha will see a challenge.<br />
  /// Corresponding JavaScript parameter – `invisible`.
  final bool invisibleMode;

  /// If `true` and invisible mode is enabled, the badge linking to the Data Processing Notice will be hidden.
  /// WARNING: You still MUST inform users that their data is processed by Yandex SmartCaptcha. If you hide the DPN badge,
  /// ensure there is an alternative method to notify users about data processing.<br />
  /// Corresponding JavaScript parameter – `hideShield`.
  final bool hideDPNBadge;

  /// If `invisibleMode` is enabled, this option specifies the position of the badge linking to the Data Processing Notice.<br />
  /// Supported values: `top-left` | `center-left` | `bottom-left` | `top-right` | `center-right` | `bottom-right`.<br />
  /// Corresponding JavaScript parameter – `shieldPosition`.
  final DPNBadgePosition dpnBadgePosition;

  /// If `true`, the CAPTCHA runs in a special WebView mode, improving challenge accuracy on mobile devices.
  /// Since this package is designed for Flutter, this option should typically be set to `true`.
  /// Corresponding JavaScript parameter – `webview`.
  final bool webViewMode;

  /// The initial scale factor for the Web SmartCaptcha content.
  /// This value is passed to the `initial-scale` attribute of the HTML document's `viewport` meta tag.
  /// The actual behavior may vary depending on the platform and OS version.
  final double initialContentScale;

  /// If `true`, the user can zoom in and out of the Web SmartCaptcha content.
  /// This value is passed to the `user-scalable` attribute of the HTML document's `viewport` meta tag.
  /// The actual behavior may vary depending on the platform and OS version.
  final bool userScalableContent;

  /// If `userScalableContent` is enabled, this option specifies the maximum scale factor for the content.
  /// This value is passed to the `maximum-scale` attribute of the HTML document's `viewport` meta tag.
  /// The actual behavior may vary depending on the platform and OS version.
  final double maximumContentScale;

  /// The background color of the `YandexSmartCaptcha` widget.
  final Color? backgroundColor;

  const CaptchaConfig({
    required this.clientKey,
    this.alwaysShowChallenge = false,
    this.language = CaptchaLanguage.ru,
    this.invisibleMode = false,
    this.hideDPNBadge = false,
    this.dpnBadgePosition = DPNBadgePosition.bottomRight,
    this.webViewMode = true,
    this.initialContentScale = 1.0,
    this.userScalableContent = false,
    this.maximumContentScale = 3.0,
    this.backgroundColor,
  });
}

/// The controller for the [YandexSmartCaptcha] widget.
/// It is primarily designed to manage the underlying Web SmartCaptcha hosted in the WebView.
final class CaptchaController {
  InAppWebViewController? _inAppWebViewController;
  VoidCallback? _onControllerReady;

  /// Returns `true` if the underlying WebView controller is fully initialized.
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

  /// Called when a network error is encountered.
  final VoidCallback? onNetworkError;

  /// Called when a JavaScript error is encountered.
  final VoidCallback? onJavaScriptError;

  /// Called when the CAPTCHA challenge popup is shown.
  final VoidCallback? onChallengeShown;

  /// Called when the CAPTCHA challenge popup is hidden.
  final VoidCallback? onChallengeHidden;

  /// Called when the user successfully solves a CAPTCHA challenge. The callback usually receives
  /// a token string as an argument. WARNING: In very rare cases, if something goes wrong,
  /// the token may be `null`, so always check for this condition.
  final void Function(String? token) onChallengeSolved;

  /// Called when a navigation request is made in the underlying WebView. Return `false` from the callback
  /// to block the request; otherwise, return `true` to allow it.
  final bool Function(String url)? onNavigationRequest;

  /// A widget to display while the Web SmartCaptcha is loading.
  final Widget? loadingIndicator;

  const YandexSmartCaptcha({
    required this.config,
    required this.onChallengeSolved,
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

  final _webCaptchaLoaded = ValueNotifier<bool>(false);

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
      clientKey: config.clientKey,
      alwaysShowChallenge: config.alwaysShowChallenge,
      language: config.language.name,
      invisibleMode: config.invisibleMode,
      hideDPNBadge: config.hideDPNBadge,
      dpnBadgePosition: config.dpnBadgePosition.id,
      webViewMode: config.webViewMode,
      initialContentScale: config.initialContentScale.clamp(0.1, 10),
      userScalableContent: config.userScalableContent ? 'yes' : 'no',
      maximumContentScale: config.maximumContentScale.clamp(0.1, 10),
    );
  }

  @override
  void dispose() {
    _webCaptchaLoaded.dispose();
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
            valueListenable: _webCaptchaLoaded,
            child: widget.loadingIndicator,
            builder: (_, loaded, child) =>
                loaded ? const SizedBox.shrink() : child!,
          ),
        ],
        InAppWebView(
          initialSettings: settings,
          initialData: InAppWebViewInitialData(data: _webCaptcha.html),
          onPermissionRequest: (_, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          shouldOverrideUrlLoading: (_, navigationAction) async {
            final url = navigationAction.request.url.toString();
            final cbResult = widget.onNavigationRequest?.call(url) ?? true;
            return cbResult
                ? NavigationActionPolicy.ALLOW
                : NavigationActionPolicy.CANCEL;
          },
          onConsoleMessage: (_, message) {
            debugPrint('YandexSmartCaptcha JS console message: $message');
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
                  handlerName: 'onChallengeSolved',
                  callback: (args) {
                    var token = args.firstOrNull?.toString();
                    token = token == 'null' ? null : token;
                    widget.onChallengeSolved(token);
                  })
              ..addJavaScriptHandler(
                  handlerName: 'onCaptchaLoaded',
                  callback: (args) {
                    _webCaptchaLoaded.value = true;
                  });
          },
        ),
      ],
    );
  }
}
