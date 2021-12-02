import 'dart:convert';
import 'dart:math';

import 'package:m_login_sdk/src/internal/authentication.dart';
import 'package:m_login_sdk/src/internal/data_pages.dart';
import 'package:m_login_sdk/src/m_login_config.dart';
import 'package:m_login_sdk/src/m_login_log.dart';
import 'package:m_login_sdk/src/m_login_result.dart';

///
/// Central access point to the MLoginSDK. All functionality is triggered via
/// the calls defined in here.
///
/// While the SDK is stateless and an [MLogin] object can be created on demand,
/// it is recommended to create only once instance and cache it as some of the
/// internally created class can be costly.
///
/// See [MLoginLog] for debugging purposes.
///
class MLogin {
  final MLoginConfig config;
  final String redirectUri;
  final String callbackUrlScheme;
  final String clientId;

  /// [loggedInMLoginUserId] Identifies the user that is currently logged-in in
  /// the app using the SDK. Optional, but it is __strongly__ recommended to set
  /// this if possible. See constructor documentation of the constructor.
  String? loggedInMLoginUserId;

  final secureRandom = Random.secure();

  ///
  /// Creates a new MLogin object.
  ///
  /// __NOTE__: While it is allowed to have multiple instances, there should
  /// always be at most one call (thus: browser session) running at the same
  /// time.
  ///
  /// [config] Defines which MLogin tier is to be accessed (i2, k, p)
  ///
  /// [redirectUri] Defines the url scheme used for this app.
  /// __MUST__ match the [clientId], login attempts will fail otherwise.
  /// This URL scheme __MUST__ also be defined for Android in the
  /// `AndroidManifest.xml` file. See the README on how to do that.
  ///
  /// [callbackUrlScheme] Necessary to catch when the web process finishes in
  /// iOS. __MUST__ match the [redirectUri]
  ///
  /// [clientId] Identifies the app using this MLoginSDK. Ask the MLogin team
  /// for a valid clientId.
  /// __MUST__ match the [redirectUri], access attempts will fail otherwise.
  ///
  /// [loggedInMLoginUserId] Identifies the user that is currently logged-in in
  /// the app using the SDK. Optional, but it is __strongly__ recommended to set
  /// this if possible.
  ///
  /// Background:
  /// ===========
  /// It is possible that the user accessed the browser context from outside
  /// the SDK or from a different app and logged into a different account.
  /// Then, when a call in this app to the SDK is issued, content will be
  /// shown for the !wrong! account.
  ///
  /// Setting the userId ensures that this error case will be recognized by
  /// the pages shown in the browser; the user will then be redirected to log
  /// into the correct account.
  ///
  /// Can (and should) be updated when the login changes.
  ///
  ///
  MLogin({
    required this.config,
    required this.redirectUri,
    required this.callbackUrlScheme,
    required this.clientId,
    this.loggedInMLoginUserId,
  });

  // ////////////////////////////////////////////////////////
  // Accounting

  ///
  /// Start the MLogin login flow: Opens a secure browser environment where the
  /// user can enter her existing MLogin credentials - or create a new account
  /// in case she does not yet have an account.
  ///
  /// This will also prompt the user to complete her profile to include all
  /// data that was marked as mandatory for the calling system, in case stuff
  /// is still missing (e.g., a mobile phone number).
  ///
  Future<MLoginResult> login({
    String prefix = '',
    String postfix = '',
    String scopes = '',
  }) async {
    return runAuthentication(this, null, prefix, postfix, scopes);
  }

  ///
  /// Start the MLogin register flow: Opens a secure browser environment where
  /// the user can create a new M-Login account - or sign in to an existing
  /// account in case it turns out she already has one.
  ///
  /// This will also prompt the user to complete her profile to include all
  /// data that was marked as mandatory for the calling system, in case stuff
  /// is still missing (e.g., a mobile phone number).
  ///
  Future<MLoginResult> register({
    String prefix = '',
    String postfix = '',
    String scopes = '',
  }) async {
    return runAuthentication(this, 'signup', prefix, postfix, scopes);
  }

  // Accounting
  // ////////////////////////////////////////////////////////
  // DataManagement

  ///
  /// Opens the M-Login portal in a web browser, focused on the profile page
  /// (name, address, birthday, email, ...). In there, the user can review
  /// and change her data.
  /// Does not require previous Login. In case there is no valid login present
  /// in the browser, the user will be prompted to log in again.
  ///
  /// Returns [true] in case the user finishes the page using the `done` button,
  /// [false] in any other case (e.g., the user pressed the "cancel" button in
  /// the iOS browser, or the back button on Android).
  ///
  /// Note that this does not contain any information whether data was changed
  /// or validated. It's safe to ignore the returned value and just assume data
  /// was changed.
  ///
  Future<bool> openPortalOverview() {
    return openDataPage(this, portalUriSuffix: 'profile');
  }

  // DataManagement
  // ////////////////////////////////////////////////////////
  // WalletAndPayment

  ///
  /// Opens a page in the browser where the user can grant a SEPA mandate for
  /// payments to the [payeeId] of the service, using the already entered bank
  /// account information in the M-Login.
  ///
  /// Calling this is usually the result of trying to trigger a payment for the
  /// given service ("checkout") and receiving a `mandate_missing` error message
  /// back. The required parameters for this call are included in the error
  /// response here.
  ///
  /// __NOTE__: For most users of the SDK, there'll never be a need to call this
  /// directly. Instead simply use [openPayAuthorizationErrorRecovery], which
  /// will cover this case, as well as others.
  ///
  /// Parameters, and where to get them:
  /// * The [methodId] identifies the SEPA payment method that needs a mandate.
  ///   If you tried to do a simple checkout, this is the default payment method
  /// * The [payeeId] identifies the entity that shall receive the money. Talk
  ///   to the M-Login team if you don't know what to put there
  ///
  /// Returns [true] in case the user finishes the page using the `done` button,
  /// [false] in any other case (e.g., the user pressed the "cancel" button in
  /// the iOS browser, or the back button on Android)
  ///
  /// Note that this does not contain any information whether data was changed
  /// or validated. It's safe to ignore the returned value and just assume data
  /// was changed.
  ///
  Future<bool> openGrantSepaMandatePage(String methodId, String payeeId) {
    return openDataPage(this,
        portalUriSuffix: 'grantmandate',
        extraParams: {'method_id': methodId, 'payee_id': payeeId});
  }

  ///
  /// Opens the M-Login portal in a web browser, focused on the payment methods
  /// page. In there, the user can review her payment methods and edit them.
  /// Does not require previous Login. In case there is no valid login present
  /// in the browser, the user will be prompted to log in again.
  ///
  /// The parameter [payeeId] is the id of the entity that will receive money,
  /// when the user pays in this service using SEPA. Must be added here to
  /// ensure that, when the user adds a new SEPA payment method, the correct
  /// mandate is already requested as well (see documentation of
  /// [openGrantSepaMandatePage]).
  ///
  /// Returns [true] in case the user finishes the page using the `done` button,
  /// [false] in any other case (e.g., the user pressed the "cancel" button in
  /// the iOS browser, or the back button on Android)
  ///
  /// Note that this does not contain any information whether data was changed
  /// or validated. It's safe to ignore the returned value and just assume data
  /// was changed.
  ///
  Future<bool> openPaymentMethodsOverviewPage(String payeeId) {
    return openDataPage(
      this,
      portalUriSuffix: 'paymentmethods',
      extraParams: {'payee_id': payeeId},
    );
  }

  ///
  /// Convenience function to open the browser on a page that prompts the user
  /// to recover from a payment authorization error that is marked as
  /// "recoverable" (see M-Login API specs)
  ///
  /// Example flow:
  /// - The user is using service XX, being logged in there with the M-Login
  /// - She wants to buy a thing, presses 'buy now' in XX's app, the app's
  ///   backend sends an `authorize` to the M-Login backend with the purchase
  ///   details
  /// - Unfortunately she did not yet give a SEPA mandate for the bank account
  ///   registered in the M-Login (d'oh!), the call fails
  /// - So, XX's backend is handed back an error object with `recoverable` set
  ///   as `error-category`
  /// - XX's backend transfers that error object to the app - which in turn just
  ///   feeds it into this method as a raw String.
  /// - An appropriate Portal page is shown, the user approves the mandate
  /// - Another checkout is triggered by the user in the app - and this time
  ///   will work as expected.
  /// - Profit
  ///
  /// The third step might be something different (no payment method defined,
  /// some missing data, ..); however, everything that can be resolved by user
  /// interaction will be categorized as `recoverable` and should be put in here
  ///
  /// The [recoverableErrorPayload] should be the complete error object as
  /// received from the backend as a raw String
  ///
  /// Returns [true] in case the user finishes the page using the `done` button,
  /// [false] in any other case (e.g., the user pressed the "cancel" button in
  /// the iOS browser, or the back button on Android)
  ///
  Future<bool> openPayAuthorizationErrorRecovery(
      String recoverableErrorPayload) {
    // We need to translate the received error JSON to query parameters in order to
    // hand it over to the Portal.
    // However, we just include 'error' and all fields in 'details' to avoid running
    // into URI length constraints.
    Map<String, String> extraParams = {};

    try {
      final Map<String, dynamic> jsonParams =
          json.decode(recoverableErrorPayload);
      final String errorCategory = jsonParams['error_category'];

      if (errorCategory.toLowerCase() != 'recoverable') {
        MLoginLog.error('Given error is not "recoverable" but $errorCategory!');
        MLoginLog.error(
            'The portal will be opened but no proper recovery will work out!');
      }

      extraParams['error'] = jsonParams['error'];
      final Map<String, String> details = jsonParams['details'];
      extraParams.addAll(details);
    } on Exception catch (e) {
      MLoginLog.error(
          'Given error payload ($recoverableErrorPayload) is not valid JSON: $e');
      MLoginLog.error(
          'The portal will be opened but no proper recovery will work out.');
    }

    return openDataPage(this,
        portalUriSuffix: 'recover-pay-authorization-error',
        extraParams: extraParams);
  }
}
