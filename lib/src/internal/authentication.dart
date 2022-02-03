import 'package:flutter/services.dart';
import 'package:m_login_sdk/m_login_sdk.dart';
import 'package:m_login_sdk/src/internal/auth_result.dart';
import 'package:m_login_sdk/src/internal/browser_flow.dart';
import 'package:m_login_sdk/src/internal/pkce.dart';
import 'package:m_login_sdk/src/internal/util.dart';

Future<MLoginResult> runAuthentication(
  MLogin mLogin,
  String? loginAction,
  String prefix,
  String postfix,
  String scopes,
) async {
  String state =
      '$prefix${makeSecureRandomString(mLogin.secureRandom, 16)}$postfix';
  PkceCodeChallenge codeChallenge =
      PkceCodeChallenge.generate(mLogin.secureRandom);

  String uri = _makeRequestUri(
    baseHost: mLogin.config.getHost(),
    clientId: mLogin.clientId,
    redirectUri: mLogin.redirectUri,
    loginAction: loginAction,
    state: state,
    codeChallenge: codeChallenge,
    scopes: scopes,
  );

  MLoginLog.info('Starting Login!');
  MLoginLog.debug('.. with URI: $uri');

  try {
    final result = await BrowserFlow.authenticate(
      url: uri,
      callbackUrlScheme: mLogin.callbackUrlScheme,
    );

    MLoginLog.info('Web authentication completed.');
    MLoginLog.debug('.. $result');

    return _processAuthResult(
      receivedRedirectUri: result,
      state: state,
      verifier: codeChallenge.verifier,
    );
  } on PlatformException catch (e) {
    if (e.code.toLowerCase() == 'canceled') {
      MLoginLog.info('Web authentication was canceled by the user');
      return MLoginResult.error(MLoginError.canceled);
    }
    MLoginLog.error('Failed with unknown PlatformException: $e');
    return MLoginResult.error(MLoginError.unknown);
  } on Exception catch (e) {
    MLoginLog.error('Failed with unexpected Exception: $e');
    return MLoginResult.error(MLoginError.unknown);
  }
}

String _makeRequestUri({
  required String baseHost,
  required String clientId,
  required String redirectUri,
  String? loginAction,
  String? scopes,
  required String state,
  required PkceCodeChallenge codeChallenge,
  bool sso = true,
}) {
  final host = '$baseHost/auth/oauth2/realms/root/realms/customers/authorize';

  var queryParams = <String, String>{};
  queryParams['client_id'] = clientId;
  queryParams['redirect_uri'] = redirectUri;
  queryParams['response_type'] = 'code';
  queryParams['state'] = state;
  queryParams['code_challenge'] = codeChallenge.challenge;
  queryParams['code_challenge_method'] = codeChallenge.challengeMethod;

  if (scopes?.isNotEmpty == true) {
    queryParams['scope'] = scopes!;
  }

  if (loginAction?.isNotEmpty == true) {
    queryParams['login_action'] = loginAction!;
  }

  // later, once supported: 'locale' -> 'de_DE'

  if (!sso) {
    queryParams['prompt'] = 'login';
  }

  String queryParamsString = queryParams.entries
      .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
      .join('&');

  return '$host?$queryParamsString';
}

/// Called after an authentication browser session has completed.
/// Interprets the result and maps it to a [MLoginResult].
MLoginResult _processAuthResult({
  required String receivedRedirectUri,
  required String state,
  required String verifier,
}) {
  final result = AuthResult.fromRedirectUri(receivedRedirectUri);

  if (result == null) {
    MLoginLog.error('The received redirect uri could not be parsed as a URI');
    MLoginLog.debug('Tried this: $receivedRedirectUri');
    return MLoginResult.error(MLoginError.unknown);
  }

  if (state != result.state) {
    MLoginLog.warning(
        'States do not match! Lifecycle issue with the app or attack attempt.');
    MLoginLog.debug('Local: $state, received: ${result.state}');
    return MLoginResult.error(MLoginError.stateMismatch);
  }

  if (result.error != null) {
    final error = _parseMLoginError(result.error!);
    MLoginLog.warning('Error received: ${result.error}, parsed as $error');
    return MLoginResult.error(error);
  }

  if (result.code?.isNotEmpty != true) {
    MLoginLog.error('No error received, but also no code. Server issue?');
    return MLoginResult.error(MLoginError.unknown);
  }

  MLoginLog.info('Auth attempt successful!');

  return MLoginResult.success(authCode: result.code!, verifier: verifier);
}

MLoginError _parseMLoginError(String error) {
  switch (error) {
    case 'invalid_request':
      return MLoginError.invalidRequest;
    case 'unauthorized_client':
      return MLoginError.unauthorizedClient;
    case 'access_denied':
      return MLoginError.accessDenied;
    case 'unsupported_response_type':
      return MLoginError.unsupportedResponseType;
    case 'invalid_scope':
      return MLoginError.invalidScope;
    default:
      MLoginLog.error('Received unknown error code: $error');
      return MLoginError.unknown;
  }
}
