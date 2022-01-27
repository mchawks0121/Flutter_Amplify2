import 'dart:async';

import 'package:flutter/material.dart';

import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';

import 'RandomChatSetting.dart';

class RandomChatSettings extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<RandomChatSettings> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  List<String>? digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("ランダムチャットの設定"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Center(
              child: TextButton(
                  onPressed: () => _showLockScreen(
                        context,
                        opaque: false,
                        cancelButton: Text(
                          'Cancel',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                          semanticsLabel: 'Cancel',
                        ),
                      ),
                  child: Text('権限が必要です')))
        ],
      ),
    );
  }

  _showLockScreen(
    BuildContext context, {
    required bool opaque,
    CircleUIConfig? circleUIConfig,
    KeyboardUIConfig? keyboardUIConfig,
    required Widget cancelButton,
    List<String>? digits,
  }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: Text(
              'パスコード',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
            passwordDigits: 4,
          ),
        ));
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  _onPasscodeEntered(String enteredPasscode) async {
    bool isValid = ('0121' == enteredPasscode);
    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => RandomChatSetting()),
              (_) => true);
      //_authenticate();
    } else {
      _authenticaterror();
    }
  }

  void _authenticate() async {
    print("ようこそ管理者さん");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ようこそ管理者さん'),
      ),
    );
  }

  void _authenticaterror() async {
    print("権限がありません");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('権限認証できません'),
      ),
    );
  }
}