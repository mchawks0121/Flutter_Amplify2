import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/photosettings.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';

import 'developer.dart';

class ChatSettings extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<ChatSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("掲示板の設定"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[

        ],
      ),
    );
  }
}