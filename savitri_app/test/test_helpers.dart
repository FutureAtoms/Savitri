import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Sets up WebView platform for testing
void setupWebViewForTesting() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Set up a mock WebView platform instance
  WebViewPlatform.instance = MockWebViewPlatform();
}

/// Mock implementation of WebViewPlatform for testing
class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return MockPlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return MockPlatformWebViewWidget(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return MockPlatformWebViewCookieManager(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return MockPlatformNavigationDelegate(params);
  }
}

/// Mock PlatformWebViewController
class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController(super.params) : super.implementation();
  
  PlatformNavigationDelegate? _navigationDelegate;

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    // Don't create any timers in tests - immediately trigger callback
    // Trigger onPageFinished callback if navigation delegate is set
    if (_navigationDelegate is MockPlatformNavigationDelegate) {
      final mockDelegate = _navigationDelegate as MockPlatformNavigationDelegate;
      // Use scheduleMicrotask to avoid creating timers
      Future.microtask(() => mockDelegate.triggerOnPageFinished());
    }
  }

  @override
  Future<void> runJavaScript(String javaScript) async {}

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    return '';
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setNavigationDelegate(
      PlatformNavigationDelegate navigationDelegate) async {
    _navigationDelegate = navigationDelegate;
  }
  
  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {
    _navigationDelegate = handler;
  }
  
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}
  
  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {}
  
  @override
  Future<void> clearCache() async {}
  
  @override
  Future<void> clearLocalStorage() async {}
  
  @override
  Future<String?> currentUrl() async => 'https://example.com';
  
  @override
  Future<String?> getTitle() async => 'Test Title';
  
  @override
  Future<void> scrollTo(int x, int y) async {}
  
  @override
  Future<void> scrollBy(int x, int y) async {}
  
  @override
  Future<Offset> getScrollPosition() async => Offset.zero;
  
  @override
  Future<void> reload() async {}
  
  @override
  Future<bool> canGoBack() async => false;
  
  @override
  Future<bool> canGoForward() async => false;
  
  @override
  Future<void> goBack() async {}
  
  @override
  Future<void> goForward() async {}
  
  @override
  Future<void> enableZoom(bool enabled) async {}
  
  @override
  Future<String?> getUserAgent() async => 'Test User Agent';
  
  @override
  Future<void> setUserAgent(String? userAgent) async {}
}

/// Mock PlatformWebViewWidget
class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    // Return a simple container for testing
    return Container(
      color: const Color(0xFF000000),
      child: const Center(
        child: Text('Mock WebView'),
      ),
    );
  }
}

/// Mock PlatformWebViewCookieManager
class MockPlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  MockPlatformWebViewCookieManager(super.params) : super.implementation();

  @override
  Future<bool> clearCookies() async => true;

  @override
  Future<void> setCookie(WebViewCookie cookie) async {}
}

/// Mock PlatformNavigationDelegate
class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate(super.params) : super.implementation();
  
  PageEventCallback? _onPageFinished;

  @override
  Future<void> setOnNavigationRequest(
      NavigationRequestCallback onNavigationRequest) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
      WebResourceErrorCallback onWebResourceError) async {}
      
  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}
  
  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback onHttpAuthRequest) async {}
  
  // Helper method to trigger onPageFinished callback
  void triggerOnPageFinished() {
    if (_onPageFinished != null) {
      _onPageFinished!('https://example.com');
    }
  }
}
