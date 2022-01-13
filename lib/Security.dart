import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/Changepass.dart';
import 'package:flutter/material.dart';
import 'Changepass.dart';
import 'sqlite/Secure_sql_helper.dart';

class Security extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Security> {
  bool _pass = false;
  String user = "";
  final _passcodeController = TextEditingController();
  List<Map<String, dynamic>> _journals = [];

  @override
  void initState() {
    super.initState();
    _checkUser();
    _Fetchlockstatus();
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("パスコードロック"),
                Switch(
            value: _pass,
            onChanged: (bool value) {
              passchange(value);
              setState(() => _pass=value);
            },
          ),
    ]
          ),
        ],
      ),
    );
  }

  void _checkUser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        setState(() {
          user = attribute.value;
        });
        print('currentuser: $user');
      }
    }
  }

  void passchange(value) async {
    if (value == true) {
      _showForm();
      print('パスコードロック: ${value}');
    }else {
      _UnSetlockstatus();
    }
}

  void _showForm() async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        context: context,
        elevation: 10,
        builder: (_) => Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.vpn_key),
                    hintText: 'newpasscode',
                    labelText: 'パスコード',
                  ),
                  controller: _passcodeController,
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('設定'),
                  color: Colors.orangeAccent,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () {
                    _Setlockstatus();
                    Navigator.pop(context);
                }
                ),
              ),
            ]
        )
    );
  }

  void _Setlockstatus() async {
      await SQLHelper.createlockstatus(1, user, _passcodeController.text, 'true');
      _Fetchlockstatus();
  }

  void _UnSetlockstatus() async {
    await SQLHelper.deleteAlllockstatus();
    _Fetchlockstatus();
  }

  void _Fetchlockstatus() async {
    final data = await SQLHelper.getlockstatus();
    setState(() {
      _journals = data;
      if (_journals[0]['token'] == 'true') {
        _pass = true;
      }else {
        _pass = false;
      }
    });
    print('sqliteから取得');
    print(_journals);
  }
}