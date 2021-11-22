import 'package:m_login_sdk/src/m_login_log.dart';

///
/// Defines available configurations for the MLoginSDK
///
/// Expected as parameter when accessing the central [MLogin] class.
///
// ignore_for_file: prefer_const_constructors

enum MLoginConfig {
  /// I2 environment for development.
  /// Only recommended to access bleeding-edge features that are not yet part
  /// of a stable MLogin release.
  ///
  /// Requires some basic auth for web site access (login, register, portal).
  /// Needs to be set as build variable
  i2,

  /// K environment for testing.
  /// This is the configuration recommended for dev and staging builds of apps
  /// that integrate the MLogin
  ///
  /// Requires some basic auth for web site access (login, register, portal)
  k,

  /// P environment for productive builds.
  ///
  /// Full security in place.
  p
}

extension ParametersExtension on MLoginConfig {
  ///
  /// The host that should be used to access MLogin services
  ///
  String getHost() {
    switch (this) {
      case MLoginConfig.i2:
        return 'https://m-login-i2.app-test.swm.de';
      case MLoginConfig.k:
        return 'https://m-login-k.app-test.swm.de';
      case MLoginConfig.p:
        return 'https://login.muenchen.de';
    }
  }

  ///
  /// The basic auth required for the environment, compiled into a single string
  /// like `c3dhOmXHY31JGW52d2M5Q15ErWRBzGy1`
  ///
  /// NOTE: __MUST__ be set for [i2] and [k] builds! See README on how to
  /// specify this parameter in your flutter configuration.
  ///
  String? getBasicAuth() {
    switch (this) {
      case MLoginConfig.i2:
      case MLoginConfig.k:
        if (!bool.hasEnvironment('M_LOGIN_BASIC_AUTH')) {
          MLoginLog.error(
              'Missing basic auth environment variable. MLogin access will fail!');
          return 'ERROR: MISSING BASIC AUTH';
        }
        return String.fromEnvironment('M_LOGIN_BASIC_AUTH',
            defaultValue: '<FAILURE>');
      case MLoginConfig.p:
        return null;
    }
  }
}
