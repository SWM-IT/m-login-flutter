## [0.5.1] - (11th April 2022)

* Shortened Toast message (Android 12 only supports max 2 lines)
* Fixed MLogin Button Image loading issue

## [0.5.0] - (21st March 2022)

* Updated to new URIs for testing environments.

**NOTE** Previous versions of the SDK are deprecated with this change. While production builds will
not be affected, test builds against `i` or `k` environments will stop working at some point in the
future!

## [0.4.0] - (25nd February 2022)

* Added optional "ephemeral" parameter to specifiy whether ephemeral sessions (previous standard!)
  should be used or not. **NOTE**: Default behaviour was changed to `ephemeral = false`!
* Fixed issue where Login attempts would appear as "canceled" on Firefox
* Added Toast warning message if no browser is installed, added error code to inform about missing
  browser

## [0.3.0] - (28th January 2022)

* Removed dependency on on `flutter_web_auth`
* Fixed issue with task handling on Android: Now, the M-Login flow runs in the same task. No more
  browser pollution in the task switcher, no more issues when logging in twice
* Fixed issue on Android where the task would fail when there is more than one app including the
  M-Login-SDK on the same phone
* Simplified integration on Android: Fewer additions to the Manifest required

## [0.2.1] - (25th January 2022)

* Bugfix for MLogin Button -> made padding parameter functional

## [0.2.0] - (18th January 2022)

* Added `openDriverLicenseVerification` call to `MLogin` to jump directly to the driver license
  verification flow in the M-Login portal
* Added optional `idVerificationRedirectUri` configuration parameter to `MLogin` to
  support `openDriverLicenseVerification`

## [0.1.3] - (17th December 2021)

* Improved accessibility of offered M-Login buttons

## [0.1.2] - (22nd November 2021)

* Removed extension-based structuring of `MLogin` class to allow for better mockability

## [0.1.1] - (22nd November 2021)

* No changed functionality. Minor adjustments to make pub.dev happy and hand out more points

## [0.1.0] - (22nd November 2021)

* Initial release: flutter-native access to the M-Login systems
