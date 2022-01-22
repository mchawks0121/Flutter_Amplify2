import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:fluamp/sqlite/MeetingId_sql_helper.dart';
import 'package:fluamp/video/Zoomindex_modified.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Goodcount.dart';

class Thread extends StatefulWidget {
  Map<String, dynamic> itemMap;

  Thread(this.itemMap);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Thread> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _commentInputController = TextEditingController();
  late int len;
  var user;
  var meetingurl;
  var meetingid;
  var meetingpass;

  var username = [];
  List<dynamic> threadMap = [];
  Set<dynamic> ownerMap = {};
  late Map<String, String> _getUrlResult = {};
  final defaultStyle = TextStyle(
    color: Colors.black,
  );
  final highlightStyle = TextStyle(
    color: Colors.blue,
  );

  @override
  void initState() {
    super.initState();
    _currentuser();
    getAlluser();
    getUrlall();
    _fetchThread();
    LoadData();
  }

  @override
  Widget build(BuildContext context) {
    _subscribeCreate();
    _subscribeUpdate();
    _subscribeDelete();
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("スレッド"),
        automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () => {
                LoadData(),
              },
            ),
          ]
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Card(
                elevation: 200,
                color: Colors.orange[200],
                margin: EdgeInsets.all(10),
                child: Column(children: [
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Row(
                    children: [
                      Padding(padding: const EdgeInsets.all(10.0)),
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: (_getUrlResult[widget.itemMap['name']] ==
                                  null)
                                  ? NetworkImage(
                                  'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                  : NetworkImage(
                                  _getUrlResult[widget.itemMap['name']]
                                  as String)),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          color: Colors.orange[200],
                        ),
                      ),
                      Padding(padding: const EdgeInsets.all(10.0)),
                      Column(
                        children: [
                          Text((widget.itemMap['name']),
                              style: TextStyle(color: Colors.black)),
                          SelectableText(widget.itemMap['createdAt'],
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                  ListTile(
                    title: SelectableText(
                      widget.itemMap['description'],
                    ),
                    trailing: SizedBox(
                      width: 10,
                    ),
                  ),
                ]),
              ),
            ),
            (threadMap.length == 0)
                ? SizedBox.shrink()
                : Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    print('Loading');
                    LoadData();
                  },
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: threadMap.length,
                    itemBuilder: (context, index) => (threadMap[index]
                    ['subject'] ==
                        widget.itemMap['id'])
                        ? Column(children: [
                      Text('|'),
                      Card(
                          elevation: 200,
                          color: Colors.orange[300],
                          margin: EdgeInsets.all(10),
                          child: Column(children: [
                            Row(
                              children: [
                                Padding(
                                    padding:
                                    const EdgeInsets.all(10.0)),
                                Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: (_getUrlResult[
                                        threadMap[index]
                                        ['owner']] ==
                                            null)
                                            ? NetworkImage(
                                            'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                            : NetworkImage(
                                            _getUrlResult[
                                            threadMap[index]
                                            ['owner']]
                                            as String)),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50.0)),
                                    color: Colors.orange[300],
                                  ),
                                ),
                                Padding(
                                    padding:
                                    const EdgeInsets.all(10.0)),
                                Column(
                                  children: [
                                    Text((threadMap[index]['owner']),
                                        style: TextStyle(
                                            color: Colors.black)),
                                    SelectableText(
                                        threadMap[index]['createdAt'],
                                        style: TextStyle(
                                            color: Colors.black)),
                                  ],
                                ),
                                Padding(
                                    padding:
                                    const EdgeInsets.all(40.0)),
                                Row(
                                  children: [
                                    (threadMap[index]['owner'] ==
                                        username[0])
                                        ? IconButton(
                                        icon: Icon(Icons.delete),
                                        iconSize: 20,
                                        onPressed: threadMap[index]
                                        ['owner'] ==
                                            username[0]
                                            ? () {
                                          _deleteThread(
                                              threadMap[index]
                                              ['id']);
                                        }
                                            : null)
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ],
                            ),
                            ListTile(
                              title: SelectableText(
                                threadMap[index]['comment'],
                              ),
                              trailing: SizedBox(
                                width: 10,
                              ),
                            ),
                            SimpleUrlPreview(
                              isClosable: true,
                              bgColor: Colors.orange[200],
                              url:
                              _URLLink(threadMap[index]['comment']).toString() != ""
                                  ? _URLLink(threadMap[index]['comment']).toString()
                                  : "",
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              descriptionStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              siteNameStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () => _launchURL(threadMap[index]['comment']),
                            ),
                            Card(
                              color: Colors.orange[100],
                              margin: EdgeInsets.all(15),
                              child:
                              Container(
                                child: Row(children: [
                                  (threadMap[index]['good'] == null)
                                      ? IconButton(
                                      icon: Icon(
                                          MdiIcons.heartPlusOutline),
                                      iconSize: 15,
                                      onPressed: () {
                                        _updategood(
                                            threadMap[index]['id'],
                                            threadMap[index]['good']);
                                      })
                                      : (getgoodststus(threadMap[index]
                                  ['good']) ==
                                      'true')
                                      ? IconButton(
                                    icon: Icon(MdiIcons.heart),
                                    iconSize: 15,
                                    onPressed: () {
                                      _updategood(
                                          threadMap[index]
                                          ['id'],
                                          threadMap[index]
                                          ['good']);
                                    },
                                  )
                                      : IconButton(
                                    icon: Icon(MdiIcons
                                        .heartPlusOutline),
                                    iconSize: 15,
                                    onPressed: () {
                                      _updategood(
                                          threadMap[index]
                                          ['id'],
                                          threadMap[index]
                                          ['good']);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.flight_takeoff),
                                    iconSize: 15,
                                    onPressed: () =>
                                    {_share(threadMap[index]['comment'])},
                                  ),

                                  (_launchZoom(threadMap[index]['comment']) ==
                                      'true')
                                      ? IconButton(
                                      icon: Icon(Icons.videocam),
                                      iconSize: 20,
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Zoomindex_modified()),
                                        );
                                        LoadData();
                                        meetingid = getSplittedZoomURL(
                                            threadMap[index]['comment']);
                                        meetingpass = getSplittedZoomPass(
                                            threadMap[index]['comment']);
                                        setZoomid();
                                        _confirminfo();
                                      })
                                      : SizedBox.shrink(),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Goodcount(threadMap[index]['good'])));
                                    },
                                    child: Text(
                                        (threadMap[index]['good'].isEmpty)
                                            ? ''
                                            : '　❤️ :  ${threadMap[index]['good'].length} 人   ＞＞',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ]),
                              ),
                            )])),
                    ])
                        : SizedBox.shrink(),
                  ),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _showForm();
            this._scaffoldKey.currentState;
          }),
    );
  }

  void _showForm() async {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        builder: (_) => Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            width: double.infinity,
            child: Stack(alignment: Alignment.bottomRight, children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  TextFormField(
                    onTap: () {
                      Timer(
                        Duration(milliseconds: 200),
                        _scrollToBottom,
                      );
                    },
                    maxLines: null,
                    //style: TextStyle(backgroundColor: )
                    controller: _commentInputController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        icon: Icon(Icons.comment),
                        hintText: '内容',
                        labelText: 'コメント *'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                  ),
                  ElevatedButton.icon(
                      icon: Icon(Icons.reply),
                      onPressed: () async {
                        _createThread(widget.itemMap['id']);
                        Navigator.of(context).pop();
                      },
                      label: Text(''))
                ],
              ),
            ])));
  }

  void LoadData() async {
    _currentuser();
    getAlluser();
    getUrlall();
    _fetchThread();
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
          user = attribute.value;
          username = user.split('@');
          print('username: $username');
          print('commentowner: ${threadMap[0]['owner']}');
        });
      }
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

  void _createThread(id) async {
    try {
      String graphQLDocument =
      '''mutation CreateThread(\$subject: String!, \$owner: String, \$count: Int!, \$comment: String!, \$good: [String], \$createdAt: String) {
              createThread(input: {subject: \$subject, owner: \$owner, count: \$count, comment: \$comment, good: \$good, createdAt: \$createdAt}) {
                id
                subject
                owner
                count
                good
                comment
                createdAt
              }
        }''';
      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('yyyy-MM-dd-Hm');
      String date = outputFormat.format(now);

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      final emptylist = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      str = user.split('@');
      var count = len + 1;
      var variables = {
        "subject": id,
        "owner": str[0],
        "count": count,
        "good": emptylist,
        "comment": _commentInputController.text,
        "createdAt": date,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;
      _commentInputController.text = "";
      var data = response.data;
      print('result: ' + data);
      _fetchThread();
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _deleteThread(id) async {
    try {
      String graphQLDocument = '''mutation deleteThread(\$id: ID!) {
          deleteThread(input: { id: \$id }) {
            id
            subject
            owner
            count
            good
            comment
            createdAt
          }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {'id': id}));
      var response = await operation.response;
      var data = response.data;
      _fetchThread();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('スレッドを削除しました!'),
      ));
      print("Success-delete: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete: ${e}");
    }
  }

  void _fetchThread() async {
    try {
      String graphQLDocument = '''query ListThreads {
      listThreads {
        items {
          id
                subject
                owner
                count
                good
                comment
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
      List<String> userstr = user.split('@');
      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listThreads']['items'].length;
      threadMap = [];
      setState(() {
        threadMap = map['listThreads']['items'];
        threadMap
            .sort((a, b) => a['count'].compareTo(b['count'])); //要素countで逆順ソート
        print('threadMap: $threadMap');
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _updategood(id, goodList) async {
    var flag = true;
    final gooduser = user.split('@');
    print('gooduser: $gooduser');
    for (int i = 0; i < goodList.length; i++) {
      print('goodList: ${goodList[i]}');
      if (goodList[i] == gooduser[0]) {
        flag = false;
      }
    }
    if (flag == true) {
      goodList.add(gooduser[0]);
      try {
        String graphQLDocument =
        '''mutation UpdateThread(\$id: ID!, \$good: [String]) {
              updateThread(input: {id: \$id, good: \$good}) {
                id
                good
              }
        }''';

        print('goodlist: $goodList');
        var operation = Amplify.API.mutate(
            request:
            GraphQLRequest<String>(document: graphQLDocument, variables: {
              'id': id,
              "good": goodList,
            }));

        var response = await operation.response;
        var data = response.errors;
        _fetchThread();

        print('_updateThreadgood result: ' + data.toString());
      } on ApiException catch (e) {
        print('MutationThread failed: $e');
      }
    } else {
      print('${gooduser}はgood済みです');
      try {
        String graphQLDocument =
        '''mutation UpdateThread(\$id: ID!,\$good: [String]) {
              updateThread(input: {id: \$id, good: \$good}) {
                id
                good
              }
        }''';

        goodList.removeWhere((dynamic value) => value == gooduser[0]);
        var operation = Amplify.API.mutate(
            request:
            GraphQLRequest<String>(document: graphQLDocument, variables: {
              'id': id,
              "good": goodList,
            }));

        var response = await operation.response;
        var data = response.data;
        _fetchThread();

        print('_updateThreadgood result: ' + data);
      } on ApiException catch (e) {
        print('MutationThread failed: $e');
      }
    }
  }

  String? getgoodststus(good) {
    final len = good.length;
    final username = user.split('@');
    for (int i = 0; i < len; i++) {
      print('比較: ${username[0]}, ${good[i]}');
      if (good[i] == username[0]) {
        print('他の人がいいねしてますので');
        return 'true';
      }
    }
    return 'false';
  }

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateThread {
        onCreateThread {
          id
                subject
                owner
                count
                good
                comment
                createdAt
        }
      }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetchThread();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            var eventname = data['onCreateThread']['owner'];
            var eventdata = data['onCreateThread']['comment'];
            print('CreateSubscription event data received: ${event.data}');
            var creator = user.split('@');
            if (creator[0] != eventname) {}
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

  void _subscribeUpdate() async {
    try {
      String graphQLDocument = '''subscription OnUpdateThread {
        onUpdateThread {
                id
                subject
                owner
                count
                good
                comment
                createdAt
              }
        }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetchThread();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            print('UpdateSubscription event data received: ${data}');
            var eventname = data['onUpdateTodo']['name'] as String;
            var eventdata = data['onUpdateTodo']['description'] as String;
            var creator = user.split('@');
            if (creator[0] != eventname) {
              print(eventname);
              print(eventdata);
            }
          },
          onEstablished: () {
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

  void _subscribeDelete() async {
    try {
      String graphQLDocument = '''subscription OnDeleteThread {
        onDeleteThread {
          id
                subject
                owner
                count
                good
                comment
                createdAt
          }
    }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetchThread();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            var eventname = data['onDeleteThread']['owner'];
            var eventdata = data['onDeleteThread']['comment'];
            print('DeleteSubscription event data received: ${event.data}');
            var creator = user.split('@');
            if (creator[0] != eventname) {}
          },
          onEstablished: () {
            print('DeleteSubscription established');
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

  void _share(code) async {
    Share.share(code);
  }

  String? getSplittedZoomURL(String message) {
    final RegExp urlRegExp = RegExp('(?:ミーティングID: [0-9]{0,11})');
    final Iterable<RegExpMatch> urlMatches = urlRegExp.allMatches(message);
    for (Match m in urlMatches) {
      meetingid = m.group(0);
      final id = meetingid.split('ミーティングID:');
      return id[1];
    }
  }

  String? getSplittedZoomPass(String message) {
    final RegExp urlRegExp = RegExp('(?:パスコード: [!-~]{6})');
    final Iterable<RegExpMatch> urlMatches = urlRegExp.allMatches(message);
    for (Match m in urlMatches) {
      final pass = m.group(0);
      final passchange = pass!.split(':');
      meetingpass = passchange[1];
      return passchange[1];
    }
  }

  String? _launchZoom(meetingid) {
    meetingurl = getSplittedZoomURL(meetingid);
    if (meetingurl == null) {
      return 'false';
    } else {
      return 'true';
    }
  }

  void _confirminfo() async {
    print("Zoom meetingの情報をコピーしました");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zoom meetingsの情報をコピーしました\n反映されない時はもう一度....'),
      ),
    );
  }

  void deleteMeetingid() async {
    await SQLHelper.deleteAllmeetingid();
  }

  Future<void> setZoomid() async {
    print('setZooomid: ${meetingid}, ${meetingpass}');
    deleteMeetingid();
    SQLHelper.createmeetingid(
        1, meetingid, meetingpass == null ? '' : meetingpass);
  }
}

