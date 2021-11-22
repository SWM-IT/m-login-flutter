# The M-Login Flutter SDK

This package, `m_login_sdk`, is a native Flutter client library that allows for accessing the
M-Login system. The M-Login system is an identity provider scheme aimed at businesses and
institutions in the Munich urban area. With it, users have a central point where they can manage
their data, and they can allow other systems to access this data in a secure and transparent way.
The SDK is built on top of the OAuth2 standard, including the PKCE enhancement.

The following functionality is supported:

* Login
* Registration
* Administration of user data (name, email, address, birthday, phone number, ...)
* Administration of payment methods
* Error recovery from payment checkout flows

These functions are built as web sites. It's the SDK's responsibility to create the correct URIs,
including correct cryptographic tokens, open secure browser sessions, capturing redirects, and
process output coming back from these websites.

## What you'll need

#### A flutter project

Duh

#### ClientID

To make use of the M-Login system, you need to apply for a `client-id` with the M-Login team. Please
visit https://login.muenchen.de/ for contact details.

#### A redirectUri

You should have defined this together with the M-Login team when getting the `client-id`. This needs
to start with a custom `url scheme` (e.g. `de.example.my-app`) to avoid runtime errors and
confusion.

## Supported clients

* Android with API level >21
* iOS from iOS 12

## Dependencies

#### `crypto`

Default Dart cryptography library. Needed to generate valid and secure code challenges and
verification codes in the [PKCE](https://oauth.net/2/pkce/) flow.

#### `flutter_web_auth`

Support plugin that handles opening of secure browser environments on Android and iOS as well as
recognizing when a browser session finishes while capturing the output from the web session.

## Integrating the SDK

Add the M-Login SDK as dependency to your `pubspec.yml` file and run `pub get`. The easiest way is
to open the terminal, navigate to the root directory of your project and run

```text
flutter pub add m_login_sdk
```

This will add a dependency in your `pubspec.yml` file that looks like this:

```yaml
  m_login_sdk: ^0.1.1
```

## SetUp

The M-Login SDK needs to jump into the browser to do its thing, and then back into the app. For
that, we'll need to make some minor adjustments in the native code of your Flutter app:

#### Android

##### Set min API version

First, make sure that you've set the right min SDK to >=21. For that, open the `build.gradle` file
in `android.app`, locate the line `minSdkVersion` (probably in `defaultConfig`) and make sure that
it is set to something >= 21 (Flutter sets this to 16 by default).

##### Register for custom url scheme

In the `android/app/src/main` folder, open the `AndroidManifest.xml` file, and add the following
inside of the `<application> [IN HERE] </application>` entity:

```xml

<activity android:name="com.linusu.flutter_web_auth.CallbackActivity">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="<YOUR URL SCHEME>" />
    </intent-filter>
</activity>
```

Make sure to replace `<YOUR URL SCHEME>` with your actual URL scheme. In case you are accessing
different M-Login tiers (`K`, `P`) for different build versions, add the according changes in the
fitting flavors, e.g. `android/app/src/debug`.

##### Targeting API versions >= 30

When you target Android versions starting with 30 (which you should), you'll also have to add the
following, to the `AndroidManifest.xml` file, this time directly in the root
entity `<manifest ...> [IN HERE] </manifest>`

```xml

<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.APP_BROWSER" />
        <data android:scheme="https" />
    </intent>
</queries>
```

Without this, your app can not open secure browser sessions!

#### iOS

Edit the `Info.plist` file in `ios/Runner` and add the following:

```
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string><YOUR URL SCHEME></string>
            </array>
        </dict>
    </array>
```

Again, replace `<YOUR URL SCHEME>` with your actual URL scheme.

## Example

Check the example sub-project in `m_login_sdk_example` to see the integration and usage in action
with a very simple UI.

## Usage

See the `example` directory for a minimal implementation that uses the sdk.

#### Accessing the M-Login SDK

The central class to access the M-Login SDK is the `MLogin` class in `m_login.dart`. All
functionality is offered in there. For the parameters required to construct a `MLogin` object: 
Please check the documentation in the code.

#### Configs / Tiers

The MLogin system offers three environments / server tiers:

* __I2__: Volatile, development tier. Normally: No use for SDK users unless they implement
  experimental features.
* __K__: Testing environment. Can be considered stable enough to use for development and debugging
* __P__: Prod environment, stable. Use this for production builds

Accordingly, to access the right environment, provide the fitting `MLoginConfig` enum value as
parameter to the `MLogin` constructor.

> __NOTE__: *K* and *I2* tiers are secured with a basic auth scheme. You should have received basic
> auth access data from the M-Login team with your `clientId`, `url_scheme`, and `redirectUri`.

#### Debug logging

The SDK implements logging through the `MLoginLog` facade. By default, no `MLoginLogger` is assigned
to this facade, so no logging takes place. It is recommended to assign your own implementation
to `MLoginLog.logger` to receive log output from the SDK. There is also a minimal implementation
included to use out of the box: The `MLoginTrivialLogger`, which simply prints all log output to the
console.

> __NOTE__: Printing of log messages of the `debug` level should *only* be active in debug
> environments as potentially sensitive data may be included. Do *not* expose to any place that might
> be accessible to other apps.

#### Login

The `MLogin.login()` method offers the central functionality of the SDK: Let a user log in and get
access to the M-Login system.

Here's what happens (happy path):

* Create a `MLogin` object, call `final result = await login();` on it
* The SDK opens up an appropriate, secure browser
* The browser loads the M-Login login page (can be skipped if the user is already logged in in the
  browser context)
* The user logs in / registers
* (Optional) The user completes her profile to include all data that is marked mandatory for your
  service
* The user confirms that your service shall receive access to her data in the M-Login
* The browser is closed
* Your code receives an `MLoginResult` that contains two fields, `authCode` and `verifier` (see
  OAuth 2.0 documentation to understand these)
* Your code sends these fields to the backend of your app, where your app can exchange those two
  fields against an `accessToken`
* This `accessToken` can then be used for all requests against the M-Login servers. See the M-Login
  server documentation.

In case something goes wrong along the way, `login()` will return an `MLoginResultError` object that
contains an errorCode, which documents the nature of the failure (see `MLoginError`).

#### Register

In case you already know that your user does not have an M-Login account yet, you can navigate her
directly to the `registration` flow. For that use the `register()` call instead of `login()`;
everything else stays the same.

#### Profile

When data in the M-Login should be updated, you can

a) request the permission to change data (as a scope when logging in), offer your own UI and send
the updated data in a server-to-server request (see backend services documentation).

b) (recommended) send the user to a web-page offered by the M-Login portal to let her change the
data there. For that, call `openPortalOverview`. This will open a secure browser session and jump
directly to a page where data can be changed.

> __NOTE__: Make sure that you've set `loggedInMLoginUserId` in the `MLogin` object! Otherwise, edge
> cases with diverging user sessions are possible! See documentation for the `MLogin` constructor.

#### PaymentMethods

Similar to the [Profile]: The user can also be sent directly to a portal page to edit her payment
data. For that, call `openPaymentMethodsOverviewPage`

#### Recover from checkout error

In case a payment "checkout" fails, i.e. the transaction can not be completed, the M-Login servers
will return different error types. Some of these errors are recoverable, e.g., there's still a
mandate missing for a SEPA mandate (see M-Login API specs).

In these cases, transport the complete error object that was received by your server to the app and
call `openPayAuthorizationErrorRecovery` with the received error as parameter.

Example flow:

- The user is using service XX, being logged in there with the M-Login
- She wants to buy a thing, presses 'buy now' in XX's app, the app's backend sends 'authorize' to
  the M-Login backend with the purchase details
- Unfortunately she did not yet give a SEPA mandate for the bank account registered in the M-Login 
  (d'oh!), so the call fails
- So, XX's backend is handed back an error object with 'recoverable' set as 'error-category'
- XX's backend transfers that error object to the app - which in turn just feeds it into this method
- An appropriate Portal page is shown, the user approves the mandate
- Another checkout is triggered by the user in the app - and this time will work as expected
- profit

The third step might be something different (no payment method defined, some missing data, ..);
however, everything that can be resolved by user interaction will be categorized as
'recoverable' and should be put in here.
