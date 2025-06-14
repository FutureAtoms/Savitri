import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
/// Sets up all platform channel mocks for testing
void setupAllMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupWebViewForTesting();
  setupPermissionHandlerMock();
  setupRecordMock();
  setupLocalAuthMock();
  setupPathProviderMock();
}

/// Sets up WebView platform for testing
void setupWebViewForTesting() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Set up a mock WebView platform instance
  WebViewPlatform.instance = MockWebViewPlatform();
}

/// Sets up Permission handler mock
void setupPermissionHandlerMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'checkPermissionStatus':
          final int permission = methodCall.arguments;
          if (permission == 7) { // Microphone permission
            return 1; // PermissionStatus.granted
          }
          return 0; // PermissionStatus.denied
        case 'requestPermissions':
          final List<int> permissions = methodCall.arguments;
          final Map<int, int> result = {};
          for (final permission in permissions) {
            result[permission] = permission == 7 ? 1 : 0; // Grant microphone, deny others
          }
          return result;
        case 'shouldShowRequestPermissionRationale':
          return false;
        case 'openAppSettings':
          return true;
        default:
          return null;
      }
    },
  );
}

/// Sets up Record (audio recorder) mock
void setupRecordMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.llfbandit.record/messages'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'hasPermission':
          return true;
        case 'start':
          // Return a mock file path
          return '/tmp/mock_recording.wav';
        case 'stop':
          // Return the mock recording path
          return '/tmp/mock_recording.wav';
        case 'pause':
          return null;
        case 'resume':
          return null;
        case 'isPaused':
          return false;
        case 'isRecording':
          return true;
        case 'getAmplitude':
          return {
            'current': -20.0,
            'max': -10.0,
          };
        case 'dispose':
          return null;
        default:
          return null;
      }
    },
  );
}

/// Sets up Local Auth mock
void setupLocalAuthMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/local_auth'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getAvailableBiometrics':
          // Return available biometric types
          return <String>['face', 'fingerprint'];
        case 'deviceSupportsBiometrics':
          return true;
        case 'isDeviceSupported':
          return true;
        case 'stopAuthentication':
          return true;
        case 'authenticate':
          // Extract authenticate options
          // Simulate successful authentication
          return true;
        case 'getEnrolledBiometrics':
          return <String>['face'];
        default:
          return null;
      }
    },
  );
}

/// Sets up Path Provider mock
void setupPathProviderMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getTemporaryDirectory':
          return '/tmp';
        case 'getApplicationDocumentsDirectory':
          return '/tmp/documents';
        case 'getApplicationSupportDirectory':
          return '/tmp/support';
        case 'getLibraryDirectory':
          return '/tmp/library';
        case 'getExternalStorageDirectory':
          return '/tmp/external';
        case 'getExternalCacheDirectories':
          return <String>['/tmp/external_cache'];
        case 'getExternalStorageDirectories':
          return <String>['/tmp/external_storage'];
        case 'getDownloadsDirectory':
          return '/tmp/downloads';
        default:
          return null;
      }
    },
  );
}

/// Clear all mocks
void clearAllMocks() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.llfbandit.record/messages'),
    null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/local_auth'),
    null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    null,
  );
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

  Future<void> setNavigationDelegate(      PlatformNavigationDelegate navigationDelegate) async {
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
