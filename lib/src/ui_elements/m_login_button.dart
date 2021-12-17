import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Platform aware M-Login button
///
class MLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;
  final EdgeInsets padding;
  final String? semanticsLabel;

  const MLoginButton({
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
            Ink.image(
              image: const AssetImage(
                'lib/assets/m_login_button_bg.png',
                package: 'm_login_sdk',
              ),
              fit: BoxFit.fitWidth,
              width: double.infinity,
              height: 40,
              child: InkWell(
                onTap: onPressed,
                highlightColor: Platform.isAndroid
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.2),
                splashColor: Platform.isAndroid
                    ? Colors.white.withOpacity(0.2)
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
                        'lib/assets/m_login_button_icon.png',
                        package: 'm_login_sdk',
                        height: 33,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled)
              Container(
                color: const Color.fromRGBO(220, 220, 220, 0.5),
                width: double.infinity,
                height: 40,
              ),
          ],
        ),
      ),
    );
  }
}
