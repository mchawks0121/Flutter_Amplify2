import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/services.dart';
import 'amplifyconfiguration.dart';
import 'Tab.dart';
import 'sqlite/Secure_sql_helper.dart' as Securesql;
import 'sqlite/Login_sql_helper.dart' as Loginsql;
import 'package:local_auth/local_auth.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class PasscodeLock extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PasscodeLock> {
  final _passcodeController = TextEditingController();
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _Lockjournals = [];
  LocalAuthentication _localAuth = LocalAuthentication();
  late bool state;
  late bool loginstate;
  List<BiometricType>? _availableBiometrics;
  var user = "";

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
    _Fetchlockstatus();
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
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Container(
                alignment: Alignment.center,
                child: Text("パスコードログイン"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.vpn_key),
                    hintText: 'passcode',
                    labelText: 'パスコード',
                  ),
                  obscureText: true,
                  controller: _passcodeController,
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
                  onPressed: () => _LocksignIn(),
                ),
              ),
              RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  _authenticate();
                },
                child: const Text('生体認証(ベータ版)'),
              ),
      RaisedButton(
        color: Colors.red,
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  title: const Text('ログアウト'),
                  content: const Text(
                    '再ログインして認証してください',
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    FlatButton(
                      onPressed: () => _signOut(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        },
        child: const Text('パスコードをお忘れの方...'),
      ),
            ]
        ),
      ),
    );
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
  static Future<AuthSession> get authSession async {
    return await Amplify.Auth.fetchAuthSession();
  }

  void _authenticate() async {
    bool result = false;
    _getAvailableBiometricTypes();
    try {
      if (_availableBiometrics!.contains(BiometricType.face)
          || _availableBiometrics!.contains(BiometricType.fingerprint)) {
        result = await _localAuth.authenticateWithBiometrics(
            localizedReason: "認証してください");
      }
    } on PlatformException catch (e) {
      print("生体認証結果: $e");
    }
    print("生体認証結果: $result");
    var session = await authSession;
    if (session.isSignedIn) {
      if (result) {
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => TabPage()
            ));
      } else {
        _authenticaterror();
      }
    }
  }

  void _authenticaterror() async {
    print("ログインできません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('認証失敗しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }


  void _Fetchlockstatus() async {
    final data = await Securesql.SQLHelper.getlockstatus();
    setState(() {
      _Lockjournals = data;
    });
  }

  void _LocksignIn() async {
  if (_passcodeController.text == _Lockjournals[0]['pass']) {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TabPage()),
            (_) => false);
  }else {
    _authenticaterror();
  }
  }

  void _signOut() async {
    try {
      _deleteItem();
      await Amplify.Auth.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, "/login", (_) => false);
      print("サインアウト");
    } on AuthException catch (authError) {
      print("エラー");
    }
  }

  void _deleteItem() async {
    await Loginsql.SQLHelper.deleteAllItems();
    await Securesql.SQLHelper.deleteAlllockstatus();
  }
}