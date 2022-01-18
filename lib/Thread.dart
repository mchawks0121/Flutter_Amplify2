import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _subscribeDelete();
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("スレッド"),
        automaticallyImplyLeading: false,
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
                  SimpleUrlPreview(
                    isClosable: true,
                    bgColor: Colors.orange[200],
                    url:
                        _URLLink(widget.itemMap['description']).toString() != ""
                            ? _URLLink(widget.itemMap['description']).toString()
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
                    onTap: () => _launchURL(widget.itemMap['description']),
                  ),
                  IconButton(
                      icon: Icon(Icons.reply),
                      iconSize: 20,
                      onPressed: () {
                        _showForm();
                      }),
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
                          ? Column(
                              children: [
                                Text('|'),
                                Card(
                                elevation: 200,
                                color: Colors.orange[300],
                                margin: EdgeInsets.all(10),
                                child: Column(children: [
                                  Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(10.0)),
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
                                                  : NetworkImage(_getUrlResult[
                                                          threadMap[index]
                                                              ['owner']]
                                                      as String)),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.0)),
                                          color: Colors.orange[300],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(10.0)),
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
                                          padding: const EdgeInsets.all(40.0)),
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
                                    bgColor: Colors.orange[300],
                                    url: _URLLink(threadMap[index]['comment'])
                                                .toString() !=
                                            ""
                                        ? _URLLink(threadMap[index]['comment'])
                                            .toString()
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
                                    onTap: () =>
                                        _launchURL(threadMap[index]['comment']),
                                  ),
                                ]),
                                //height: 400,
                                //width: 600,
                              ),
                            ])
                          : SizedBox.shrink(),
                    ),
                  )),
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
          '''mutation CreateThread(\$subject: String!, \$owner: String, \$count: Int!, \$comment: String!,\$createdAt: String) {
              createThread(input: {subject: \$subject, owner: \$owner, count: \$count, comment: \$comment, createdAt: \$createdAt}) {
                id
                subject
                owner
                count
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

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateThread {
        onCreateThread {
          subject
          owner
          count
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

  void _subscribeDelete() async {
    try {
      String graphQLDocument = '''subscription OnDeleteThread {
        onDeleteThread {
          subject
          owner
          count
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
}
