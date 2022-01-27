import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/services.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'amplifyconfiguration.dart';
import 'Tab.dart';
import 'sqlite/Secure_sql_helper.dart' as Securesql;
import 'sqlite/Login_sql_helper.dart' as Loginsql;
import 'package:local_auth/local_auth.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class PasscodeLogin extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PasscodeLogin> {
  final _passcodeController = TextEditingController();
  final StreamController<bool> _verificationNotifier =
  StreamController<bool>.broadcast();
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _Lockjournals = [];
  LocalAuthentication _localAuth = LocalAuthentication();
  late bool state;
  bool isAuthenticated = false;
  late bool loginstate;
  List<BiometricType>? _availableBiometrics;
  var user = "";
  var username = [];
  late var title;
  bool opaque = true;
  List<String>? digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  late Map<String, String> _getUrlResult={};
  late int len;
  late bool initialcounter = true;
  List<dynamic> itemMap = [];
  Set<dynamic> ownerMap = {};

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
    _currentuser();
    _authenticate();
    _Fetchlockstatus();
    getAlluser();
    getUrlall();
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(50.0),
            ),
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: (_getUrlResult[username[0]] == null)?
                NetworkImage('https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                    :NetworkImage(_getUrlResult[username[0]] as String)),
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                color: Colors.redAccent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
            ),
            _defaultLockScreenButton(context),
            Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            RaisedButton(
              color: Colors.blue,
              onPressed: () {
                _authenticate();
              },
              child: const Text('生体認証(ベータ版)'),
            ),Padding(
              padding: const EdgeInsets.all(10.0),
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
          ],
        ),
      ),
    );
  }

  _defaultLockScreenButton(BuildContext context) => MaterialButton(
    color: Theme.of(context).primaryColor,
    child: Text('パスコードロック'),
    onPressed: () {
      _showLockScreen(
        context,
        opaque: false,
        cancelButton: Text(
          'Cancel',
          style: const TextStyle(fontSize: 16, color: Colors.white),
          semanticsLabel: 'Cancel',
        ),
      );
    },
  );

  _showLockScreen(
      BuildContext context, {
        required bool opaque,
        CircleUIConfig? circleUIConfig,
        KeyboardUIConfig? keyboardUIConfig,
        required Widget cancelButton,
        List<String>? digits,
      }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
                title: Text(
                  'ログイン',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
                circleUIConfig: circleUIConfig,
                keyboardUIConfig: keyboardUIConfig,
                passwordEnteredCallback: _onPasscodeEntered,
                cancelButton: cancelButton,
                deleteButton: Text(
                  'Delete',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  semanticsLabel: 'Delete',
                ),
                shouldTriggerVerification: _verificationNotifier.stream,
                backgroundColor: Colors.black.withOpacity(0.8),
                cancelCallback: _onPasscodeCancelled,
                digits: digits,
                passwordDigits: 4,
              ),
        ));
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  _onPasscodeEntered(String enteredPasscode) async {
    bool isValid = _Lockjournals[0]['pass'] == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TabPage()),
              (_) => false);
    }else {
      _authenticaterror();
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
        await Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => TabPage()), (_) => false);
      } else {
        _authenticaterror();
      }
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

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        setState(() {
          user = attribute.value;
          username = user.split('@');
          title = "ようこそ ${username[0]}さん";
        });
      }
    }
  }

  void getAlluser() async {
    try {
      print('getAlluser_start');
      String graphQLDocument = '''query listOwners {
      listOwners {
        items {
          id
          createdAt
          owner
          updatedAt
        }
        nextToken
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
            document: graphQLDocument,
          ));
      var response = await operation.response;

      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listOwners']['items'].length;
      ownerMap= {};
      setState(() {
        for(int i=0;i<len;i++) {
          final List = map['listOwners']['items'][i]['owner'];
          ownerMap.add(List);
        }
      });
      print('getAlluser: ${ownerMap}');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void getUrlall() async {
    _getUrlResult={};
    try {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey== 'email') {
          setState(() {
            user = attribute.value;
          });
        }
      }
      var key = user.split("@");
      S3GetUrlOptions options = S3GetUrlOptions(
          accessLevel: StorageAccessLevel.guest, expires: 10000);
        GetUrlResult result =
        await Amplify.Storage.getUrl(key: '${username[0]}.jpeg');
        setState(() {
          _getUrlResult.addAll({username[0]: '${result.url}' as String});
        });
      print('imageurl: $_getUrlResult');
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }
}