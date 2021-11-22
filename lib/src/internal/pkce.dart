import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:m_login_sdk/src/internal/util.dart';

///
/// Code challenge scheme that provides security against attacks where the
/// communication between an app and the secure browser environment is leaked
/// to a malicious third party app.
///
class PkceCodeChallenge {
  final String verifier;
  final String challenge;
  final String challengeMethod = 'S256';

  static const int _minEntropy = 32;
  static const int _maxEntropy = 96;

  PkceCodeChallenge({required this.verifier, required this.challenge});

  static PkceCodeChallenge generate(Random secureRandomGenerator) {
    var verifier = _makeVerifier(secureRandomGenerator);
    return PkceCodeChallenge(
      verifier: verifier,
      challenge: _makeChallenge(verifier),
    );
  }

  static String _makeVerifier(Random secureRandomGenerator) {
    final randomEntropy =
        _minEntropy + secureRandomGenerator.nextInt(_maxEntropy - _minEntropy);
    return makeSecureRandomString(secureRandomGenerator, randomEntropy);
  }

  static String _makeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncodeWithoutPadding(digest.bytes);
  }
}
