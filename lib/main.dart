import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/services.dart';
import 'amplifyconfiguration.dart';
import 'Tab.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(App());
}


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansCJKJp',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        fontFamily: 'NotoSansCJKJp',
      ),
      home: Login(),
      //Login(),
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => new Login(),
        '/tab': (BuildContext context) => new TabPage(),
      },
    );
  }
}

class Login extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Login> {
  final _mailAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationController = TextEditingController();
  LocalAuthentication _localAuth = LocalAuthentication();
  late bool state;
  List<BiometricType>? _availableBiometrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
      AmplifyAPI apiPlugin = AmplifyAPI();
      AmplifyStorageS3 storagePlugin = AmplifyStorageS3();
      Amplify.addPlugins([authPlugin]);
      Amplify.addPlugins([apiPlugin]);
      Amplify.addPlugins([storagePlugin]);
      Amplify.configure(amplifyconfig);
    });
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: const Text('ログイン', style: TextStyle(fontFamily: 'Raleway')),
      ),
      body: Center(
        child: ListView(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    _launchURL("https://aws.amazon.com/jp/cognito/"); //amplifyのURL
                  },
                  child: Text("Amazon AWS Cognito",
                    style: TextStyle(color: Colors.red,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
        Padding(
        padding: const EdgeInsets.all(10.0),
        ),
              Container(
              alignment: Alignment.center,
              child: Text("未ログインの方はこちらへ"),
            ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.mail_outline),
                    hintText: '○○○○○○@examle.com',
                    labelText: 'メールアドレス',
                  ),
                  controller: _mailAddressController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.vpn_key),
                    hintText: 'password',
                    labelText: 'パスワード',
                  ),
                  obscureText: true,
                  controller: _passwordController,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('ログイン'),
                  color: Colors.indigo,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () => _signIn(),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('新規登録申請'),
                  color: Colors.orangeAccent,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () => _singUp(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.vpn_key),
                    hintText: '012345',
                    labelText: '確認コード',
                  ),
                  controller: _verificationController,
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('確認コード承認'),
                  color: Colors.orangeAccent,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () => _confirmSignUp(),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text("ログイン済みの方はこちらへ"),
              ),
              RaisedButton(
                color: Colors.red,
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        AlertDialog(
                          title: const Text('ログイン'),
                          content: const Text(
                            'ログインセッションから認証します。',
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            FlatButton(
                              onPressed: () => _signing(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('ログイン済みの方'),
              ),
              RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  _authenticate();
                },
                child: const Text('生体認証(ベータ版)'),
              ),
            ]),
      ),
    );
  }

  void _launchURL(uri) async {
    final url = uri;
    if (await canLaunch(url!)) {
      await launch(url);
      print("$urlへ接続します。");
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _getAvailableBiometricTypes() async {
    List<BiometricType> availableBiometricTypes;
    try {
      availableBiometricTypes = await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometricTypes = <BiometricType>[];
    }
    setState(() {
      _availableBiometrics = availableBiometricTypes;
    });
  }

  void _authenticaterror() async {
    print("ログインできません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ログインセッションがありません'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
}

  void _signinerror() async {
    print("ログインできません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('入力情報が不適当です'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmerror() async {
    print("コード承認できません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('入力コードが不適当です'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _signuperror() async {
    print("申請できません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('入力情報が不適当です'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmsucess() async {
    print("新規登録完了しました。");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('承認されました ログインしてください'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirminfo() async {
    print("新規登録申請しました。");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('メールアドレスに送信しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _authenticate() async {
    bool result = false;
    _getAvailableBiometricTypes();
    try {
      if (_availableBiometrics!.contains(BiometricType.face)
          || _availableBiometrics!.contains(BiometricType.fingerprint)) {
        result = await _localAuth.authenticateWithBiometrics(localizedReason: "認証してください");
      }
    } on PlatformException catch (e) {
      print("生体認証結果: $e");
    }
    print("生体認証結果: $result");
    var session = await authSession;
    if (session.isSignedIn) {
      if (result){
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => TabPage()
            ));
      }else {
        _authenticaterror();
      };
    }
  }

  void _singUp() async {
    try {
      Map<String, String> userAttributes = {
        "email": _mailAddressController.text
      };
      SignUpResult res = await Amplify.Auth.signUp(
          username: _mailAddressController.text,
          password: _passwordController.text,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      print(res.isSignUpComplete);
      _confirminfo();
    } on AuthException catch (authError) {
      _signuperror();
    }
  }

  void _confirmSignUp() async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: _mailAddressController.text,
          confirmationCode: _verificationController.text);
      if (res.isSignUpComplete) {
        _confirmsucess();
      } else {
        _confirmerror();
      }
    } on AuthException catch (authError) {
      _signinerror();
    }
  }

  void _signIn() async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
          username: _mailAddressController.text,
          password: _passwordController.text);
      await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => TabPage()
          ));
    } on AuthException catch (authError) {
      _signinerror();
    }
  }

  static Future<AuthSession> get authSession async {
    return await Amplify.Auth.fetchAuthSession();
  }

  void _signing() async {
    try {
      var session = await authSession;
      if (session.isSignedIn) {
        print("自動ログインに成功しました。");
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => TabPage()
            ));
      }else {
        _authenticaterror();
      }
    } on AuthException catch (authError) {
      _authenticaterror();
    }
  }

  void checkUser() async {
    var session = await authSession;
    var user;
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        setState(() {
          user = attribute.value;
        });
      }
    }
    print("currentuser: $user");
    if (user != "") {
      if (session.isSignedIn) {
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => TabPage()
            ));
      } else {
      }
    }
  }

}