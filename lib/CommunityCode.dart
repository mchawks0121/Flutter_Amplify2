import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'CommunityCreate.dart';
import 'main.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class CommunityCode extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<CommunityCode> {
  final _CommunityCodeController = TextEditingController();
  final _CommunityNameController = TextEditingController();
  final _passwordController = TextEditingController();
  List<Map<String, dynamic>> _CommunityCodejournals = [];
  var len;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawerEdgeDragWidth: 0,
        appBar: AppBar(
          title:
              const Text('コミュニティログイン', style: TextStyle(fontFamily: 'Raleway')),
          /*actions: [
            IconButton(
              icon: Icon(Icons.grade),
              onPressed: () => {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HelpView()))
              },
            ),
          ],*/
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(20.0),
                  width: double.infinity,
                  child: Text('コミュニティコードを入力してください')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(MdiIcons.badgeAccountHorizontalOutline),
                    hintText: '',
                    labelText: 'コミュニティコード',
                  ),
                  controller: _CommunityCodeController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.vpn_key),
                    hintText: '',
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
                  onPressed: () async {
                    _CommunityCode_Login(_CommunityCodeController.text, _passwordController.text);
                  },
                ),
              ),
              RaisedButton(
                color: Colors.orangeAccent,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommunityCreate()));
                },
                child: const Text('コミュニティ新規登録',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ));
  }

  void _CommunityCode_Login(community_name, community_pass) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential result =
      await auth.signInWithEmailAndPassword(
          email: community_name,
          password: community_pass);
      final User user = result.user!;
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Login()), (_) => true);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('コミュニティが認証されました')
          ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('リジェクトされています')
          ));
    }
  }
}
