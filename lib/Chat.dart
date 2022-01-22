import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';

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
  late int len;
  late String user = "";
  late String lastchat = "";
  var username = [];
  late Map<String, String> _getUrlResult = {};

  @override
  void initState() {
    super.initState();
    _currentuser();
      _LoadData();
      _LoadData();
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: chatList.length,
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
                                        image: (_getUrlResult[chatList[index]
                                                    ['name']] ==
                                                null)
                                            ? NetworkImage(
                                                'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                            : NetworkImage(_getUrlResult[
                                                    chatList[index]['name']]
                                                as String)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50.0)),
                                    color: Colors.orange[200],
                                  ),
                                ),
                                Center(
                                  child: Row(children: [
                                    Padding(padding: const EdgeInsets.all(5.0)),
                                    Text(chatList[index]['name']),
                                    Padding(
                                        padding: const EdgeInsets.all(30.0)),
                                    (status(chatList[index]['name']) ==
                                                chatList[index]['name'] ||
                                            status(chatList[index]['name']) ==
                                                username)
                                        ? Card(
                                            elevation: 100,
                                            color: Colors.orange[200],
                                            margin: EdgeInsets.all(15),
                                            child: Text(lastchat))
                                        : Text(''),
                                  ]),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        Chatdetails(chatList[index]['name']))),
              )),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _showFormList();
            this._scaffoldKey.currentState;
          }),
    );
  }

  Future _LoadData() async{
    await Future.delayed(Duration(seconds: 2));
    getAlluser();
    getUrlall();
    fetchChatuser();
    _fetch();
  }

  void _showFormList() async {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (_) => ListView.builder(
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
                            TextButton(
                                onPressed: () {
                                  addChatuser(userList[index]['owner']);
                                  Navigator.of(context).pop();
                                },
                                child: Text(userList[index]['owner']))
                          ],
                        ),
                      ],
                    ),
                  ),
                )));
  }

  void _scrollToBottom() {
    ScrollController _scrollController = new ScrollController();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent +
          MediaQuery.of(context).viewInsets.bottom,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
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
      ownerMap = {};
      userList = [];
      chatList = [];
      final chatListList = map['listOwners']['items'];
      setState(() {
        final username = user.split("@");
        for (int i = 0; i < len; i++) {
          final ownerMapList = map['listOwners']['items'][i]['owner'];
          final chatListList = map['listOwners']['items'];
          ownerMap.add(ownerMapList);
          final chatList = map['listOwners']['items'];
          if (chatListList[i]['owner'] == username[0]) {
            print('chatListList: ${chatListList[i]['owner']}');
          } else {
            userList.toSet().toList();
            for(int j=0;j<chatList.length;j++) {
              if (userList[i]['owner'] == chatList[j]['owner'])
                userList.add(chatList[i]);
            }
          }
        }
      });
      print('ownerMap: ${ownerMap}');
      print('userList: ${userList}');
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
          setState(() {
            user = attribute.value;
          });
        }
      }
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

  void addChatuser(user) async {
    try {
      String graphQLDocument =
          '''mutation CreateChatList(\$name: String, \$owner: String) {
              createChatList(input: {name: \$name, owner: \$owner}) {
                name
                owner
              }
        }''';

      var variables = {
        "name": user,
        "owner": username[0],
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      fetchChatuser();
      print('result_addChatuse: ' + data);
    } on ApiException catch (e) {
      print('failed_addChatuse: $e');
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

  void fetchChatuser() async {
    try {
      print('getAlluser_start');
      String graphQLDocument = '''query listChatLists {
      listChatLists {
        items {
          id
          createdAt
          name
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
      len = map['listChatLists']['items'].length;
      chatList = [];
      setState(() {
        for (int i = 0; i < len; i++) {
          final ChatListList = map['listChatLists']['items'];
          if (ChatListList[i]['owner'] == username[0]) {
            chatList.add(ChatListList[i]);
          }
        }
      });
      print('chatList: ${chatList}');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _fetch() async {
    try {
      String graphQLDocument = '''query ListChats {
      listChats {
        items {
          id
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

  String? status(user) {
    for (int i = 0; i < chatMap.length; i++) {
      if (chatMap[i]['owner'] == username || chatMap[i]['owner'] == user) {
        lastchat = chatMap[i]['description'];
        print('user: ${user}');
        print('lastchat: ${chatMap[i]['description']}');
        print('lastchatowner: ${chatMap[i]['owner']}');
        return chatMap[i]['owner'];
      }
    }
  }
}
