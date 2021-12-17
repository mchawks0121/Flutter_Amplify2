import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'amplifyconfiguration.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyChat extends StatefulWidget {
  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  final _nameInputController = TextEditingController();
  final _descryptionInputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var itemList = [];
  var user;
  late Map<String, String> _getUrlResult={};
  late int len;
  late bool initialcounter = true;
  List<dynamic> itemMap = [];
  Set<dynamic> ownerMap = {};
  List<String> namebuf = [];
  bool _isLoading = true;
  late bool _isEnabled; //amplifyが接続されているか否か
  String URL = "";
  File? imagefile;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    WidgetsFlutterBinding.ensureInitialized();
    NotificationSetup();
    _fetch();
    _initialStarterGet();
    if (initialcounter){
    setAlluser();
    _initialStarterSet();
    }
    getAlluser();
    _currentuser();
    getUrlall();
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
          automaticallyImplyLeading: false,
        title: Text("掲示板"),
          actions: [
      IconButton(
      icon: Icon(Icons.autorenew),
      onPressed: () => {
      _fetch(),
        _initialStarterGet(),
    if (initialcounter){
      setAlluser(),
      _initialStarterSet(),
    }else{},
    getAlluser(),
    _currentuser(),
    getUrlall(),
      },
    ),
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
          ),
          Container(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                _launchURL("https://aws.amazon.com/jp/amplify/"); //amplifyのURL
              },
              child: Text("Amazon AWS Amplify",
                style: TextStyle(color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
          ),
      Expanded(
        /*
      child: RefreshIndicator(
      onRefresh: () async {
    print('Loading');
    await _loadData();
    }*/
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: itemMap.length,
        itemBuilder: (context, index) => Card(
          elevation: 100,
          color: Colors.orange[200],
          margin: EdgeInsets.all(15),
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
                          fit: BoxFit.cover, image: (_getUrlResult[itemMap[index]['name']] == null)?
                      NetworkImage('https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                          :NetworkImage(_getUrlResult[itemMap[index]['name']] as String)),
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      color: Colors.redAccent,
                    ),
                  ),
                    Padding(padding: const EdgeInsets.all(10.0)),
                    Column(
                      children: [
                    Text((itemMap[index]['name'])),
                    SelectableText(itemMap[index]['createdAt']),
        ],
                    ),
                  Padding(padding: const EdgeInsets.all(40.0)),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit),
                          iconSize: 20,
                          onPressed: itemMap[index]['owner'] == user? () {
                            _showForm(itemMap[index]['id']);
                          }:
                          null
                      ),
                      IconButton(
                          icon: Icon(Icons.delete),
                          iconSize: 20,
                          onPressed: itemMap[index]['owner'] == user? (){
                            _delete(itemMap[index]['id']);
                          }
                              :
                          null
                      ),
                    ],
                  ),
                ],
              ),
              ListTile(
              title: SelectableText(itemMap[index]['description'], onTap: () => _launchURL(itemMap[index]['description'])),
              trailing: SizedBox(
                width: 100,
              ),
          ),
              SimpleUrlPreview(
                isClosable: true,
                bgColor: Colors.orange[200],
                url: _URLLink(itemMap[index]['description']).toString()!=""?_URLLink(itemMap[index]['description']).toString():"",
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
                onTap:()=> _launchURL(itemMap[index]['description']),
              ),
        ]),
          ),
      ),
    ),
    ]
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showForm(null);
          this
          ._scaffoldKey
          .currentState;
        }
      ),
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
    final InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: null,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
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
      if (attribute.userAttributeKey== 'email') {
        print("user's email is ${attribute.value}");
        setState(() {
          user = attribute.value;
        });
      }
    }
  }

  void _configureAmplify() async {
    try {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
        AmplifyAPI apiPlugin = AmplifyAPI();
        AmplifyStorageS3 storagePlugin = AmplifyStorageS3();
        Amplify.addPlugins([authPlugin]);
        Amplify.addPlugins([apiPlugin]);
        Amplify.addPlugins([storagePlugin]);
        Amplify.configure(amplifyconfig);
      });
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print("初期化失敗");
    }
  }

  void _showForm(id) async {
    if (id != null) {
      final existingJournal =
      itemMap.firstWhere((element) => element['id'] == id);
      _nameInputController.text = existingJournal['name'];
      _descryptionInputController.text = existingJournal['description'];
    }else if(id == null ) {
      _nameInputController.text = "";
      _descryptionInputController.text = "";
    }

    showBottomSheet(
        context: context,
        elevation: 10,
        builder: (_) => Container(
        padding: EdgeInsets.only(bottom : MediaQuery.of(context).viewInsets.bottom),
          width: double.infinity,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
              children:[
              TextFormField(
                onTap: (){
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
                labelText: 'コメント *'),
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
                  label: Text(id == null ? '作成' : '変更')
                  )
            ],
          ),
        ])));
  }

  void _scrollToBottom(){
    ScrollController _scrollController = new ScrollController();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + MediaQuery.of(context).viewInsets.bottom,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  String? getSplittedURL(String message) {
    final RegExp urlRegExp = RegExp(
        r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');
    final Iterable<RegExpMatch> urlMatches =
    urlRegExp.allMatches(message);
    for (Match m in urlMatches) {
      return(m.group(0));
    }
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
    //Future.delay()を使用して擬似的に非同期処理を表現してみた笑
    await Future.delayed(Duration(seconds: 2));
    String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          name
          description
        }
        nextToken
      }
    }''';

    var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
        ));
    itemMap = [];
    var response = await operation.response;
    Map<String, dynamic> map = jsonDecode(response.data);
    setState(() {
      itemMap = map['listTodos']['items'];
      itemMap.sort( (a, b) => -a['count'].compareTo(b['count']) ); //要素countで逆順ソート
    });
  }

  void _create() async {
    try {
      String graphQLDocument =
      '''mutation CreateTodo(\$name: String!, \$description: String, \$owner: String, \$count: Int!, \$createdAt: String) {
              createTodo(input: {name: \$name, description: \$description, owner: \$owner, count: \$count, createdAt: \$createdAt}) {
                id
                name
                description
                owner
                count
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
        if (attribute.userAttributeKey== 'email') {
          print("user's email is ${attribute.value}");
          user = attribute.value;
        }
      }
      str = user.split('@');
      var count = len+1;
      var variables = {
        "name": str[0],
        "description": _descryptionInputController.text,
        "owner": user,
        "count": count,
        "createdAt": date,
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
      String graphQLDocument =
      '''mutation deleteTodo(\$id: ID!) {
          deleteTodo(input: { id: \$id }) {
            id
            name
            description
            owner
            count
            createdAt
          }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(document: graphQLDocument, variables: {
            'id': id
          }));
      var response = await operation.response;
      var data = response.data;
      _fetch();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('メモを削除しました!'),
      ));
      print("Success-delete: ${data}");
    } on AuthException catch(e) {
      print("Faild-delete: ${e}");
    }
  }

  void _update(id) async {
    try {
      String graphQLDocument =
      '''mutation UpdateTodo(\$id: ID!,\$name: String!, \$description: String) {
              updateTodo(input: {id: \$id, name: \$name, description: \$description}) {
                id
                name
                description
                owner
                count
                createdAt
              }
        }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {
            'id': id,
            "name": _nameInputController.text,
            "description": _descryptionInputController.text,
          }));

      var response = await operation.response;
      var data = response.data;
      _fetch();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
      print('Mutation failed: $e');
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
          createdAt
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
        if (attribute.userAttributeKey== 'email') {
          print("user's email is ${attribute.value}");
          user = attribute.value;
        }
      }

      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listTodos']['items'].length;
      itemMap= [];
      setState(() {
        itemMap = map['listTodos']['items'];
        itemMap.sort( (a, b) => -a['count'].compareTo(b['count']) ); //要素countで逆順ソート
      });
    } on ApiException catch (e) {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      for (var attribute in attributes) {
        if (attribute.userAttributeKey== 'email') {
          print("user's email is ${attribute.value}");
          user = attribute.value;
        }
      }
      print('Query failed: $e');
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
          createdAt
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
      String graphQLDocument =
      '''subscription OnUpdateTodo {
        onUpdateTodo {
                id
                name
                description
                owner
                count
                createdAt
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

  void _subscribeDelete() async {
    try {
      String graphQLDocument =
      '''subscription OnDeleteTodo {
        onDeleteTodo {
            id
            name
            description
            owner
            count
            createdAt
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
            //getUrlall();
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
    _getUrlResult={};
    try {
      var attributes = await Amplify.Auth.fetchUserAttributes();
      for (var attribute in attributes) {
        if (attribute.userAttributeKey== 'email') {
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
      for(int i=0;i<ownerMap.length;i++) {
        GetUrlResult result =
        await Amplify.Storage.getUrl(key: '${ownerMap.elementAt(i)}.jpeg');
        setState(() {
          _getUrlResult.addAll({ownerMap.elementAt(i): '${result.url}' as String});
        });
        print(_getUrlResult[ownerMap.elementAt(i)] as String);
      }
      print('imageurl: $_getUrlResult');
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }

  void setAlluser() async {
    try {
      String graphQLDocument =
      '''mutation CreateOwner(\$owner: String!) {
              createOwner(input: {owner: \$owner}) {
                owner
              }
        }''';

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey== 'email') {
          print("user's email is ${attribute.value}");
          user = attribute.value;
        }
      }
      str = user.split('@');
      var variables = {
        "owner": str[0],
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      print('result: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
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
}


