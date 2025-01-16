import 'package:flutter/material.dart';
import 'package:yandex_smart_captcha/yandex_smart_captcha.dart';

// Get your key from the Yandex Cloud admin panel.
const siteKey = String.fromEnvironment('SITE_KEY');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yandex SmartCaptcha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({required this.title, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CaptchaController _controller;
  late final CaptchaConfig _config;

  @override
  void initState() {
    super.initState();
    _controller = CaptchaController();
    _config = const CaptchaConfig(
      siteKey: siteKey,
      testMode: true,
      language: CaptchaUILanguage.en,
      // invisible: false,
      // hideShield: false,
      // shieldPosition: CaptchaShieldPosition.bottomRight,
      // webView: true,
      backgroundColor: Colors.lightBlue,
    );
    _controller.setReadyCallback(() {
      debugPrint('call: SmartCaptcha controller is ready');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: YandexSmartCaptcha(
                config: _config,
                controller: _controller,
                loadingIndicator: const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
                onNavigationRequest: (url) {
                  debugPrint('call: onNavigationRequest $url');
                  if (url.contains('cloud.yandex')) {
                    // Block the navigation request when the user
                    // clicks on the 'SmartCaptcha by Yandex Cloud' link.
                    return false;
                  }
                  return true;
                },
                onChallengeShown: () {
                  debugPrint('call: onChallengeShown');
                },
                onChallengeHidden: () {
                  debugPrint('call: onChallengeHidden');
                },
                onTokenReceived: (token) {
                  debugPrint('call: onTokenReceived $token');
                },
                onNetworkError: () {
                  debugPrint('call: onNetworkError');
                },
                onJavaScriptError: () {
                  debugPrint('call: onJavaScriptError');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.isReady) {
                        _controller.execute();
                      }
                    },
                    child: const Text('Execute'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.isReady) {
                        _controller.destroy();
                      }
                    },
                    child: const Text('Destroy'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
