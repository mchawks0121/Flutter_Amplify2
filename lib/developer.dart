import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:fluamp/photosettings.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:package_info/package_info.dart';

class Developer extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Developer> {
  late int len;
  List<dynamic> itemMap = [];
  Set<dynamic> ownerMap = {};

  @override
  void initState() {
    super.initState();
    getAlluser();
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
          child: Text('ownerMapの中身を表示中...'),
      ),
      Expanded(
      child: ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
        itemCount: ownerMap.length,
        itemBuilder: (context, index)=>Text(ownerMap.elementAt(index)),
      ),),],
      ),
    );
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
      ownerMap= {};
      setState(() {
        for(int i=0;i<len;i++) {
          final List = map['listOwners']['items'][i]['owner'];
          ownerMap.add(List);
        }
      });
      print('getAlluser: ${ownerMap}');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }
}