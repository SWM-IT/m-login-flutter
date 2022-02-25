import 'm_login_log.dart';

///
/// Objects of this type are returned when attempting to access the MLogin.
/// Call [process] for a streamlined processing of the result.
///
class MLoginResult {
  MLoginResult._();

  factory MLoginResult.success({
    required String authCode,
    required String verifier,
  }) = MLoginResultSuccess;

  factory MLoginResult.error(
    MLoginError authCode,
  ) = MLoginResultError;

  ///
  /// Convenience function that simplifies working with [MLoginResult]s.
  ///
  void process(
    /// Called in case the request was successful
    Function(String authCode, String verifier) successHandler,

    /// Called in case the request encountered an error
    Function(MLoginError error) errorHandler,
  ) {
    if (this is MLoginResultError) {
      errorHandler((this as MLoginResultError).error);
    } else if (this is MLoginResultSuccess) {
      MLoginResultSuccess successResult = this as MLoginResultSuccess;
      successHandler(successResult.authCode, successResult.verifier);
    } else {
      MLoginLog.error(
          'ERROR! Unexpected result type $this. Fallback to unknown error.');
      errorHandler(MLoginError.unknown);
    }
  }
}

class MLoginResultSuccess extends MLoginResult {
  final String authCode;
  final String verifier;

  MLoginResultSuccess({
    required this.authCode,
    required this.verifier,
  }) : super._();
}

class MLoginResultError extends MLoginResult {
  final MLoginError error;

  MLoginResultError(this.error) : super._();
}

///
/// Identifies an error that occurred when attempting to access MLogin.
///
enum MLoginError {
  /// The user canceled the process when the browser context was shown.
  canceled,

  /// Only to be expected (as a rare edge case) on Android phones. Indicates
  /// that there was no suitable browser found to run a M-Login session.
  ///
  /// If this error occurs, the SDK has already shown an error toast to the
  /// user, so no immediate need to process this.
  noBrowserInstalled,

  /// The request is missing a required parameter, includes an
  /// invalid parameter value, includes a parameter more than
  /// once, or is otherwise malformed.
  invalidRequest,

  /// The client is not authorized to request an authorization
  /// code using this method.
  unauthorizedClient,

  /// The client is not authorized to request an authorization
  /// code using this method.
  accessDenied,

  /// The authorization server does not support obtaining an
  /// authorization code using this method.
  unsupportedResponseType,

  /// The requested scope is invalid, unknown, or malformed.
  invalidScope,

  /// The response received from the M-Login did not match the made request.
  /// Might be a f*ck-up somewhere or an attack.
  /// Anyway: This attempt failed and the user can only try again.
  stateMismatch,

  /// Some unspecified error occurred.
  /// This indicates a bug in the sdk (or backend systems). Please contact
  /// the MLogin team!
  unknown
}
