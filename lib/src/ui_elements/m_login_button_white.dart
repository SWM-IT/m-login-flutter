import 'dart:io';

import 'package:flutter/material.dart';

const Color mLoginBlue = Color.fromRGBO(58, 102, 245, 1);

///
/// Platform aware M-Login button for dark backgrounds
///
class MLoginButtonWhite extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;
  final EdgeInsets padding;
  final String? semanticsLabel;

  const MLoginButtonWhite({
    Key? key,
    required this.onPressed,
    required this.text,
    this.enabled = true,
    this.padding = EdgeInsets.zero,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? text,
      child: Padding(
        padding: padding,
        child: Material(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Ink(
                color: Colors.white,
                width: double.infinity,
                height: 40,
                child: InkWell(
                  onTap: onPressed,
                  highlightColor: Platform.isAndroid
                      ? mLoginBlue.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  splashColor: Platform.isAndroid
                      ? mLoginBlue.withOpacity(0.2)
                      : Colors.transparent,
                ),
              ),
              IgnorePointer(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          'lib/assets/m_login_button_white_icon.png',
                          package: 'm_login_sdk',
                          height: 33,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(color: mLoginBlue, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (!enabled)
                Container(
                  color: const Color.fromRGBO(210, 210, 210, 0.5),
                  width: double.infinity,
                  height: 40,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
