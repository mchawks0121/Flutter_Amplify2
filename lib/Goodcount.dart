import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';

class Goodcount extends StatefulWidget {
  List<dynamic> GoodMap;

  Goodcount(this.GoodMap);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Goodcount> {
  Set<dynamic> ownerMap = {};
  late Map<String, String> _getUrlResult = {};
  late int len;
  var user;

  @override
  void initState() {
    super.initState();
    getAlluser();
    getUrlall();
    LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("Good"),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              print('Loading');
              LoadData();
            },
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: widget.GoodMap.length,
              itemBuilder: (context, index) => Card(
                elevation: 100,
                color: Colors.orange[200],
                margin: EdgeInsets.all(15),
                child: Column(children: [
                  (widget.GoodMap != null)
                      ? Row(children: [
                    Padding(padding: const EdgeInsets.all(10.0)),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (_getUrlResult[widget.GoodMap[index]] ==
                                null)
                                ? NetworkImage(
                                'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                : NetworkImage(_getUrlResult[
                            widget.GoodMap[index]]
                            as String)),
                        borderRadius:
                        BorderRadius.all(Radius.circular(50.0)),
                        color: Colors.orange[200],
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(10.0)),
                          Text(widget.GoodMap.isEmpty
                              ? ''
                              : widget.GoodMap[index]),
                        ])
                      : Row(children: [
                          Padding(padding: const EdgeInsets.all(10.0)),
                          Container(child: Text("いいねはありません")),
                        ]),
                ]),
              ),
            ),
          ),
        )
      ]),
    );
  }

  void LoadData() async {
    getAlluser();
    getUrlall();
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

  void getUrlall() async {
    _getUrlResult = {};
    try {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          print("user's email is ${attribute.value}");
          setState(() {
            user = attribute.value;
          });
        }
      }
      print('In getUrl');
      var key = user.split("@");
      S3GetUrlOptions options = S3GetUrlOptions(
          accessLevel: StorageAccessLevel.guest, expires: 10000);
      for (int i = 0; i < ownerMap.length; i++) {
        GetUrlResult result =
        await Amplify.Storage.getUrl(key: '${ownerMap.elementAt(i)}.jpeg');
        setState(() {
          _getUrlResult
              .addAll({ownerMap.elementAt(i): '${result.url}' as String});
        });
        print(_getUrlResult[ownerMap.elementAt(i)] as String);
      }
      print('imageurl: $_getUrlResult');
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }

}