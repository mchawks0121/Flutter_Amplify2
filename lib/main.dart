import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';
import 'Tab.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => new Login(),
        '/home': (BuildContext context) => new TabPage(),
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


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
      AmplifyAPI apiPlugin = AmplifyAPI();
      Amplify.addPlugins([authPlugin]);
      Amplify.addPlugins([apiPlugin]);
      Amplify.configure(amplifyconfig);
    });
    _signing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('ログイン', style: TextStyle(fontFamily: 'Raleway')),
          ),
          body: Center(
            child: ListView(
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                    child: Text("一度ログイン済みの方はこちらへ"),
                  ),
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      // The function showDialog<T> returns Future<T>.
                      // Use Navigator.pop() to return value (of type T).
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('ログイン'),
                          content: const Text(
                            'ログインセッションを確認します。',
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
                      ).then((returnVal) {
                        if (returnVal != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('ログイン: $returnVal'),
                              action: SnackBarAction(label: 'OK', onPressed: () {}),
                            ),
                          );
                        }
                      });
                    },
                    child: const Text('ログイン済みの方'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
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
                      color: Colors.indigo,
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
                      color: Colors.indigo,
                      shape: StadiumBorder(),
                      textColor: Colors.white,
                      onPressed: () => _confirmSignUp(),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      child: Text('ログイン済みの方'),
                      color: Colors.indigo,
                      shape: StadiumBorder(),
                      textColor: Colors.white,
                      onPressed: () => _signing(),
                    ),
                  ),
                ]),
          ),
        );
  }

  void _singUp() async {
    try {
      Map<String, String> userAttributes = {
        "email": _mailAddressController.text
        // additional attributes as needed
      };
      SignUpResult res = await Amplify.Auth.signUp(
          username: _mailAddressController.text,
          password: _passwordController.text,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      print(res.isSignUpComplete);
    } on AuthException catch (authError) {
      print("エラー");
    }
  }

  void _confirmSignUp() async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: _mailAddressController.text,
          confirmationCode: _verificationController.text);
      if (res.isSignUpComplete) {
        print("大成功");
        await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
            builder: (context) => TabPage()
        ));
      } else {
        // Follow more steps
      }
    } on AuthException catch (authError) {
      print("エラー");
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
      print("エラー");
    }
  }

  static Future<AuthSession> get authSession async {
    return await Amplify.Auth.fetchAuthSession();
  }

  void _signing() async {
    try {
      var session = await authSession;
      if (session.isSignedIn) {
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => TabPage()
            ));
      // サインインしている場合の処理
      }
      } on AuthException catch (authError) {
      }
    }
}