import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/photosettings.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';
import 'developer.dart';

class Changepass extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Changepass> {
  final _oldpassword = TextEditingController();
  final _newpassword = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationController = TextEditingController();
  var user = [];
  var userstring = "";
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
        title: Text("セキュリティ"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(user[0])
      ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.mail_outline),
                hintText: 'oldpassword',
                labelText: '旧パスワード',
              ),
              controller: _oldpassword,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.vpn_key),
                hintText: 'newpassword',
                labelText: '新パスワード',
              ),
              controller: _newpassword,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('パスワード変更'),
              color: Colors.indigo,
              shape: StadiumBorder(),
              textColor: Colors.white,
              onPressed: () => _ChangePass(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('パスワードリセット'),
              color: Colors.indigo,
              shape: StadiumBorder(),
              textColor: Colors.white,
              onPressed: () => _ResetPass(),
            ),
          ),
        ],
      ),
    );
  }

  void _ChangePass() async {
    try {
      print("oldpass: ${_oldpassword.text}");
      print("newpass: ${_newpassword.text}");
      await Amplify.Auth.updatePassword(
          oldPassword: _oldpassword.text, newPassword: _newpassword.text
      );
      _confirmsucess();
    } on AuthException {
      _confirmfaild();
    }
  }

  void _confirmsucess() async {
    print("パスワード変更成功しました。");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('パスワードを変更しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmfaild() async {
    print("パスワード変更エラー");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('パスワード変更に失敗しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _ResetPass() async {
    try {
      print('user: ${userstring}');
      await Amplify.Auth.resetPassword(username: userstring);
      _showForm();
      _confirminfo();
    } on AuthException {
      _confirmfaild();
    }
  }

  void _resetsucess() async {
    print("パスワードを初期化しました。");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('パスワードを初期化しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _resetfaild() async {
    print("パスワード初期化エラー");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('パスワード初期化に失敗しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmReset() async {
    try {
      await Amplify.Auth.confirmPassword(
          username: userstring,
          newPassword: _passwordController.text,
          confirmationCode: _verificationController.text
      );
      Navigator.pop(context);
      _resetsucess();
    } on AmplifyException catch (e) {
      _resetfaild();
      print(e);
    }
  }

  void _confirminfo() async {
    print("新規登録申請しました。");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('メールアドレスに送信しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
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
                hintText: 'newpassword',
                labelText: '新パスワード',
              ),
              controller: _passwordController,
            ),
          ),
          Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8.0),
          child:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.vpn_key),
                hintText: '012345',
                labelText: '確認コード',
              ),
              controller: _verificationController,
            ),
          ),
      ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('コード再送信'),
              color: Colors.orangeAccent,
              shape: StadiumBorder(),
              textColor: Colors.white,
              onPressed: () => _Resendcode(),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('コード承認'),
              color: Colors.orangeAccent,
              shape: StadiumBorder(),
              textColor: Colors.white,
              onPressed: () => _confirmReset(),
            ),
          ),
        ]
      )
    );
  }

  void _Resendcode() async {
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

  void checkUser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        setState(() {
          userstring = attribute.value;
          user = attribute.value.split('@');
        });
      }
    }
  }
}