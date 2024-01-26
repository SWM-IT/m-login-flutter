import 'package:flutter/material.dart';
import 'package:m_login_sdk/m_login_sdk.dart';

class ConfigurableButton extends StatefulWidget {
  const ConfigurableButton({super.key});

  @override
  State<ConfigurableButton> createState() => _ConfigurableButtonState();
}

class _ConfigurableButtonState extends State<ConfigurableButton> {
  bool isEnabled = true;
  bool fillWidth = true;
  int cornerRadius = 4;
  Locale locale = const Locale.fromSubtags(languageCode: 'de');
  MLoginButtonShape shape = MLoginButtonShape.roundedRectangle;
  MLoginButtonStyle style = MLoginButtonStyle.blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Button configuration', style: TextStyle(fontSize: 24)),
          Row(
            children: [
              const Text('isEnabled:'),
              Switch(
                value: isEnabled,
                onChanged: (value) => setState(() => isEnabled = value),
              ),
              const SizedBox(width: 16),
              const Text('fillWidth:'),
              Switch(
                value: fillWidth,
                onChanged: (value) => setState(() => fillWidth = value),
              ),
            ],
          ),
          const Text('style:'),
          RadioMenuButton(
            value: MLoginButtonStyle.blue,
            groupValue: style,
            onChanged: (MLoginButtonStyle? style) =>
                setState(() => this.style = style!),
            child: const Text('MLoginButtonStyle.blue'),
          ),
          RadioMenuButton(
            value: MLoginButtonStyle.white,
            groupValue: style,
            onChanged: (MLoginButtonStyle? style) =>
                setState(() => this.style = style!),
            child: const Text('MLoginButtonStyle.white'),
          ),
          const Text('shape:'),
          RadioMenuButton(
            value: MLoginButtonShape.roundedRectangle,
            groupValue: shape,
            onChanged: (MLoginButtonShape? shape) =>
                setState(() => this.shape = shape!),
            child: const Text('MLoginButtonShape.roundedRectangle'),
          ),
          RadioMenuButton(
            value: MLoginButtonShape.pill,
            groupValue: shape,
            onChanged: (MLoginButtonShape? shape) =>
                setState(() => this.shape = shape!),
            child: const Text('MLoginButtonShape.pill'),
          ),
          Text('cornerRadius: $cornerRadius'),
          Slider(
            value: cornerRadius.toDouble(),
            max: 24,
            onChanged: (radius) => setState(
              () => cornerRadius = radius.toInt(),
            ),
          ),
          const Text('locale:'),
          RadioMenuButton(
            value: const Locale.fromSubtags(languageCode: 'de'),
            groupValue: locale,
            onChanged: (Locale? locale) =>
                setState(() => this.locale = locale!),
            child: const Text('de'),
          ),
          RadioMenuButton(
            value: const Locale.fromSubtags(languageCode: 'en'),
            groupValue: locale,
            onChanged: (Locale? locale) =>
                setState(() => this.locale = locale!),
            child: const Text('en'),
          ),
          MLoginButton(
            onPressed: () {},
            data: MLoginButtonData(
              isEnabled: isEnabled,
              fillWidth: fillWidth,
              shape: shape,
              style: style,
              cornerRadius: cornerRadius,
              locale: locale,
            ),
          ),
        ],
      ),
    );
  }
}
