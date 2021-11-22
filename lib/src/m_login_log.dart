///
/// Central logging facilities of the MLogin SDK.
/// This is a facade only! Assign an object implementing [MLoginLogger] to
/// [MLoginLog.logger] for actual log output and integrating MLoginSDK log
/// output into your own logging scheme.
///
/// Assign a [MLoginTrivialLogger] for quick output.
///
class MLoginLog {
  static MLoginLogger? logger;

  static void debug(String message) {
    logger?.log(MLoginLogLevel.debug, message);
  }

  static void info(String message) {
    logger?.log(MLoginLogLevel.info, message);
  }

  static void warning(String message) {
    logger?.log(MLoginLogLevel.warning, message);
  }

  static void error(String message) {
    logger?.log(MLoginLogLevel.error, message);
  }
}

enum MLoginLogLevel {
  /// Verbose low level output.
  /// Can be safely ignored unless debugging MLogin issues
  ///
  /// DANGER: There might be message logged on this level which potentially
  /// contain sensitive data! Make sure to not expose these messages!
  debug,

  /// Default log level of expected behaviour of some significance, e.g.,
  /// a successful login attempt.
  info,

  /// Log level for regretful things that were expected, like a failed login
  /// attempt or missing network connectivity.
  warning,

  /// Something went irrecoverably wrong.
  /// Might signify a configuration issue or unsupported usage of the SDK - or
  /// a bug encountered inside of the SDK.
  error
}

///
/// Implement this interface and register it as [MLoginLog.logger] to receive
/// log message from the SDK.
///
abstract class MLoginLogger {
  ///
  /// Called for every log output of the MLogin SDK.
  /// It's recommended to ignore low logging levels (like [MLoginLogLevel.debug],
  /// or [MLoginLogLevel.info]) unless debugging issues with the MLogin or
  /// the SDK itself.
  ///
  log(MLoginLogLevel level, String message);
}

///
/// Simple minimal implementation of an [MLoginLogger]. Simply writes all
/// incoming messages to the console.
///
class MLoginTrivialLogger implements MLoginLogger {
  final bool logDebugMessages;

  MLoginTrivialLogger({this.logDebugMessages = false});

  @override
  log(MLoginLogLevel level, String message) {
    if (level == MLoginLogLevel.debug && !logDebugMessages) {
      return;
    }

    // ignore: avoid_print
    print('${_logLevelPrefix(level)} $message');
  }

  String _logLevelPrefix(MLoginLogLevel level) {
    switch (level) {
      case MLoginLogLevel.debug:
        return '[DEBUG]';
      case MLoginLogLevel.info:
        return '[INFO]';
      case MLoginLogLevel.warning:
        return '[WARNING]';
      case MLoginLogLevel.error:
        return '[ERROR]';
    }
  }
}
