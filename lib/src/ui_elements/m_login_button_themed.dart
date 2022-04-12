import 'package:flutter/material.dart';
import 'package:m_login_sdk/m_login_sdk.dart';

///
/// Wrapper for M-Login buttons,
/// adapted to dark/light theme according to [isDarkTheme]
/// default is light theme
///
class MLoginButtonThemed extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;
  final EdgeInsets padding;
  final String? semanticsLabel;
  final bool isDarkTheme;

  const MLoginButtonThemed({
    Key? key,
    required this.onPressed,
    required this.text,
    this.enabled = true,
    this.padding = EdgeInsets.zero,
    this.semanticsLabel,
    this.isDarkTheme = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDarkTheme) {
      return MLoginButtonWhite(
        onPressed: onPressed,
        text: text,
        padding: padding,
        key: key,
        enabled: enabled,
        semanticsLabel: semanticsLabel,
      );
    } else {
      return MLoginButton(
        onPressed: onPressed,
        text: text,
        padding: padding,
        key: key,
        enabled: enabled,
        semanticsLabel: semanticsLabel,
      );
    }
  }
}
