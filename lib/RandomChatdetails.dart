import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Tab.dart';

class RandomChatdetails extends StatefulWidget {
  String list;

  RandomChatdetails(this.list);

  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<RandomChatdetails>
    with TickerProviderStateMixin {
  final _chattextInputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> RandomchatMap = [];
  late int len;
  final _formKey = GlobalKey<FormState>();
  var username;
  var deleteid;
  late String roomcrypto1;
  Set<dynamic> ownerMap = {};
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
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("${widget.list}とのチャット"),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.exitRun),
              onPressed: () => {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('トーク退出'),
                    content: const Text(
                      '退出すると全てのトーク履歴が削除されます。',
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      FlatButton(
                        onPressed: () => _delete(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                )
              },
            ),
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () => {_loadData()},
            ),
          ]),
      body: SizedBox(
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                reverse: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: RandomchatMap.length,
                itemBuilder: (context, index) => Column(children: [
                      (RandomchatMap.length != 0)
                          ? (RandomchatMap[index]['room'] ==
                                      crypt('${username[0] + widget.list}') ||
                                  RandomchatMap[index]['room'] ==
                                      crypt('${widget.list + username[0]}'))
                              ? (RandomchatMap[index]['to'] == widget.list ||
                                      RandomchatMap[index]['to'] == username[0])
                                  ? (RandomchatMap[index]['owner'] ==
                                          username[0])
                                      ? Container(
                                          alignment: Alignment.centerRight,
                                          child: Card(
                                            margin: EdgeInsets.only(
                                                top: 5.0,
                                                left: 100.0,
                                                bottom: 5.0,
                                                right: 8.0),
                                            color: Colors.orange[100],
                                            child: Column(
                                                //crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                        RandomchatMap[index]
                                                            ['description'],
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                    subtitle: Text(
                                                        RandomchatMap[index]
                                                            ['createdAt'],
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 8.5)),
                                                    trailing: Container(
                                                      width: 30.0,
                                                      height: 30.0,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: (_getUrlResult[
                                                                        RandomchatMap[index]
                                                                            [
                                                                            'owner']] ==
                                                                    null)
                                                                ? NetworkImage(
                                                                    'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                                                : NetworkImage(_getUrlResult[
                                                                        RandomchatMap[index]
                                                                            [
                                                                            'owner']]
                                                                    as String)),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50.0)),
                                                        color:
                                                            Colors.orange[200],
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                  ),
                                                  SimpleUrlPreview(
                                                    isClosable: true,
                                                    bgColor: Colors.orange[200],
                                                    url: _URLLink(RandomchatMap[
                                                                        index][
                                                                    'description'])
                                                                .toString() !=
                                                            ""
                                                        ? _URLLink(RandomchatMap[
                                                                    index]
                                                                ['description'])
                                                            .toString()
                                                        : "",
                                                    titleStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                        RandomchatMap[index]
                                                            ['description']),
                                                  ),
                                                ]),
                                          ))
                                      : Container(
                                          alignment: Alignment.centerLeft,
                                          child: Card(
                                            color: Colors.greenAccent[100],
                                            margin: EdgeInsets.only(
                                                top: 5.0,
                                                left: 8.0,
                                                bottom: 5.0,
                                                right: 100.0),
                                            child: Column(
                                                //crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                        RandomchatMap[index]
                                                            ['description'],
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                    subtitle: Text(
                                                        RandomchatMap[index]
                                                            ['createdAt'],
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 8.5)),
                                                    leading: Container(
                                                      width: 30.0,
                                                      height: 30.0,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: (_getUrlResult[
                                                                        RandomchatMap[index]
                                                                            [
                                                                            'owner']] ==
                                                                    null)
                                                                ? NetworkImage(
                                                                    'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                                                : NetworkImage(_getUrlResult[
                                                                        RandomchatMap[index]
                                                                            [
                                                                            'owner']]
                                                                    as String)),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50.0)),
                                                        color:
                                                            Colors.orange[200],
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                  ),
                                                  SimpleUrlPreview(
                                                    isClosable: true,
                                                    bgColor:
                                                        Colors.greenAccent[200],
                                                    url: _URLLink(RandomchatMap[
                                                                        index][
                                                                    'description'])
                                                                .toString() !=
                                                            ""
                                                        ? _URLLink(RandomchatMap[
                                                                    index]
                                                                ['description'])
                                                            .toString()
                                                        : "",
                                                    titleStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                        RandomchatMap[index]
                                                            ['description']),
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
                  child: Column(children: <Widget>[
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
                                onTap: () {
                                  // タイマーを入れてキーボード分スクロールする様に
                                  Timer(
                                    Duration(milliseconds: 200),
                                    _scrollToBottom,
                                  );
                                },
                              )),
                              Material(
                                color: Colors.orange[100],
                                child: Row(children: [
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
                                        Timer(
                                          Duration(milliseconds: 200),
                                          _scrollToBottom,
                                        );
                                      },
                                    ),
                                  ),
                                ]),
                              )
                            ])),
                  ])),
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
          '''mutation CreateRandomChat(\$owner: String, \$description: String, \$to: String, \$room: String, \$count: Int!, \$createdAt: String) {
              createRandomChat(input: {owner: \$owner, description: \$description, to: \$to, room: \$room, count: \$count, createdAt: \$createdAt}) {
                id
                owner
                description
                to
                room
                count
                createdAt
              }
        }''';

      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('MM-dd-Hm');
      String date = outputFormat.format(now);

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      str = user.split('@');
      var count = len + 1;
      var room = crypt(username[0] + widget.list);
      var variables = {
        "owner": str[0],
        "description": _chattextInputController.text,
        "to": widget.list,
        "room": room,
        "count": count,
        "createdAt": date,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      _fetch();
      _chattextInputController.text = '';
      print('result: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _fetch() async {
    try {
      String graphQLDocument = '''query ListRandomChats {
      listRandomChats {
        items {
          id
          owner
          description
          to
          room
          count
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
      len = map['listRandomChats']['items'].length;
      RandomchatMap = [];
      setState(() {
        RandomchatMap = map['listRandomChats']['items'];
        RandomchatMap.sort(
            (a, b) => -a['count'].compareTo(b['count'])); //要素countで逆順ソート
        print('RandomchatMap: $RandomchatMap');
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _delete() async {
    try {
      String graphQLDocument = '''mutation deleteRandomChat(\$id: ID!) {
          deleteRandomChat(input: { id: \$id }) {
          id
          owner
          description
          to
          room
          count
          createdAt
          }
    }''';

      for (int i = 0; i < RandomchatMap.length; i++) {
        if (RandomchatMap[i]['room'] == crypt('${username[0] + widget.list}') ||
            RandomchatMap[i]['room'] == crypt('${widget.list + username[0]}')) {
          deleteid = RandomchatMap[i]['id'];
          print('deleteid: $deleteid');
          var operation = Amplify.API.mutate(
              request: GraphQLRequest<String>(
                  document: graphQLDocument, variables: {'id': deleteid}));
          var response = await operation.response;
          var data = response.data;
          print("Success-delete_item: ${data}");
        }
      }
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => TabPage()), (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('エントリー情報を削除しました!'),
      ));
    } on AuthException catch (e) {
      print("Faild-delete_item: ${e}");
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
        });
      }
    }
  }

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateRandomChat {
        onCreateRandomChat {
          id
          owner
          description
          to
          room
          count
          createdAt
        }
      }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            var eventname = data['onRandomCreateChat']['name'];
            var eventdata = data['onRandomCreateChat']['description'];
            print(
                'CreateRandomSubscription event data received: ${event.data}');
            var creator = username;
            if (creator[0] != eventname) {
              //setNotification('[作成]: $eventname', eventdata);
            }
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
    print('chatMap: $RandomchatMap');
    print('roomcrypto1; ${roomcrypto1}');
    return roomcrypto1;
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
