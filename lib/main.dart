import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluamp/CommunityCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'PasscodeLogin.dart';
import 'Tab.dart';
import 'amplifyconfiguration.dart';
import 'sqlite/Login_sql_helper.dart' as Loginsql;
import 'sqlite/Secure_sql_helper.dart' as Securesql;
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  initializeDateFormatting('ja_JP');
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(App());
  //runApp(CommunityCode());
}

class App extends StatelessWidget {
  List<Map<String, dynamic>> _journals = [];
  @override
  void initState() {
    initState();
    _refreshJournals();
  }

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
      home: (_journals.isEmpty
          ? Login()
          : _journals[0]['token'] == 'true'
              ? TabPage()
              : Login()),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new Login(),
        '/tab': (BuildContext context) => new TabPage(),
      },
      navigatorObservers: [
      routeObserver,
      ],
    );
  }

  void _refreshJournals() async {
    final data = await Loginsql.SQLHelper.getItems();
    _journals = data;
    print(_journals[0]['token']);
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
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _Lockjournals = [];
  LocalAuthentication _localAuth = LocalAuthentication();
  late bool state;
  late bool loginstate;
  List<BiometricType>? _availableBiometrics;
  var user = "";
  late var len;

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
    _checkUser();
    _Fetchlockstatus();
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: const Text('????????????', style: TextStyle(fontFamily: 'Raleway')),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          Container(
            width: double.infinity,
            child: IconButton(icon: Icon(MdiIcons.aws),onPressed: () { _launchURL("https://aws.amazon.com/jp/amplify/"); },)
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          Container(
            alignment: Alignment.center,
            child: Text("????????????"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.mail_outline),
                hintText: '??????????????????@examle.com',
                labelText: '?????????????????????',
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
                labelText: '???????????????',
              ),
              obscureText: true,
              controller: _passwordController,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('????????????'),
              color: Colors.indigo,
              shape: StadiumBorder(),
              textColor: Colors.white,
              onPressed: () => _signIn(),
            ),
          ),
          /*
          RaisedButton(
            color: Colors.red,
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('????????????'),
                  content: const Text(
                    '???????????????????????????????????????????????????',
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
            child:
                const Text('????????????????????????', style: TextStyle(color: Colors.black)),
          ),
          RaisedButton(
            color: Colors.blue,
            onPressed: () {
              _authenticate();
            },
            child:
                const Text('????????????(????????????)', style: TextStyle(color: Colors.black)),
          ),
          */

          RaisedButton(
            color: Colors.orangeAccent,
            onPressed: () {
              _showFormnewuser();
              _singUp();
            },
            child: const Text('????????????', style: TextStyle(color: Colors.black)),
          ),
          Container(
            alignment: Alignment.center,
            child: Text("????????????????????????????????????????????????????????????????????????????????????????????????????????????"),
          ),
          RaisedButton(
            color: Colors.yellow,
            onPressed: () {
              _showFormforgetpass();
            },
            child: const Text('?????????????????????????????????...',
                style: TextStyle(color: Colors.black)),
          ),
          Text('?????????????????????????????????????????????????????????????????????????????????????????????????????????'),
          RaisedButton(
            color: Colors.lightBlue,
            onPressed: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) => CommunityCode()), (_) => true);
            },
            child: const Text('???????????????????????????',
                style: TextStyle(color: Colors.black)),
          ),
          Text('????????????????????????????????????????????????????????????????????????'),
        ]),
      ),
    );
  }

  void _showFormforgetpass() async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        context: context,
        elevation: 10,
        builder: (_) => Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.vpn_key),
                    hintText: 'newpassword',
                    labelText: '??????????????????',
                  ),
                  controller: _passwordController,
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.vpn_key),
                      hintText: '012345',
                      labelText: '???????????????',
                    ),
                    controller: _verificationController,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('???????????????', style: TextStyle(color: Colors.black)),
                  color: Colors.orangeAccent,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () => _confirmReset(),
                ),
              ),
            ]));
  }

  void _showFormnewuser() async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        context: context,
        elevation: 10,
        builder: (_) => Column(children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.vpn_key),
                      hintText: '012345',
                      labelText: '???????????????',
                    ),
                    controller: _verificationController,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('??????????????????', style: TextStyle(color: Colors.black)),
                  color: Colors.orangeAccent,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () {
                    _resendcode();
                  },
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('???????????????', style: TextStyle(color: Colors.black)),
                  color: Colors.orangeAccent,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () {
                    _confirmSignUp();
                  },
                ),
              ),
            ]));
  }

  void _launchURL(uri) async {
    final url = uri;
    if (await canLaunch(url!)) {
      await launch(url);
      print("$url?????????????????????");
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
    print("???????????????????????????");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('?????????????????????????????????????????????'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _signinerror() async {
    print("???????????????????????????");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('??????????????????????????????'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmerror() async {
    print("??????????????????????????????");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('?????????????????????????????????'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _signuperror() async {
    print("?????????????????????");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('??????????????????????????????'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmsucess() async {
    print("?????????????????????????????????");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('????????????????????? ??????????????????????????????'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirminfo() async {
    print("?????????????????????????????????");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('??????????????????????????????????????????'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _authenticate() async {
    bool result = false;
    _getAvailableBiometricTypes();
    try {
      if (_availableBiometrics!.contains(BiometricType.face) ||
          _availableBiometrics!.contains(BiometricType.fingerprint)) {
        result = await _localAuth.authenticateWithBiometrics(
            localizedReason: "????????????????????????");
      }
      _addItem(1, user, 'true');
    } on PlatformException catch (e) {
      print("????????????: $e");
    }
    print("??????????????????: $result");
    var session = await authSession;
    if (session.isSignedIn) {
      if (result) {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TabPage()));
      } else {
        _authenticaterror();
      }
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
      setAlluser(_mailAddressController.text);
      _confirminfo();
    } on AuthException catch (authError) {
      _signuperror();
    }
  }

  void setAlluser(user) async {
    try {
      String graphQLDocument_get = '''query listOwners {
      listOwners {
        items {
          id
          createdAt
          owner
          count
          updatedAt
        }
        nextToken
      }
    }''';
      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
            document: graphQLDocument_get,
          ));
      var response = await operation.response;

      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listOwners']['items'].length;


      String graphQLDocument_set = '''mutation CreateOwner(\$owner: String!, \$count: Int!) {
              createOwner(input: {owner: \$owner, count: \$count}) {
                owner
                count
              }
        }''';

      var count = len + 1;
      List<String> str = [];
      str = user.split('@');
      var variables = {
        "owner": str[0],
        "count": count,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument_set, variables: variables);

      operation = Amplify.API.mutate(request: request);
      response = await operation.response;

      var data = response.data;
      //_createChatList();
      print('result: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _createChatList() async {
    try {
      String graphQLDocument =
      '''mutation CreateChatList(\$owner: String, \$count: Int!) {
              createChatList(input: {owner: \$owner, count: \$count) {
                id
                owner
                count
              }
        }''';

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      str = user.split('@');
      var count = len + 1;
      var variables = {
        "owner": str[0],
        "count": count,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      print('result: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _confirmSignUp() async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: _mailAddressController.text,
          confirmationCode: _verificationController.text);
      if (res.isSignUpComplete) {
        Navigator.pop(context);
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
      _deleteItem();
      _addItem(1, _mailAddressController.text, 'true');
      _refreshJournals();
      await Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => TabPage()), (_) => false);
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
        _addItem(1, user, 'true');
        print("??????????????????????????????????????????");
        await Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => TabPage()), (_) => false);
      } else {
        _authenticaterror();
      }
    } on AuthException catch (authError) {
      _authenticaterror();
    }
  }

  void _checkUser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey == 'email') {
        setState(() {
          user = attribute.value;
        });
        print('currentuser: $user');
      }
    }
  }

  void _confirmReset() async {
    try {
      await Amplify.Auth.confirmPassword(
          username: _mailAddressController.text,
          newPassword: _passwordController.text,
          confirmationCode: _verificationController.text);
    } on AmplifyException catch (e) {
      print(e);
    }
  }

  void _resendcode() async {
    try {
      var res = await Amplify.Auth.resendUserAttributeConfirmationCode(
        userAttributeKey: 'email',
      );
      var destination = res.codeDeliveryDetails.destination;
      print('Confirmation code set to $destination');
    } on AmplifyException catch (e) {
      print(e.message);
    }
  }

  Future<void> _addItem(id, owner, token) async {
    await Loginsql.SQLHelper.createItem(id, owner, token);
  }

  void _deleteItem() async {
    await Loginsql.SQLHelper.deleteAllItems;
  }

  void _refreshJournals() async {
    final data = await Loginsql.SQLHelper.getItems();
    setState(() {
      _journals = data;
    });
    print('sqlite????????????');
    print(_journals[0]['token']);
    if (_Lockjournals.length != 0) {
      if (_Lockjournals[0]['token'] == 'true') {
      } else {
        _autoLogin();
      }
    } else {
      _autoLogin();
    }
  }

  void _autoLogin() async {
    print('autoLoginStatus Check...');
    print('status: ${_journals}');
    if (_journals[0]['token'] == 'true') {
      print('autoLoginStatus: ${_journals[0]['token']}');
      await Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => TabPage()), (_) => false);
    } else {}
  }

  void _Fetchlockstatus() async {
    final data = await Securesql.SQLHelper.getlockstatus();
    setState(() {
      _Lockjournals = data;
    });
    if (_Lockjournals[0]['token'] == 'true') {
      print('????????????????????????: ${_Lockjournals[0]['token']}');
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PasscodeLogin()),
          (_) => false);
    }
    print('sqlite????????????');
    print(_journals);
  }
}
