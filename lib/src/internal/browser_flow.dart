import 'package:flutter/services.dart';

///
/// Handles communication with the platform's inbuilt secure browser environments
/// through method channels.
///
/// Static access only so far.
///
class BrowserFlow {
  static const MethodChannel _channel = MethodChannel('m_login_sdk');

  ///
  /// Open the M-Login portal with the given [url] in a secure browser
  /// environment.
  ///
  /// On completion, the portal will redirect to this app using a URI with the
  /// provided [callbackUrlScheme]
  ///
  /// [callbackUrlScheme] should be a string specifying the scheme of the url
  /// that the page will redirect to upon successful authentication.
  ///
  static Future<String> authenticate(
      {required String url, required String callbackUrlScheme}) async {
    return await _channel.invokeMethod('authenticate', <String, dynamic>{
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
    }) as String;
  }
}
