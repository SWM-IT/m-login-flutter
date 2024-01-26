import 'package:flutter/material.dart';

/// Style of the button.
/// Use either [MLoginButtonStyle.blue] or [MLoginButtonStyle.white].
class MLoginButtonStyle {
  static const blue = MLoginButtonStyle._(
    iconAsset: 'm_login_button_blue_icon.svg',
    textColor: Color(0xFFFFFFFF),
    buttonBackgroundAsset: 'm_login_button_blue_background.svg',
    iconBackground: LinearGradient(
      colors: [
        Color(0xFFFFF0FC),
        Color(0xFFE3FDF5),
      ],
    ),
  );

  static const white = MLoginButtonStyle._(
    iconAsset: 'm_login_button_white_icon.svg',
    textColor: Color(0xFF0065F5),
    buttonBackgroundAsset: 'm_login_button_white_background.svg',
    iconBackground: LinearGradient(
      colors: [
        Color(0xFF0069FF),
        Color(0xFF2265C5),
        Color(0xFF7C40FD),
      ],
      stops: [
        0.0168,
        0.6262,
        1,
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  );

  final String iconAsset;
  final Color textColor;
  final String buttonBackgroundAsset;
  final Gradient iconBackground;

  const MLoginButtonStyle._({
    required this.iconAsset,
    required this.textColor,
    required this.buttonBackgroundAsset,
    required this.iconBackground,
  });
}

/// Shape of the button.
enum MLoginButtonShape { roundedRectangle, pill }
