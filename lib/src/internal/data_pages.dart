import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:m_login_sdk/m_login_sdk.dart';

Future<bool> openDataPage(
  MLogin mLogin, {
  required String portalUriSuffix,
  Map<String, String> extraParams = const {},
}) async {
  final path = '${mLogin.config.getHost()}/portal/mobilesdk/$portalUriSuffix';

  var queryParams = <String, String>{};
  queryParams['client_id'] = mLogin.clientId;
  queryParams['done_redirect_uri'] = mLogin.redirectUri;

  if (mLogin.loggedInMLoginUserId?.isNotEmpty == true) {
    queryParams['user_id'] = mLogin.loggedInMLoginUserId!;
  }

  extraParams.forEach((key, value) {
    queryParams[key] = value;
  });

  String queryParamsString = queryParams.entries
      .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
      .join('&');

  final uri = '$path?$queryParamsString';

  try {
    final result = await FlutterWebAuth.authenticate(
      url: uri,
      callbackUrlScheme: mLogin.callbackUrlScheme,
    );
    final receivedQueryParams = Uri.tryParse(result)?.queryParameters ?? {};
    return receivedQueryParams['success'] == 'true';
  } on Exception catch (e) {
    MLoginLog.warning(
        'Opening of page $portalUriSuffix failed / was canceled by the user: $e');
  }
  return false;
}
