import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

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
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                  child: Text("ユーザー:   ${user ==""? "ログインしていません": user}" , style: TextStyle(color: Colors.white)),
                  color: Colors.indigo,
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('サインアウト'),
                  color: Colors.indigo,
                  shape: StadiumBorder(),
                  textColor: Colors.white,
                  onPressed: () => _signOut(),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                    child: Text('ログイン画面へ'),
                    color: Colors.indigo,
                    shape: StadiumBorder(),
                    textColor: Colors.white,
                    onPressed: _isEnabled ? ()
                    //true
                    {
                      Navigator
                          .pushNamedAndRemoveUntil(
                          context, "/login", (_) => false);
                    } :
                    //false
                    null
                ),
              ),
            ]),
      ),
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