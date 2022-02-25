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
  /// [ephemeral] defines whether an "ephemeral" browser session (a new session
  /// without access to stored cookies) should be opened or not.
  ///
  /// Ephemeral sessions have the advantage on iOS that the user does not have
  /// to confirm access before the browser is opened - but then the user has
  /// to login again!
  ///
  /// It is recommended to *not* use ephemeral sessions.
  ///
  /// Native access! May throw `PlatformException`s
  ///
  static Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool ephemeral,
  }) async {
    return await _channel.invokeMethod(
      'authenticate',
      <String, dynamic>{
        'url': url,
        'callbackUrlScheme': callbackUrlScheme,
        'ephemeral': ephemeral,
      },
    ) as String;
  }
}
