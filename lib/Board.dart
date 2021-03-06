import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:fluamp/Goodcount.dart';
import 'package:fluamp/LikeBoard.dart';
import 'package:fluamp/Thread.dart';
import 'package:fluamp/video/Zoomindex_modified.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Chatdetails.dart';
import 'Detailboard.dart';
import 'sqlite/MeetingId_sql_helper.dart';

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> with TickerProviderStateMixin {
  final _nameInputController = TextEditingController();
  final _descryptionInputController = TextEditingController();
  final _commentInputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var itemList = [];
  var user;
  var username = [];
  var meetingurl;
  var meetingid;
  var meetingpass;
  late Map<String, String> _getUrlResult = {};
  late int len;
  late bool initialcounter = true;
  List<dynamic> itemMap = [];
  List<dynamic> threadMap = [];
  List<dynamic> mythreadMap = [];
  Set<dynamic> ownerMap = {};
  List<String> namebuf = [];
  bool _isLoading = true;
  late bool _isEnabled; //amplifyが接続されているか否か
  String URL = "";
  File? imagefile;
  final defaultStyle = TextStyle(
    color: Colors.black,
  );
  final highlightStyle = TextStyle(
    color: Colors.blue,
  );
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    WidgetsFlutterBinding.ensureInitialized();
    NotificationSetup();
    _fetch();
    _controller = AnimationController(vsync: this);
    print('_controller: ${_controller}');
    _initialStarterGet();
    if (initialcounter) {
      _initialStarterSet();
    }
    getAlluser();
    _currentuser();
    getUrlall();
    _loadData();
    deleteMeetingid();
    _fetchThread();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _subscribeCreate();
    _subscribeUpdate();
    _subscribeDelete();
    _subscribeUpdateGood();
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("ボード"),
          actions: [
            IconButton(
              icon: Icon(Icons.grade),
              onPressed: () => {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => LikeChat()))
              },
            ),
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () => {
              _loadData()
              },
            ),
          ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        Container(
          width: double.infinity,
          child: IconButton(icon: Icon(MdiIcons.aws),onPressed: () { _launchURL("https://aws.amazon.com/jp/amplify/"); },)
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              print('Loading');
              await _loadData();
            },
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: itemMap.length,
              itemBuilder: (context, index) => GestureDetector(
                child: Card(
                  elevation: 100,
                  color: Colors.orange[200],
                  margin: EdgeInsets.all(15),
                  child: Column(children: [
                    Row(
                      children: [
                        Padding(padding: const EdgeInsets.all(10.0)),
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: (_getUrlResult[itemMap[index]['name']] ==
                                        null)
                                    ? NetworkImage(
                                        'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                    : NetworkImage(
                                        _getUrlResult[itemMap[index]['name']]
                                            as String)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                            color: Colors.orange[200],
                          ),
                        ),
                        Padding(padding: const EdgeInsets.all(10.0)),
                        Column(
                          children: [
                            Card(
                              color: Colors.orange[100],
                              child: Column(children: [
                                Text((itemMap[index]['name']),
                                    style: TextStyle(color: Colors.black)),
                                SelectableText(itemMap[index]['createdAt'],
                                    style: TextStyle(color: Colors.black)),
                              ]),
                            ),
                            Card(
                              color: Colors.orange[50],
                              child: (itemMap[index]['edited'] == "true")
                                  ? Text('編集済み',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black))
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                        Padding(padding: const EdgeInsets.all(30.0)),
                        Row(
                          children: [
                            (itemMap[index]['owner'] == user)
                                ? IconButton(
                                    icon: Icon(Icons.edit),
                                    iconSize: 20,
                                    onPressed: itemMap[index]['owner'] == user
                                        ? () {
                                            _showForm(itemMap[index]['id']);
                                          }
                                        : null)
                                : SizedBox.shrink(),
                            (itemMap[index]['owner'] == user)
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    iconSize: 20,
                                    onPressed: itemMap[index]['owner'] == user
                                        ? () {
                                            _delete(itemMap[index]['id']);
                                          }
                                        : null)
                                : SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                    ListTile(
                      title: SubstringHighlight(
                        text: itemMap[index]['description'],
                        term: getSplittedURL(itemMap[index]['description']) ==
                                null
                            ? ""
                            : getSplittedURL(itemMap[index]['description']),
                        textStyle: defaultStyle,
                        textStyleHighlight: highlightStyle,
                      ),
                      trailing: SizedBox(
                        width: 10,
                      ),
                    ),
                    SimpleUrlPreview(
                      isClosable: true,
                      bgColor: Colors.orange[200],
                      url: _URLLink(itemMap[index]['description']).toString() !=
                              ""
                          ? _URLLink(itemMap[index]['description']).toString()
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
                      onTap: () => _launchURL(itemMap[index]['description']),
                    ),
                    Card(
                        color: Colors.orange[100],
                        margin: EdgeInsets.all(15),
                        child: Column(children: [
                          Row(children: [
                            (itemMap[index]['good'].isEmpty)
                                ? Stack(overflow: Overflow.visible, children: [
                                    IconButton(
                                        icon: Icon(MdiIcons.heartPlusOutline),
                                        iconSize: 20,
                                        onPressed: () {
                                          _updategood(itemMap[index]['id'],
                                              itemMap[index]['good']);
                                        }),
                                    Positioned(
                                        top: -8,
                                        left: 20,
                                        child: NotificationNumberBadge(
                                            itemMap[index]['good'].length, Colors.red))
                                  ])
                                : (getgoodststus(itemMap[index]['good']) ==
                                        'true')
                                    ? Stack(overflow: Overflow.visible, children: [
                                      IconButton(
                                        icon: Icon(MdiIcons.heart),
                                        iconSize: 20,
                                        onPressed: () {
                                          _updategood(itemMap[index]['id'],
                                              itemMap[index]['good']);
                                        },
                                      ),
                              Positioned(
                                  top: -8,
                                  left: 20,
                                  child: NotificationNumberBadge(
                                      itemMap[index]['good'].length, Colors.red))
                            ])
                                :Stack(overflow: Overflow.visible, children: [
                                  IconButton(
                                        icon: Icon(MdiIcons.heartPlusOutline),
                                        iconSize: 20,
                                        onPressed: () {
                                          _updategood(itemMap[index]['id'],
                                              itemMap[index]['good']);
                                        },
                                      ),
                              Positioned(
                                  top: -8,
                                  left: 20,
                                  child: NotificationNumberBadge(
                                      itemMap[index]['good'].length, Colors.red))
                            ]),
                            IconButton(
                              icon: Icon(Icons.grade),
                              iconSize: 20,
                              onPressed: () => {setLiked(itemMap[index]['id'])},
                            ),
                            IconButton(
                              icon: Icon(Icons.flight_takeoff),
                              iconSize: 20,
                              onPressed: () =>
                                  {_share(itemMap[index]['description'])},
                            ),
                            (_launchZoom(itemMap[index]['description']) ==
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
                                      await _loadData();
                                      meetingid = getSplittedZoomURL(
                                          itemMap[index]['description']);
                                      meetingpass = getSplittedZoomPass(
                                          itemMap[index]['description']);
                                      setZoomid();
                                      _confirminfo();
                                    })
                                : SizedBox.shrink(),
                            Stack(
                              overflow: Overflow.visible,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.reply),
                                  iconSize: 20,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Thread(itemMap[index])),
                                    );
                                  },
                                ),
                                Positioned(
                                    top: -8,
                                    left: 20,
                                    child: NotificationNumberBadge(
                                        mythreadMap.length, Colors.red))
                              ],
                            )
                            /*FloatingActionButton(
                          onPressed: () async {
                            if (_controller.isCompleted) {
                              _controller.reset();
                              _updategood(itemMap[index]['id']);
                            } else {
                              _controller.forward();
                              _updategood(itemMap[index]['id']);
                            }
                          },
                          backgroundColor: Colors.orange[200],
                          child: Lottie.network(
                            'https://assets1.lottiefiles.com/packages/lf20_ADzN7G.json',
                            controller: _controller,
                            repeat: true,
                            onLoaded: (composition) {
                              _controller.duration = composition.duration;
                            },
                          ),
                        ),*/
                          ]),
                          Row(children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Goodcount(itemMap[index]['good'])));
                              },
                              child: Text(
                                  (itemMap[index]['good'].isEmpty)
                                      ? ''
                                      : ' いいね   ＞＞',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Thread(itemMap[index])),
                                );
                              },
                              child: Text(
                                  (Convert_threadMaps(itemMap[index]['id']) ==
                                          false)
                                      ? ''
                                      : '　スレッド   ＞＞',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ]),
                        ])),
                  ]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Detailboard(itemMap[index])),
                  );
                },
                onDoubleTap: () {
                  (itemMap[index]['name'] != username[0])
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Chatdetails(itemMap[index]['name'])),
                        )
                      : null;
                },
              ),
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _showForm(null);
            this._scaffoldKey.currentState;
          }),
    );
  }

  static Widget NotificationNumberBadge(int num, Color col) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.brightness_1,
          color: col,
          size: 25,
        ),
        Text(num.toString(),style: TextStyle(color: Colors.white),),
      ],
    );
  }

  void NotificationSetup() async {
//iOSの設定
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    //initializationSettingsのオブジェクト
    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  void setNotification(title, body) async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(
            // sound: 'example.mp3',
            presentAlert: true,
            presentBadge: true,
            presentSound: true);
    NotificationDetails platformChannelSpecifics = const NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
      android: null,
    );
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey == 'email') {
        print("user's email is ${attribute.value}");
        setState(() {
          user = attribute.value;
          username = user.split('@');
        });
      }
    }
  }

  void _showForm(id) async {
    if (id != null) {
      final existingJournal =
          itemMap.firstWhere((element) => element['id'] == id);
      _nameInputController.text = existingJournal['name'];
      _descryptionInputController.text = existingJournal['description'];
    } else if (id == null) {
      _nameInputController.text = "";
      _descryptionInputController.text = "";
    }

    showBottomSheet(
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
                    controller: _descryptionInputController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        icon: Icon(Icons.comment),
                        hintText: '内容',
                        labelText: 'ボード *'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                  ),
                  ElevatedButton.icon(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        // Save new journal
                        if (id == null) {
                          _create();
                        }
                        if (id != null) {
                          _update(id);
                        }
                        Navigator.of(context).pop();
                      },
                      label: Text(''))
                ],
              ),
            ])));
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

  void _confirminfo() async {
    print("Zoom meetingの情報をコピーしました");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zoom meetingsの情報をコピーしました\n反映されない時はもう一度....'),
      ),
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

//(?:ミーティングID: [0-9]{10} |パスコード: [!-~]{6})
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

  Future<void> setZoomid() async {
    print('setZooomid: ${meetingid}, ${meetingpass}');
    deleteMeetingid();
    SQLHelper.createmeetingid(
        1, meetingid, meetingpass == null ? '' : meetingpass);
  }

  void deleteMeetingid() async {
    await SQLHelper.deleteAllmeetingid();
  }

  _launchURL(uri) async {
    final url = getSplittedURL(uri);
    if (await canLaunch(url!)) {
      await launch(url);
      print("$urlへ接続します。");
    } else {
      throw 'Could not launch $url';
    }
  }

  String? _URLLink(uri) {
    final url = getSplittedURL(uri);
    print("URL変換: $url");
    return url;
  }

  Future _loadData() async {
    _fetch();
    _initialStarterGet();
    if (initialcounter) {
      _initialStarterSet();
    } else {}
    ;
    getAlluser();
    _currentuser();
    getUrlall();
    _fetchThread();
  }

  void _create() async {
    try {
      String graphQLDocument =
          '''mutation CreateTodo(\$name: String!, \$description: String, \$owner: String, \$edited: String, \$count: Int!, \$good: [String], \$createdAt: String, \$updateAt: String) {
              createTodo(input: {name: \$name, description: \$description, owner: \$owner, edited: \$edited, count: \$count, good: \$good, createdAt: \$createdAt, updateAt: \$updateAt}) {
                id
                name
                description
                owner
                count
                good
                edited
                createdAt
                updateAt
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
      str = user.split('@');
      final emptylist = [];
      var count = len + 1;
      var variables = {
        "name": str[0],
        "description": _descryptionInputController.text,
        "owner": user,
        "count": count,
        "good": emptylist,
        "edited": 'false',
        "thread": emptylist,
        "createdAt": date,
        "updateAt": date,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      _fetch();
      _nameInputController.text = '';
      _descryptionInputController.text = '';
      print('result: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _delete(id) async {
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
              document: graphQLDocument, variables: {'id': id}));
      var response = await operation.response;
      var data = response.data;
      final subject = id.toString();
      _deleteThread(id);
      _fetch();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('メモを削除しました!'),
      ));
      print("Success-delete_item: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete_item: ${e}");
    }
  }

  void _deleteThread(id) async {
    var deleteid;
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
    for (int i = 0; i < threadMap.length; i++) {
      if (threadMap[i]['subject'] == id) {
        deleteid = threadMap[i]['id'];
      }
    }
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
      print('deletesubject: ${deleteid}');
      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {'id': deleteid}));
      var response = await operation.response;
      var data = response.data;
      print("Success-delete_thread: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete_thread: ${e}");
    }
  }

  void _update(id) async {
    try {
      String graphQLDocument =
          '''mutation UpdateTodo(\$id: ID!,\$name: String!, \$description: String, \$edited: String, \$updateAt: String) {
              updateTodo(input: {id: \$id, name: \$name, description: \$description, edited: \$edited, updateAt: \$updateAt}) {
                id
                name
                description
                owner
                count
                good
                edited
                createdAt
                updateAt
              }
        }''';

      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('yyyy-MM-dd-Hm');
      String date = outputFormat.format(now);

      var operation = Amplify.API.mutate(
          request:
              GraphQLRequest<String>(document: graphQLDocument, variables: {
        'id': id,
        "name": _nameInputController.text,
        "description": _descryptionInputController.text,
        "edited": 'true',
        "updateAt": date,
      }));

      var response = await operation.response;
      var data = response.data;
      _fetch();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
      print('Mutation failed: $e');
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
            '''mutation UpdateTodo(\$id: ID!,\$good: [String]) {
              updateTodo(input: {id: \$id, good: \$good}) {
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
        var data = response.data;
        print('_updategood result: ' + data);
      } on ApiException catch (e) {
        print('Mutation failed: $e');
      }
    } else {
      print('${gooduser}はgood済みです');
      try {
        String graphQLDocument =
            '''mutation UpdateTodo(\$id: ID!,\$good: [String]) {
              updateTodo(input: {id: \$id, good: \$good}) {
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
        _fetch();

        print('_updategood result: ' + data);
      } on ApiException catch (e) {
        print('Mutation failed: $e');
      }
    }
  }

  void _fetch() async {
    try {
      String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          name
          description
          owner
          count
          good
          edited
          createdAt
          updateAt
        }
        nextToken
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));
      //List<Map<String, dynamic>> _journals = [];
      var response = await operation.response;
      int i = 0;

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      List<String> userstr = user.split('@');
      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listTodos']['items'].length;
      itemMap = [];
      setState(() {
        itemMap = map['listTodos']['items'];
        itemMap
            .sort((a, b) => -a['count'].compareTo(b['count'])); //要素countで逆順ソート
        print('itemMap: $itemMap');
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
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
        final List<dynamic> convertthreadMap = threadMap;
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  bool? Convert_threadMaps(id) {
    mythreadMap = [];
    print('threadMaplen : ${threadMap.length}');
    for (int i = 0; i < threadMap.length; i++) {
      print('threadMap${[i]} : ${threadMap[i]['subject']}');
      print('id : ${id}');
      if (threadMap[i]['subject'] == id) {
        mythreadMap.add(threadMap[i]);
      }
    }
    print('${id}のスレッド数は${mythreadMap.length}件');
    if (mythreadMap.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateTodo {
        onCreateTodo {
          id
          name
          description
          owner
          count
          good
          thread
          createdAt
          updateAt
        }
      }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            var eventname = data['onCreateTodo']['name'];
            var eventdata = data['onCreateTodo']['description'];
            print('CreateSubscription event data received: ${event.data}');
            var creator = user.split('@');
            if (creator[0] != eventname) {
              setNotification('[作成]: $eventname', eventdata);
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

  void _subscribeUpdate() async {
    try {
      String graphQLDocument = '''subscription OnUpdateTodo {
        onUpdateTodo {
                id
                name
                description
                owner
                count
                good
                thread
                createdAt
                updateAt
              }
        }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            print('UpdateSubscription event data received: ${data}');
            var eventname = data['onUpdateTodo']['name'] as String;
            var eventdata = data['onUpdateTodo']['description'] as String;
            var creator = user.split('@');
            if (creator[0] != eventname) {
              print(eventname);
              print(eventdata);
              setNotification('[更新]: $eventname', eventdata);
            }
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

  void _subscribeUpdateGood() async {
    try {
      String graphQLDocument = '''subscription OnUpdateTodo {
        onUpdateTodo {
                good
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

  void _subscribeDelete() async {
    try {
      String graphQLDocument = '''subscription OnDeleteTodo {
        onDeleteTodo {
            id
            name
            description
            owner
            count
            good
            thread
            createdAt
            updateAt
          }
    }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
            Map<String, dynamic> data = jsonDecode(event.data as String);
            var eventname = data['onDeleteTodo']['name'];
            var eventdata = data['onDeleteTodo']['description'];
            print('DeleteSubscription event data received: ${event.data}');
            var creator = user.split('@');
            if (creator[0] != eventname) {
              setNotification('[削除]: $eventname', eventdata);
            }
          },
          onEstablished: () {
            //_fetch();
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

  void setLiked(id) async {
    try {
      String graphQLDocument =
          '''mutation CreateLiked(\$owner: String!, \$commentId: String!) {
              createLiked(input: {owner: \$owner, commentId: \$commentId}) {
                owner
                commentId
              }
        }''';

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
          user = attribute.value;
        }
      }
      str = user.split('@');
      var variables = {"owner": str[0], "commentId": id};
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      print('Likedresult: ' + data);
      _confirmLiked();
    } on ApiException catch (e) {
      print('Likedfailed: $e');
      _notconfirmLiked();
    }
  }

  void _confirmLiked() async {
    print("Like!");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('お気に入りに登録しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _confirmGood() async {
    print("いいねを押しました");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('いいねを設定しました'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _notconfirmLiked() async {
    print("Not Like!");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('お気に入りに登録できませんでした'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
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

  _initialStarterSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('counter', false);
    print('setStatus $initialcounter');
  }

  _initialStarterGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      initialcounter = (prefs.getBool('counter') ?? false);
    });
    print('getStatus $initialcounter');
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
}

void _share(code) async {
  Share.share(code);
}
