import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/photosettings.dart';
import 'package:fluamp/sqlite/Login_sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';

class MyAccount extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<MyAccount> {
  late int len;
  List<dynamic> itemMap = [];
  Set<dynamic> ownerMap = {};
  List<Map<String, dynamic>> _journals = [];
  late AuthDevice fetch_device;
  String Deviceinfo = "";
  String email = "";
  List<String> user = [];
  List<dynamic> Devicename = [];
  List<dynamic> Lastdate = [];
  String Devicedateinfo = "";
  List<dynamic> date = [];
  @override
  void initState() {
    super.initState();
    checkUser();
    FetchDevice();
    LastDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("マイアカウント"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
    children: [
          Card(
          elevation: 10,
          color: Colors.white,
          margin: EdgeInsets.all(15),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ログインユーザー", style: TextStyle(color: Colors.black)),
            Text(user[0]==""?'取得できません':user[0], style: TextStyle(color: Colors.black)),
          ]
      ),
          ),
      Card(
        elevation: 10,
        color: Colors.white,
        margin: EdgeInsets.all(15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("メールアドレス", style: TextStyle(color: Colors.black)),
              Text(email==""?'取得できません':email, style: TextStyle(color: Colors.black)),
            ]
        ),
      ),
      Card(
          elevation: 10,
          color: Colors.white,
          margin: EdgeInsets.all(15),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ログイン済みデバイス", style: TextStyle(color: Colors.black)),
            Text(Devicename.length==0?'取得できません':Devicename[0], style: TextStyle(color: Colors.black))
          ]
      ),
      ),
      Card(
        elevation: 10,
        color: Colors.white,
        margin: EdgeInsets.all(15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("最終認証日時", style: TextStyle(color: Colors.black)),
              Text(Lastdate.length==0?'取得できません':Lastdate[0], style: TextStyle(color: Colors.black))
            ]
        ),
      ),
      ]
      ),
    );
  }

  void FetchDevice() async {
    try {
      /*
      * Device: CognitoDevice{id=ap-northeast-1_68cefc69-3f7e-4d39-a66f-6df9e6f9d77d, name=Android SDK built for x86, attributes={device_status: valid, device_name: Android SDK built for x86, last_ip_used: 182.50.224.56}, createdDate=2022-01-13 12:31:52.000, lastAuthenticatedDate=2022-01-13 12:31:52.000, lastModifiedDate=2022-01-13 12:31:52.000}
      * */
      final devices = await Amplify.Auth.fetchDevices();
      for (var device in devices) {
        fetch_device = device;
        print('Device: $fetch_device');
        Deviceinfo = fetch_device.toString();
        Devicename = Deviceinfo.split('name');
        Deviceinfo = Devicename[2];
        Devicename = Deviceinfo.split(',');

        print('devicename: ${Devicename[0]}');
      }
    } on Exception catch (e) {
      print('Fetch devices failed with error: $e');
    }
  }

  void LastDate() async {
    try {
      /*
      * Device: CognitoDevice{id=ap-northeast-1_68cefc69-3f7e-4d39-a66f-6df9e6f9d77d, name=Android SDK built for x86, attributes={device_status: valid, device_name: Android SDK built for x86, last_ip_used: 182.50.224.56}, createdDate=2022-01-13 12:31:52.000, lastAuthenticatedDate=2022-01-13 12:31:52.000, lastModifiedDate=2022-01-13 12:31:52.000}
      * */
      final devices = await Amplify.Auth.fetchDevices();
      for (var device in devices) {
        fetch_device = device;
        print('Device: $fetch_device');
        Devicedateinfo = fetch_device.toString();
        Lastdate = Devicedateinfo.split('=');
        Devicedateinfo = Lastdate[4];
        Lastdate = Devicedateinfo.split(',');

        print('LadtAuthenticatedDate: ${Lastdate[0]}');
      }
    } on Exception catch (e) {
      print('Fetch devices failed with error: $e');
    }
  }


  void checkUser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        setState(() {
          email = attribute.value;
          user = email.split('@');
        });
      }
    }
  }
}