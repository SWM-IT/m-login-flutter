import 'package:flutter/services.dart';
import 'package:m_login_sdk/m_login_sdk.dart';
import 'package:m_login_sdk/src/internal/browser_flow.dart';
import 'package:m_login_sdk/src/m_login_cit_result.dart';

Future<MLoginCitResult> runCit(
  MLogin mLogin, {
  required String url,
  required bool ephemeral,
}) async {
  MLoginLog.info('Starting CIT!');
  MLoginLog.debug('.. with URL: $url');

  try {
    final browserFlowResult = await BrowserFlow.authenticate(
      url: url,
      callbackUrlScheme: mLogin.callbackUrlScheme,
      ephemeral: ephemeral,
    );

    final redirectUrl = Uri.tryParse(browserFlowResult);
    if (redirectUrl == null) {
      MLoginLog.error('CIT flow returned invalid redirect url.');
      return MLoginCitResult.error(MLoginCitError.unknown);
    }

    final jwt = redirectUrl.queryParameters['jwt'];
    if (jwt == null) {
      MLoginLog.error('CIT flow returned without jwt.');
      return MLoginCitResult.error(MLoginCitError.unknown);
    }

    MLoginLog.info('CIT completed.');
    return MLoginCitResultSuccess(jwt: jwt);
  } on PlatformException catch (e) {
    switch (e.code.toLowerCase()) {
      case 'canceled':
        MLoginLog.info('CIT flow was canceled by the user');
        return MLoginCitResult.error(MLoginCitError.canceled);
      case 'no_browser_installed':
        MLoginLog.info('CIT failed: No browser installed.');
        return MLoginCitResult.error(MLoginCitError.noBrowserInstalled);
      default:
        MLoginLog.error('CIT failed with unknown PlatformException: $e');
        return MLoginCitResult.error(MLoginCitError.unknown);
    }
  } on Exception catch (e) {
    MLoginLog.error('CIT failed with unexpected Exception: $e');
    return MLoginCitResult.error(MLoginCitError.unknown);
  }
}
