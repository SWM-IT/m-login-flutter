import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:m_login_sdk/src/ui_elements/m_login_button_data.dart';
import 'package:m_login_sdk/src/ui_elements/m_login_button_style.dart';

/// Platform aware M-Login button, configurable with [data].
class MLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final MLoginButtonData data;

  const MLoginButton({
    super.key,
    required this.onPressed,
    this.data = const MLoginButtonData(
      isEnabled: true,
      fillWidth: true,
      style: MLoginButtonStyle.blue,
      shape: MLoginButtonShape.roundedRectangle,
      cornerRadius: 4,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: data.isEnabled ? 1 : 0.6,
            child: Container(
              width: data.fillWidth ? double.infinity : null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  data.shape == MLoginButtonShape.pill
                      ? 9999
                      : data.cornerRadius.toDouble(),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicWidth(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'lib/assets/${data.style.buttonBackgroundAsset}',
                        package: 'm_login_sdk',
                        fit: BoxFit.fill,
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(width: 2),
                          _ButtonIcon(data: data),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ButtonText(data: data),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor:
                              Platform.isIOS ? Colors.transparent : null,
                          onTap: data.isEnabled ? onPressed : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonIcon extends StatelessWidget {
  final MLoginButtonData data;

  const _ButtonIcon({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isPill = data.shape == MLoginButtonShape.pill;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        width: isPill ? 56 : 44,
        child: Container(
          decoration: BoxDecoration(
            gradient: data.style.iconBackground,
            borderRadius: isPill
                ? const BorderRadius.horizontal(left: Radius.circular(9999))
                : BorderRadius.circular(data.cornerRadius.toDouble() - 2),
          ),
          child: SvgPicture.asset(
            'lib/assets/${data.style.iconAsset}',
            package: 'm_login_sdk',
            width: 44,
            height: 44,
          ),
        ),
      ),
    );
  }
}

class _ButtonText extends StatelessWidget {
  final MLoginButtonData data;

  const _ButtonText({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Text(
          data.locale.languageCode == 'de'
              ? 'Mit M-Login anmelden'
              : 'Sign in with M-Login',
          style: TextStyle(
            fontSize: 16,
            height: 20 / 16,
            fontWeight: FontWeight.w500,
            color: data.style.textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
