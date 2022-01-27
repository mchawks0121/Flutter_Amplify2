import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:crypto/crypto.dart';
import 'package:fluamp/LikeBoard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class Chatdetails extends StatefulWidget {
  String toUser;

  Chatdetails(this.toUser);

  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<Chatdetails> with TickerProviderStateMixin {
  final _chattextInputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> chatMap = [];
  late int len;
  final _formKey = GlobalKey<FormState>();
  var username;
  var updateid;
  var ownerid;
  late String roomcrypto1;
  late String roomcrypto2;
  Set<dynamic> ownerMap = {};
  List<dynamic> ownerList = [];
  late Map<String, String> _getUrlResult = {};

  @override
  void initState() {
    super.initState();
    _currentuser();
    getAlluser();
    getUrlall();
    _fetch();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    _subscribeCreate();
    _subscribeUpdate();
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("${widget.toUser}"),
          actions: [
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () => {_loadData()},
            ),
          ]),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(child:
            ListView.builder(
            reverse: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: chatMap.length,
            itemBuilder: (context, index) => Column(children: [
                  (chatMap.length != 0)
            ?
                    (chatMap[index]['room'] == crypt('${username[0]+widget.toUser}') || chatMap[index]['room'] == crypt('${widget.toUser+username[0]}'))
                  ?
                       (chatMap[index]['to'] == widget.toUser || chatMap[index]['to'] == username[0])
                          ? (chatMap[index]['owner'] == username[0])
                              ? Container(
                                  alignment: Alignment.centerRight,
                                  child: Card(
                                    margin: EdgeInsets.only(top: 5.0, left: 100.0, bottom: 5.0, right: 8.0),
                                    color: Colors.orange[100],
                                    child: Column(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: Text(
                                                chatMap[index]['description'],
                                                textAlign: TextAlign.right,
                                                style: TextStyle(color: Colors.black)),
                                            subtitle: Text(
                                                chatMap[index]['createdAt'],
                                                textAlign: TextAlign.right,
                                                style: TextStyle(color: Colors.black,fontSize: 8.5)),
                                            trailing: Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: (_getUrlResult[chatMap[index]
                                                    ['owner']] ==
                                                        null)
                                                        ? NetworkImage(
                                                        'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                                        : NetworkImage(_getUrlResult[
                                                    chatMap[index]['owner']]
                                                    as String)),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(50.0)),
                                                color: Colors.orange[200],
                                              ),
                                            ),
                                            onTap: () {},
                                          ),
                                          SimpleUrlPreview(
                                            isClosable: true,
                                            bgColor: Colors.orange[200],
                                            url: _URLLink(chatMap[index]
                                                            ['description'])
                                                        .toString() !=
                                                    ""
                                                ? _URLLink(chatMap[index]
                                                        ['description'])
                                                    .toString()
                                                : "",
                                            titleStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            descriptionStyle: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            siteNameStyle: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            onTap: () => _launchURL(
                                                chatMap[index]['description']),
                                          ),
                                        ]),
                                  ))
                              : Container(
                                  alignment: Alignment.centerLeft,
                                  child: Card(
                                    color: Colors.greenAccent[100],
                                    margin: EdgeInsets.only(top: 5.0, left: 8.0, bottom: 5.0, right: 100.0),
                                    child: Column(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: Text(
                                                chatMap[index]['description'],
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Colors.black)),
                                            subtitle: Text(
                                                chatMap[index]['createdAt'],
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Colors.black, fontSize: 8.5)),
                                            leading: Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: (_getUrlResult[chatMap[index]
                                                    ['owner']] ==
                                                        null)
                                                        ? NetworkImage(
                                                        'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                                        : NetworkImage(_getUrlResult[
                                                    chatMap[index]['owner']]
                                                    as String)),
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(50.0)),
                                                color: Colors.orange[200],
                                              ),
                                            ),
                                            onTap: () {},
                                          ),
                                          SimpleUrlPreview(
                                            isClosable: true,
                                            bgColor: Colors.greenAccent[200],
                                            url: _URLLink(chatMap[index]
                                                            ['description'])
                                                        .toString() !=
                                                    ""
                                                ? _URLLink(chatMap[index]
                                                        ['description'])
                                                    .toString()
                                                : "",
                                            titleStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            descriptionStyle: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            siteNameStyle: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            onTap: () => _launchURL(
                                                chatMap[index]['description']),
                                          ),
                                        ]),
                                  ))
                          : SizedBox.shrink()
                      : SizedBox.shrink()
                      : Text('最初のトークです'),
                ])),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Container(
                    color: Colors.orange[100],
                    child: Column(
                        children: <Widget>[
                          new Form(
                              key: _formKey,
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    new Flexible(
                                        child: new TextFormField(
                                          controller: _chattextInputController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 5,
                                          minLines: 1,
                                          decoration: const InputDecoration(
                                            hintText: 'メッセージ',
                                          ),
                                          onTap: (){
                                            _update();
                                            // タイマーを入れてキーボード分スクロールする様に
                                            Timer(
                                              Duration(milliseconds: 200),
                                              _scrollToBottom,
                                            );
                                          },
                                        )
                                    ),
                                    Material(
                                      color: Colors.orange[100],
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.keyboard_arrow_down),
                                            color: Colors.blue,
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                          Ink(
                                          decoration: const ShapeDecoration(
                                            color: Colors.green,
                                            shape: CircleBorder(),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.send),
                                            color: Colors.white,
                                            onPressed: () {
                                              _create();
                                              _updateOwner(ownerid);
                                              Timer(
                                                Duration(milliseconds: 200),
                                                _scrollToBottom,
                                              );
                                            },
                                          ),
                                        ),
                                      ]),
                                    )
                                  ]
                              )
                          ),
                        ]
                    )
                ),
              ],
            )
          ],
        )),
    );
  }

  Future _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    _fetch();
    getAlluser();
    getUrlall();
  }

  void _create() async {
    try {
      String graphQLDocument =
          '''mutation CreateChat(\$owner: String, \$ownerid: String, \$description: String, \$to: String, \$room: String, \$count: Int!, \$good: [String], \$unread:String, \$createdAt: String) {
              createChat(input: {owner: \$owner, ownerid: \$ownerid, description: \$description, to: \$to, room: \$room, count: \$count, good: \$good, unread: \$unread, createdAt: \$createdAt}) {
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

      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('yyyy-MM-dd-Hm');
      String date = outputFormat.format(now);

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      print('chat_to: ${widget.toUser}');
      str = user.split('@');
      final emptylist = [];
      for(int i=0;i<ownerList.length;i++) {
        if(ownerList[i]['owner']==username[0]){
          ownerid = ownerList[i]['id'];
        }
      }
      var count = len + 1;
      var room = crypt(username[0]+widget.toUser);
      var variables = {
        "owner": str[0],
        "ownerid": ownerid,
        "description": _chattextInputController.text,
        "to": widget.toUser,
        "room": room,
        "count": count,
        "good": emptylist,
        "unread": false,
        "createdAt": date,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      _chattextInputController.text = '';
      print('resultid: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _update() async {
    try {
      String graphQLDocument =
      '''mutation UpdateChat(\$id: ID!, \$unread: String) {
              updateChat(input: {id: \$id, unread: \$unread}) {
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

      print('chatMap.length: ${chatMap.length}');
      for (int i = 0; i < chatMap.length; i++) {
        if(chatMap[i]['unread'] == 'false' && chatMap[i]['to']==username[0] &&chatMap[i]['owner']!=username[0]) {
          updateid = chatMap[i]['id'];
          print('updateid: $updateid');
          var operation = Amplify.API.mutate(
              request:
              GraphQLRequest<String>(document: graphQLDocument, variables: {
                'id': updateid,
                "unread": true,
              }));

          var response = await operation.response;
          var data = response.data;
          print('unread_update result: ' + data);
        }
      }
    } on ApiException catch (e) {
      print('Mutation failed: $e');
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
      var user = "";
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listChats']['items'].length;
      chatMap = [];
      setState(() {
        chatMap = map['listChats']['items'];
        chatMap
            .sort((a, b) => -a['count'].compareTo(b['count'])); //要素countで逆順ソート
        print('chatMap: $chatMap');
        _update();
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
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

  String? getSplittedURL(String message) {
    final RegExp urlRegExp = RegExp(
        r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');
    final Iterable<RegExpMatch> urlMatches = urlRegExp.allMatches(message);
    for (Match m in urlMatches) {
      return (m.group(0));
    }
  }

  String? _URLLink(uri) {
    final url = getSplittedURL(uri);
    return url;
  }

  _launchURL(uri) async {
    final url = getSplittedURL(uri);
    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey == 'email') {
        setState(() {
          final user = attribute.value;
          username = user.split('@');
          final room1 = utf8.encode('${widget.toUser+username[0]}');
          roomcrypto1 = sha256.convert(room1).toString();
          final room2 = utf8.encode('${username[0]+widget.toUser}');
          roomcrypto2 = sha256.convert(room2).toString();
        });
      }
    }
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
            //getUrlall();
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

  String? crypt(string) {
    final room1 = utf8.encode(string);
    roomcrypto1 = sha256.convert(room1).toString();
    print('chatMap: $chatMap');
    print('roomcrypto1; ${roomcrypto1}');
    return roomcrypto1;
  }

  void _updateOwner(id) async {
    try {
      String graphQLDocument =
      '''mutation UpdateOwner(\$id: ID!,\$count: Int!, \$updatedAt: String) {
              updateOwner(input: {id: \$id, count: \$count, updatedAt: \$updatedAt}) {
                id
                count
                updatedAt
              }
        }''';

      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('yyyy-MM-dd-Hm');
      String date = outputFormat.format(now);

      var operation = Amplify.API.mutate(
          request:
          GraphQLRequest<String>(document: graphQLDocument, variables: {
            'id': id,
            'count': 1,
            "updatedAt": date,
          }));

      var response = await operation.response;
      var data = response.data;
      _fetch();
      print('Mutation updateOwner: ' + data);
    } on ApiException catch (e) {
      print('Mutation updateOwner: $e');
    }
  }

  void _subscribeUpdate() async {
    try {
      String graphQLDocument = '''subscription OnUpdateOwner {
        onUpdateOwner {
        id
          createdAt
          owner
          count
          updatedAt
              }
        }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
          },
          onEstablished: () {
            //getUrlall();
            print('UpdateSubscription established');
          },
          onError: (e) {
            print('UpcateSubscription failed with error: $e');
          },
          onDone: () {
            print('Subscription has been closed successfully');
          });
    } on ApiException catch (e) {
      print('Failed to establish subscription: $e');
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
          final ownerMapList = map['listOwners']['items'][i]['owner'];
          final chatListList = map['listOwners']['items'];
          ownerMap.add(ownerMapList);
          ownerList=chatListList;
        }
      });
      print('ownerMap: ${ownerMap}');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void getUrlall() async {
    _getUrlResult = {};
    try {
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
