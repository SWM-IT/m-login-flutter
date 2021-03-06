import 'package:flutter/material.dart';
import 'package:m_login_sdk/m_login_sdk.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  ///
  /// Assign a simple logger to the MLoginSDK's login facilities.
  /// This logger will simply write every log message (regardless of log leve)
  /// to the Console.
  /// You are encouraged to provide your own [MLoginLogger] implementation and
  /// taylor it to your needs.
  ///
  MLoginLog.logger = MLoginTrivialLogger(logDebugMessages: true);

  runApp(const FlutterMLoginSdkSample());
}

class FlutterMLoginSdkSample extends StatelessWidget {
  const FlutterMLoginSdkSample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: ExampleLauncherPage(),
    );
  }
}

class ExampleLauncherPage extends StatefulWidget {
  const ExampleLauncherPage({Key? key}) : super(key: key);

  @override
  _ExampleLauncherPageState createState() => _ExampleLauncherPageState();
}

class _ExampleLauncherPageState extends State<ExampleLauncherPage> {
  String loginResultText = '<Not yet logged in>';
  String signUpResultText = '<Not yet signed up>';
  String profilePageResultText = '';
  String paymentMethodsPageResultText = '';
  String driversLicenseResultText = '';

  BehaviorSubject<String?> userName = BehaviorSubject.seeded(null);
  BehaviorSubject<String?> userId = BehaviorSubject.seeded(null);

  bool ephemeral = false;

  ///
  /// Having the [MLogin] as an object with longer lifecycle is recommended but
  /// not required. It's also possible to create a new [MLogin] object on demand
  /// just in time. Monitoring is recommended to check for adverse performance
  /// impact (unlikely).
  ///
  final MLogin mLogin = MLogin(
    config: MLoginConfig.k,
    clientId: 'm-login-demo-app-k',
    callbackUrlScheme: 'k.de.swm.login.app',
    redirectUri: 'k.de.swm.login.app:/oauth2redirect/example',
    idVerificationRedirectUri: 'k.de.swm.login.app:/oauth2redirect/example',
  );

  @override
  initState() {
    userName.listen((value) {
      mLogin.prefilledUsername = value;
    });
    userId.listen((value) {
      mLogin.loggedInMLoginUserId = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Login SDK'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    const Text('Ephemeral: '),
                    Switch(
                      value: ephemeral,
                      onChanged: (value) {
                        setState(() {
                          ephemeral = value;
                        });
                      },
                    ),
                  ],
                ),
                MLoginButton(
                  text: 'Mit M-Login anmelden',
                  onPressed: _startLogin,
                ),
                Text(loginResultText),
                ElevatedButton(
                  onPressed: _startSignUp,
                  child: const Text('Sign Up'),
                ),
                Text(signUpResultText),
                ElevatedButton(
                  onPressed: _openProfilePage,
                  child: const Text('Profile Page'),
                ),
                Text(profilePageResultText),
                ElevatedButton(
                  onPressed: _openDriversLicenseVerificationPage,
                  child: const Text('Drivers License Verification'),
                ),
                Text(driversLicenseResultText),
                Container(
                  color: Colors.grey,
                  padding: const EdgeInsets.all(10),
                  child: MLoginButtonWhite(
                    text: 'Payment Methods Page',
                    onPressed: _openPaymentMethodsPage,
                  ),
                ),
                Text(paymentMethodsPageResultText),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'To test prefilled user name function, login with valid account, '
                        'enter user name and random user id and open service page (e.g. Profile Page)',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        onChanged: (text) => userName.add(text),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Username (e-Mail)',
                        ),
                        keyboardType: TextInputType.text,
                        autofocus: true,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        onChanged: (text) => userId.add(text),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'User Id (may be random value)',
                        ),
                        keyboardType: TextInputType.text,
                        autofocus: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _startLogin() async {
    setState(() {
      loginResultText = 'Logging in...';
    });
    final loginResult = await mLogin.login(
      ephemeral: ephemeral,
    );
    setState(() {
      loginResult.process(
        (authCode, verifier) {
          loginResultText =
              'Login successful!\ncode: $authCode\nverifier: $verifier';
        },
        (error) {
          loginResultText = 'Login FAILED!\n$error';
        },
      );
    });
  }

  _startSignUp() async {
    setState(() {
      signUpResultText = 'Signing up...';
    });
    final loginResult = await mLogin.register(ephemeral: ephemeral);
    setState(() {
      loginResult.process(
        (authCode, verifier) {
          signUpResultText =
              'SignUp successful!\ncode: $authCode\nverifier: $verifier';
        },
        (error) {
          signUpResultText = 'SignUp FAILED!\n$error';
        },
      );
    });
  }

  _openProfilePage() async {
    setState(() {
      profilePageResultText = 'Opening profile page...';
    });

    final result = await mLogin.openPortalOverview(
      ephemeral: ephemeral,
    );
    setState(() {
      profilePageResultText = 'Profile was shown, result: $result';
    });
  }

  _openPaymentMethodsPage() async {
    setState(() {
      paymentMethodsPageResultText = 'Opening payment methods page...';
    });

    final result = await mLogin.openPaymentMethodsOverviewPage(
      'm-login-demo-payee-k',
      ephemeral: ephemeral,
    );
    setState(() {
      paymentMethodsPageResultText =
          'Payment methods page was shown, result: $result';
    });
  }

  _openDriversLicenseVerificationPage() async {
    setState(() {
      driversLicenseResultText = 'Opening Drivers License page...';
    });

    final result = await mLogin.openDriverLicenseVerification(
      ephemeral: ephemeral,
    );
    setState(() {
      driversLicenseResultText = 'Profile was shown, result: $result';
    });
  }
}
