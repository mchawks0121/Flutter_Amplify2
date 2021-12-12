import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'amplifyconfiguration.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MyChat extends StatefulWidget {
  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  final _nameInputController = TextEditingController();
  final _descryptionInputController = TextEditingController();
  var itemList = [];
  var user;
  late int len;
  List<dynamic> itemMap = [];
  List<String> namebuf = [];
  bool _isLoading = true;
  late bool _isEnabled; //amplifyが接続されているか否か

  @override
  void initState() {
    super.initState();
    _configureAmplify();
    _fetch();
    _currentuser();
  }

  @override
  Widget build(BuildContext context) {
    _subscribe();
    return Scaffold(
      appBar: AppBar(
        title: Text("掲示板"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
      Expanded(
      child: RefreshIndicator(
      onRefresh: () async {
    print('Loading');
    await _loadData();
    },
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: itemMap.length,
        itemBuilder: (context, index) => Card(
          elevation: 30,
          color: Colors.orange[200],
          margin: EdgeInsets.all(15),
          child: ListTile(
              title: SelectableText(itemMap[index]['description'], onTap: () => _launchURL(itemMap[index]['description'])),
              subtitle: SelectableText(itemMap[index]['name']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                  onPressed: itemMap[index]['owner'] == user? () {
                    _showForm(itemMap[index]['id']);
                  }:
                      null
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: itemMap[index]['owner'] == user? (){
                        _delete(itemMap[index]['id']);
                      }
                      :
                          null
                    ),
                  ],
                ),
              )),
        ),
      ),
    ))
    ]
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: !_isEnabled? (){
          _showForm(null);
        }
        :
        null
      ),
    );
  }

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey== 'email') {
        print("user's email is ${attribute.value}");
        user = attribute.value;
      }
    }
  }

  void _configureAmplify() async {
    try {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        AmplifyAPI apiPlugin = AmplifyAPI();
        Amplify.addPlugins([apiPlugin]);
        Amplify.configure(amplifyconfig);
      });
      await Amplify.configure(amplifyconfig);
      _isEnabled = true;
    } on AmplifyAlreadyConfiguredException {
      print("Amplify_初期化の失敗");
      _isEnabled = false;
    }
  }

  void _showForm(id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      itemMap.firstWhere((element) => element['id'] == id);
      _nameInputController.text = existingJournal['name'];
      _descryptionInputController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        context: context,
        elevation: 10,
        builder: (_) => Container(
          padding: EdgeInsets.only(bottom : MediaQuery.of(context).viewInsets.bottom),
          width: double.infinity,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                maxLines: null,
                //style: TextStyle(backgroundColor: )
                controller: _descryptionInputController,
                decoration: InputDecoration(
                    icon: Icon(Icons.comment),
                    hintText: '内容',
                labelText: 'コメント *'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
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
                  child: Text(id == null ? '作成' : '変更')
              )
            ],
          ),
        ));
  }

  String? getSplittedURL(String message) {
    final RegExp urlRegExp = RegExp(
        r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');
    final Iterable<RegExpMatch> urlMatches =
    urlRegExp.allMatches(message);
    for (Match m in urlMatches) {
      return(m.group(0));
    }
    //return urlMatches as String;
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

  Future _loadData() async {
    itemList =[];
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
      itemList= [];
      itemMap= [];
      setState(() {
        //itemMap.add(map['listTodos']['items']);
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
      itemMap.add("id: 564b3e64-7db5-4370-8b2f-1b0f5c5d37cf, name: 'AWSに', description: '接続できません', owner: ${user}");
      print('Query failed: $e');
    }
  }

  void _subscribe() async {
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
            print('Subscription event data received: ${event.data}');
          },
          onEstablished: () {
            print('Subscription established');
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


