import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';

class Home extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Home> {
  bool _isEnabled = false;
  var user = "";
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    const numItems = 20;
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("設定"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
        ListTile(
        title: Text(
          "ユーザー:   ${user ==""? "ログインしていません": user}" , style: TextStyle(color: Colors.black)
        ),
        subtitle: Text("タップでサインアウト"),
        onLongPress: () {
          Text('タップでサインアウト');
        },
        onTap: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('ログイン'),
              content: const Text(
                'サインアウトします',
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                FlatButton(
                  onPressed: () {
                    _signOut();
                    Navigator
                        .pushNamedAndRemoveUntil(
                    context, "/login", (
                    _
                    )
                    =>
                    false
                    );
                  }
                  ,
                  child: const Text('OK'),
                ),
              ],
            ),
          ).then((returnVal) {
            if (returnVal != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('サインアウト: $returnVal'),
                  action: SnackBarAction(label: 'OK', onPressed: () {}),
                ),
              );
            }
          });
        },
        trailing: null,
      ),
    ListTile(
    title: Text(
    "ライセンス"
    ),
    subtitle: Text("タップで表示"),
    onTap: () {
    _showLicense(context);
    },)
        ],
    ),
    );
  }

  Future _showLicense(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    showLicensePage(
      context: context,
      applicationName: info.appName,
      applicationVersion: info.version,
      applicationIcon: Icon(Icons.personal_video),
      applicationLegalese: "fluamp",
    );
  }

  void _signOut() async {
    try {
      await Amplify.Auth.signOut();
      setState(() {
        _isEnabled = true;
      });
      print("サインアウト¥n");
      print(_isEnabled);
    } on AuthException catch (authError) {
      print("エラー");
    }
  }
  void checkUser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        setState(() {
        user = attribute.value;
        });
      }
    }
  }
}