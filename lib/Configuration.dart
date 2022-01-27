import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/Security.dart';
import 'package:fluamp/photosettings.dart';
import 'package:fluamp/sqlite/Login_sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';
import 'MyAccount.dart';
import 'Security.dart';
import 'developer.dart';

class Configuration extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Configuration> {
  var _isEnabled;
  var user = "";
  List<Map<String, dynamic>> _journals = [];
  @override
  void initState() {
    super.initState();
    checkUser();
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("セットアップ"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(
                "アカウント"
            ),
            subtitle: Text("タップで表示"),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => MyAccount()
                  ));
            },
          ),
          ListTile(
            title: Text(
                "セッションの削除"
            ),
            subtitle: Text("タップで表示"),
            onTap: () {
              _deleteItem();
              Navigator.pushNamedAndRemoveUntil(
              context, "/login", (_) => false);
            },
          ),
        ListTile(
        title: Text(
          "ユーザー:   ${user ==""? "ログインしていません": user}"
        ),
        subtitle: Text("タップでサインアウト"),
        onLongPress: () {
          Text('タップでサインアウト');
        },
        onTap: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('サインアウト'),
              content: const Text(
                'サインアウトします',
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context, 'キャンセル'),
                  child: const Text('Cancel'),
                ),
                FlatButton(
                  onPressed: () {
                    _signOut();
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
                ),
              );
            }
          }
          );
        },
        trailing: null,
      ),
          ListTile(
            title: Text(
                "セキュリティ"
            ),
            subtitle: Text("タップで表示"),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Security()
                  ));
            },
          ),
          ListTile(
            title: Text(
                "ライセンス"
            ),
            subtitle: Text("タップで表示"),
            onTap: () {
              _showLicense(context);
              },
          ),
          ListTile(
            title: Text(
                "プロフィール"
            ),
            subtitle: Text("タップで編集"),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Photosettings()
                  ));
            },
          ),
          ListTile(
            title: Text(
                "開発者"
            ),
            subtitle: Text("タップで表示"),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Developer()
                  ));
            },
          ),
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
      applicationLegalese: "Flutter × AWS",
    );
  }

  void _signOut() async {
    try {
      _deleteItem();
      await Amplify.Auth.signOut();
      setState(() {
        _isEnabled = true;
      });
      Navigator.pushNamedAndRemoveUntil(
          context, "/login", (_) => false);
      print("サインアウト");
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

  void _deleteItem() async {
    await SQLHelper.deleteAllItems();
    _refreshJournals();
  }

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
    });
    print('sqliteから取得');
    print(_journals[0]['token']);
  }
}