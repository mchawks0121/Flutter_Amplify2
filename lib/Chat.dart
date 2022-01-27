import 'dart:convert';
import 'dart:math';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'Chatdetails.dart';

class MyChat extends StatefulWidget {
  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> with TickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Set<dynamic> ownerMap = {};
  List<dynamic> chatList = [];
  List<dynamic> userList = [];
  List<dynamic> chatMap = [];
  late String roomcrypto1;
  late int len;
  late String user = "";
  Map<String, dynamic> lastchat = {};
  late String lasttime = "";
  var username = [];
  late Map<String, String> _getUrlResult = {};
  Map<String, dynamic> chatuserlist = {};

  @override
  void initState() {
    super.initState();
    _currentuser();
    getAlluser();
    getUrlall();
    _LoadData();
  }

  void didPopNext() {
    _LoadData();
  }

  @override
  Widget build(BuildContext context) {
    _subscribeCreate();
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("チャット"),
          actions: [
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () => {_LoadData()},
            ),
          ]),
      body: (userList.length == 0)
          ? Text('表示されない場合は右上の更新ボタンを押してください')
          : ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: userList.length,
              itemBuilder: (context, index) => GestureDetector(
                    child: Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(padding: const EdgeInsets.all(10.0)),
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: (_getUrlResult[userList[index]
                                                  ['owner']] ==
                                              null)
                                          ? NetworkImage(
                                              'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                          : NetworkImage(_getUrlResult[
                                                  userList[index]['owner']]
                                              as String)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50.0)),
                                  color: Colors.orange[200],
                                ),
                              ),
                              Center(
                                child: Column(children: [
                                  Padding(padding: const EdgeInsets.all(5.0)),
                                  Row(
                                    children: [
                                      Text(userList[index]['owner'],
                                          style:
                                              TextStyle(color: Colors.black)),
                                      Padding(
                                          padding: const EdgeInsets.all(5.0)),
                                      (lastchatstatus(
                                                  userList[index]['owner']) !=
                                              null)
                                          ? Text(lasttime,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8))
                                          : Text(''),
                                    ],
                                  ),
                                  (lastchatstatus(userList[index]['owner']) !=
                                          null)
                                      ? (lastchat['owner'] == username[0])
                                          ? Row(children: [
                                              Card(
                                                  elevation: 100,
                                                  color: Colors.orange[100],
                                                  margin: EdgeInsets.all(10),
                                                  child: Text(
                                                    lastchat['description'],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13),
                                                    textAlign: TextAlign.left,
                                                  )),
                                              (Unreadcheck(
                                                          crypt(username[0] +
                                                              userList[index]
                                                                  ['owner']),
                                                          crypt(userList[index]
                                                                  ['owner'] +
                                                              username[0])) ==
                                                      true)
                                                  ? Text('●',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                      textAlign:
                                                          TextAlign.right)
                                                  : Text('')
                                            ])
                                          : Row(children: [
                                              Card(
                                                  elevation: 100,
                                                  color:
                                                      Colors.greenAccent[100],
                                                  margin: EdgeInsets.all(10),
                                                  child: Text(
                                                    lastchat['description'],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13),
                                                    textAlign: TextAlign.left,
                                                  )),
                                              (Unreadcheck(
                                                          crypt(username[0] +
                                                              userList[index]
                                                                  ['owner']),
                                                          crypt(userList[index]
                                                                  ['owner'] +
                                                              username[0])) ==
                                                      true)
                                                  ? Text('●',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                      textAlign:
                                                          TextAlign.right)
                                                  : Text('')
                                            ])
                                      : Text(''),
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            Chatdetails(userList[index]['owner']))),
                  )),
    );
  }


  void setIconBadge(number) async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.updateBadgeCount(number ?? 0);
    }
  }

  Future _LoadData() async {
    _currentuser();
    _fetch();
    getAlluser();
    getUrlall();
  }

  void getAlluser() async {
    try {
      String graphQLDocument = '''query listOwners {
      listOwners {
        items {
          id
          createdAt
          owner
          count
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
      userList = [];
      ownerMap = {};
      setState(() {
        for (int i = 0; i < map['listOwners']['items'].length; i++) {
          final data = map['listOwners']['items'];
          if (data[i]['owner'] == username[0]) {
          } else {
            userList.add(data[i]);
          }
          final ownerMapList = map['listOwners']['items'][i]['owner'];
          ownerMap.add(ownerMapList);
        }
        print('userListソート前: $userList');
        userList
            .sort((a, b) => -a['updatedAt'].compareTo(b['updatedAt'])); //要素countで逆順ソート
        print('userListソート後: $userList');
      });
      print('userList: ${userList}');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  bool? Unreadcheck(roomid1, roomid2) {
    print('unread: ${chatMap[0]['unread']}');
    for (int i = 0; i < chatMap.length; i++) {
      if (chatMap[i]['unread'] == 'false' && chatMap[i]['to'] == username[0]) {
        if (chatMap[i]['room'] == roomid1 || chatMap[i]['room'] == roomid2) {
          print('Unreadcheck: true');
          print('userList: $userList');
          return true;
        }
      }
    }
    print('Unreadcheck: false');
    return false;
  }

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateChat {
        onCreateChat {
          id
          ownerid
          owner
          description
          to
          room
          count
          good
          unread
          createdAt
        }
      }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
          },
          onEstablished: () {
            print('CreateSubscription established');
          },
          onError: (e) {
            print('Subscription failed with error: $e');
          },
          onDone: () {
            print('Subscription has been closed successfully');
          });
    } on ApiException catch (e) {
      print('Failed to establish subscription: $e');
    }
  }

  void getUrlall() async {
    _getUrlResult = {};
    try {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
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

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey == 'email') {
        setState(() {
          final user = attribute.value;
          username = user.split('@');
        });
      }
    }
  }

  void _fetch() async {
    try {
      String graphQLDocument = '''query ListChats {
      listChats {
        items {
          id
          ownerid
          owner
          description
          to
          room
          count
          good
          unread
          createdAt
        }
        nextToken
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));
      var response = await operation.response;
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      Map<String, dynamic> map = jsonDecode(response.data);
      chatMap = [];
      setState(() {
        chatMap = map['listChats']['items'];
        chatMap
            .sort((a, b) => -a['count'].compareTo(b['count'])); //要素countで逆順ソート
        print('chatMap: $chatMap');
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  String? lastchatstatus(user) {
    final data = chatMap;
    chatMap = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i]['owner'] == username[0] || data[i]['to'] == username[0]) {
        chatMap.add(data[i]);
      }
    }
    for (int i = 0; i < chatMap.length; i++) {
      if (chatMap[i]['to'] == user || chatMap[i]['owner'] == user) {
        lastchat = chatMap[i];
        lasttime = chatMap[i]['createdAt'];
        print('user: ${user}');
        print('lastchat: ${chatMap[i]['description']}');
        print('lastchatowner: ${chatMap[i]['owner']}');
        print('lastchatstatuschatMap: ${chatMap[i]}');
        return chatMap[i]['owner'];
      }
    }
  }

  String? crypt(string) {
    final room1 = utf8.encode(string);
    roomcrypto1 = sha256.convert(room1).toString();
    print('chatMap: $chatMap');
    print('roomcrypto1; ${roomcrypto1}');
    return roomcrypto1;
  }
}
