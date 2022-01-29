import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluamp/CommunityCode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'main.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class CommunityCreate extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<CommunityCreate> {
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
          const Text('コミュニティ新規登録', style: TextStyle(fontFamily: 'Raleway')),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(20.0),
                  width: double.infinity, child: Text('新規登録するコミュニティコードを入力してください')),
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
              /*Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(MdiIcons.accountCircle),
                    hintText: '',
                    labelText: 'コミュニティネーム',
                  ),
                  controller: _CommunityNameController,
                ),
              ),*/
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
                  child: Text('登録'),
                  color: Colors.indigo,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () => {
                    _CommunityCode_Create(_CommunityCodeController, _passwordController)
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void _CommunityCode_Create(newUserEmail, newUserPassword) async {
    try {
      // メール/パスワードでユーザー登録
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential result =
      await auth.createUserWithEmailAndPassword(
        email: newUserEmail,
        password: newUserPassword,
      );
      // 登録したユーザー情報
      final User user = result.user!;
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => CommunityCode()), (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('リジェクトされています')
          ));
    }
  }
}
