///
/// Object generated from a captured redirect URI.
/// Simplifies access to the received query parameters.
///
class AuthResult {
  final String? code;
  final String? state;
  final String? error;

  AuthResult({
    this.code,
    this.state,
    this.error,
  });

  ///
  /// Attempt to read the auth results from a given redirect string.
  /// Will deliver [null] in case [receivedRedirectUri] is not in a valid
  /// URI format.
  ///
  static AuthResult? fromRedirectUri(String receivedRedirectUri) {
    final uri = Uri.tryParse(receivedRedirectUri);
    if (uri == null) {
      return null;
    }

    return AuthResult(
      code: uri.queryParameters['code'],
      state: uri.queryParameters['state'],
      error: uri.queryParameters['error'],
    );
  }
}
