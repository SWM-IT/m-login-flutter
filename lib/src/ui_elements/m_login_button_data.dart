import 'dart:ui';

import 'package:m_login_sdk/m_login_sdk.dart';

/// Configuration object for an [MLoginButton].
class MLoginButtonData {
  /// Set this to false to disable the button. No tap callbacks are triggered
  /// and the button appears greyed out. (default: true)
  final bool isEnabled;

  /// Set this to false if you do not want the button to fill the whole
  /// available width. (default: true)
  final bool fillWidth;

  /// Style of the button.
  /// - [MLoginButtonStyle.blue] (default) for a blue button that can be used in
  ///   a light theme.
  /// - [MLoginButtonStyle.white] for a white button that can be used in a
  ///   dark theme.
  final MLoginButtonStyle style;

  /// Shape of the button.
  /// - [MLoginButtonShape.roundedRectangle] (default) for a rectangle with
  ///   rounded corners. Use [cornerRadius] to adjust the radius.
  /// - [MLoginButtonShape.pill] for a pill shaped button with completely
  ///   round ends.
  final MLoginButtonShape shape;

  /// Corner radius of the button, only used if [shape] is
  /// [MLoginButtonShape.roundedRectangle]. (default: 4)
  final int cornerRadius;

  /// The locale used to determine the text of the button. Currently only
  /// supports German and English.
  /// - If no value is passed, German is used.
  /// - If a locale is passed and the language is 'de', German is used.
  /// - If a locale is passed and the language is NOT 'de', English is used.
  final Locale locale;

  const MLoginButtonData({
    this.isEnabled = true,
    this.fillWidth = true,
    this.style = MLoginButtonStyle.blue,
    this.shape = MLoginButtonShape.roundedRectangle,
    this.cornerRadius = 4,
    this.locale = const Locale.fromSubtags(languageCode: 'de'),
  });
}
