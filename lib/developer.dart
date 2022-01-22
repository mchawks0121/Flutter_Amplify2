import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/sqlite/Login_sql_helper.dart';
import 'package:flutter/material.dart';

class Developer extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Developer> {
  late int len;
  List<dynamic> itemMap = [];
  Set<dynamic> ownerMap = {};
  Set<dynamic> GoodMap = {};
  List<dynamic> Goods = [];
  late AuthDevice fetch_device;
  String Deviceinfo = "";
  List<dynamic> Devicename = [];
  List<Map<String, dynamic>> _journals = [];

  @override
  void initState() {
    super.initState();
    getAlluser();
    _refreshJournals();
    FetchDevice();
    _getgood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("開発者用画面"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text('登録済みユーザー表示中...'),
          ),
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: ownerMap.length,
              itemBuilder: (context, index) => Card(
                  elevation: 10,
                  color: Colors.orange[200],
                  margin: EdgeInsets.all(15),
                  child: Column(children: [
                    Text(ownerMap.elementAt(index),
                        style: TextStyle(color: Colors.black))
                  ])),
            ),
          ),
          Container(
            child: Text('ログインセッション表示中...'),
          ),
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                  elevation: 10,
                  color: Colors.orange[200],
                  margin: EdgeInsets.all(15),
                  child: Column(children: [
                    Text(_journals[index]['owner'],
                        style: TextStyle(color: Colors.black)),
                    Text(_journals[index]['token'],
                        style: TextStyle(color: Colors.black)),
                  ])),
            ),
          ),
          Container(
            child: Text('アカウント情報'),
          ),
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) => Card(
                  elevation: 100,
                  color: Colors.orange[200],
                  margin: EdgeInsets.all(15),
                  child: Column(children: [
                    Text(Deviceinfo, style: TextStyle(color: Colors.black)),
                  ])),
            ),
          ),
          Container(
            child: Text('Good情報'),
          ),
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) => Card(
                  elevation: 100,
                  color: Colors.orange[200],
                  margin: EdgeInsets.all(15),
                  child: Column(children: [
                    Text(Goods.toString(),
                        style: TextStyle(color: Colors.black)),
                  ])),
            ),
          ),
          TextButton(
            onPressed: () {
              AllAwsResourcesdelete();
            },
            child: Text('AWSリソース削除'),
          ),
        ],
      ),
    );
  }

  void AllAwsResourcesdelete() async {
    _deleteThread();
    _delete();
    deleteLiked();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('AWSリソースを全削除しました!'),
    ));
  }

  void deleteLiked() async {
    try {
      String graphQLDocument =
      '''mutation deleteLiked(\$id: ID!) {
              deleteLiked(input: { id: \$id }) {
                owner
                commentId
              }
        }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {}));
      var response = await operation.response;
      var data = response.data;
      print('Likedresult: ' + data);
    } on ApiException catch (e) {
      print('Likedfailed: $e');
    }
  }

  void _delete() async {
    try {
      String graphQLDocument = '''mutation deleteTodo(\$id: ID!) {
          deleteTodo(input: { id: \$id }) {
            id
            name
            description
            owner
            count
            edited
            good
            createdAt
            updateAt
          }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {}));
      var response = await operation.response;
      var data = response.data;
      print("Success-delete_item: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete_item: ${e}");
    }
  }

  void _deleteThread() async {
    try {
      String graphQLDocument = '''mutation deleteThread(\$id: ID!) {
          deleteThread(input: { id: \$id }) {
            id
            subject
            owner
            comment
            createdAt
          }
    }''';
      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {}));
      var response = await operation.response;
      var data = response.data;
      print("Success-delete_thread: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete_thread: ${e}");
    }
  }

  void getAlluser() async {
    try {
      print('getAlluser_start');
      String graphQLDocument = '''query listOwners {
      listOwners {
        items {
          id
          createdAt
          owner
          updatedAt
        }
        nextToken
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));
      var response = await operation.response;

      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listOwners']['items'].length;
      ownerMap = {};
      setState(() {
        for (int i = 0; i < len; i++) {
          final List = map['listOwners']['items'][i]['owner'];
          ownerMap.add(List);
        }
      });
      print('getAlluser: ${ownerMap}');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
    });
    print('sqliteから取得');
    print(_journals[0]['token']);
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
        print('devicename: ${Deviceinfo}');
      }
    } on Exception catch (e) {
      print('Fetch devices failed with error: $e');
    }
  }

  void _getgood() async {
    try {
      String graphQLDocument = '''query listGoods {
      listGoods {
        items {
          id
          name
          commentId
        }
        nextToken
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));
      var response = await operation.response;
      Map<String, dynamic> map = jsonDecode(response.data);
      GoodMap = {};
      Goods = [];
      setState(() {
        final List = map['listGoods']['items'];
        //GoodMap.add(List);
        Goods.add(List);
      });
      print('Goods: ${Goods.toString()}');
      print(map['listGoods']);
    } on ApiException catch (e) {
      print('失敗: $e');
    }
  }
}
