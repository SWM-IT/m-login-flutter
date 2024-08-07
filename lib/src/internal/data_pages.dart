import 'package:m_login_sdk/m_login_sdk.dart';
import 'package:m_login_sdk/src/internal/browser_flow.dart';

Future<bool> openDataPage(
  MLogin mLogin, {
  required String portalUriSuffix,
  Map<String, String> extraParams = const {},
  required bool ephemeral,
  String? username,
  String? overrideRedirectUri,
  String? anchor,
}) async {
  final path = '${mLogin.config.getHost()}/portal/mobilesdk/$portalUriSuffix';

  var queryParams = <String, String>{};
  queryParams['client_id'] = mLogin.clientId;
  queryParams['redirect_uri'] = overrideRedirectUri ?? mLogin.redirectUri;

  if (mLogin.loggedInMLoginUserId?.isNotEmpty == true) {
    queryParams['user_id'] = mLogin.loggedInMLoginUserId!;
  }

  if (username?.isNotEmpty == true) {
    queryParams['username'] = username!;
  }

  extraParams.forEach((key, value) {
    queryParams[key] = value;
  });

  String queryParamsString = queryParams.entries
      .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
      .join('&');

  final uri = '$path?$queryParamsString${anchor != null ? '#$anchor' : ''}';

  try {
    final result = await BrowserFlow.authenticate(
      url: uri,
      callbackUrlScheme: mLogin.callbackUrlScheme,
      ephemeral: ephemeral,
    );
    final receivedQueryParams = Uri.tryParse(result)?.queryParameters ?? {};
    return receivedQueryParams['success'] == 'true';
  } on Exception catch (e) {
    MLoginLog.warning(
        'Opening of page $portalUriSuffix failed / was canceled by the user: $e');
  }
  return false;
}
