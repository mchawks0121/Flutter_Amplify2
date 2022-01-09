import 'package:fluamp/Changepass.dart';
import 'package:flutter/material.dart';
import 'Changepass.dart';

class Security extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Security> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const numItems = 20;
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("セキュリティ"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(
                "パスワードの変更"
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Changepass()
                  ));
            },
          ),
        ],
      ),
    );
  }
}