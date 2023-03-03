import 'm_login_log.dart';

///
/// Objects of this type are returned when attempting to perform a custom
/// initiated transaction (CIT).
/// Call [process] for a streamlined processing of the result.
///
class MLoginCitResult {
  MLoginCitResult._();

  factory MLoginCitResult.success({
    required String jwt,
  }) = MLoginCitResultSuccess;

  factory MLoginCitResult.error(
    MLoginCitError authCode,
  ) = MLoginCitResultError;

  ///
  /// Convenience function that simplifies working with [MLoginCitResult]s.
  ///
  void process(
    /// Called in case the request was successful
    Function(String jwt) successHandler,

    /// Called in case the request encountered an error
    Function(MLoginCitError error) errorHandler,
  ) {
    if (this is MLoginCitResultError) {
      errorHandler((this as MLoginCitResultError).error);
    } else if (this is MLoginCitResultSuccess) {
      MLoginCitResultSuccess successResult = this as MLoginCitResultSuccess;
      successHandler(successResult.jwt);
    } else {
      MLoginLog.error(
          'ERROR! Unexpected result type $this. Fallback to unknown error.');
      errorHandler(MLoginCitError.unknown);
    }
  }
}

class MLoginCitResultSuccess extends MLoginCitResult {
  final String jwt;

  MLoginCitResultSuccess({
    required this.jwt,
  }) : super._();
}

class MLoginCitResultError extends MLoginCitResult {
  final MLoginCitError error;

  MLoginCitResultError(this.error) : super._();
}

///
/// Identifies an error that occurred when attempting to perform a customer
/// initiated transaction (CIT).
///
enum MLoginCitError {
  /// The user canceled the process when the browser context was shown.
  canceled,

  /// Only to be expected (as a rare edge case) on Android phones. Indicates
  /// that there was no suitable browser found to run a M-Login session.
  ///
  /// If this error occurs, the SDK has already shown an error toast to the
  /// user, so no immediate need to process this.
  noBrowserInstalled,

  /// Some unspecified error occurred.
  /// This indicates a bug in the sdk (or backend systems). Please contact
  /// the M-Login team!
  unknown
}
