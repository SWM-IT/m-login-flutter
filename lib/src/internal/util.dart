import 'dart:convert';
import 'dart:math';

String makeSecureRandomString(Random secureRandomGenerator, int byteLength) {
  var bytes =
      List<int>.generate(byteLength, (i) => secureRandomGenerator.nextInt(256));
  return base64UrlEncodeWithoutPadding(bytes);
}

///
/// Basically the same as normal Base64 URL encoding but without padding, i.e.,
/// without trailing '=' signs, as defined for M-Login's OAuth flow.
String base64UrlEncodeWithoutPadding(List<int> bytes) {
  var base64encoded = base64Url.encode(bytes);
  while (base64encoded.endsWith('=')) {
    base64encoded = base64encoded.substring(0, base64encoded.length - 1);
  }
  return base64encoded;
}
