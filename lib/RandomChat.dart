import 'dart:convert';
import 'dart:math';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart';
import 'Clock.dart';
import 'RandomChatSettings.dart';
import 'RandomChatdetails.dart';
import 'Clock.dart';

class RandomChat extends StatefulWidget {
  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<RandomChat> with WidgetsBindingObserver {
  List<dynamic> RandomChatMap = [];
  late int len;
  var username;
  var deleteid;

  @override
  void initState() {
    super.initState();
    _currentuser();
    _LoadData();
  }


  void didPopNext() {}

  @override
  Widget build(BuildContext context) {
    _subscribeCreate();
    _subscribeUpdate();
    _subscribeDelete();
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("ランダムチャットエントリー"),
          actions: [
            IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () => {
                _LoadData()
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => {
              Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>
              RandomChatSettings()))
              },
            ),
          ]),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //Clock(),
            Text('こちらはランダムチャットです'),
            (Checkuser(username[0])==false)?
            FlatButton.icon(
                onPressed: () => {_create()},
                icon: Icon(Icons.group_add),
                label: Text('参加エントリー'))
            :Text('エントリー済みです'),
            /*SizedBox(
              child:
              Expanded(
                child: TimerPage('Life cycle Event Timer'),
              ),
              height: 30,
            ),*/
            Expanded(
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: RandomChatMap.length,
                    itemBuilder: (context, index) => Center(child:
                          (RandomChatMap.length != 0)
                              ? Card(
                                  color: Colors.orange[200],
                                  child: Text(RandomChatMap[index]['name'], style: TextStyle(fontSize: 17)),
                                )
                              : Text('現在エントリー者はいません'),
                        ))),
            FlatButton.icon(
                onPressed: () => {_delete()},
                icon: Icon(Icons.delete),
                label: Text('エントリー中止')),
            (RandomChatMap.length>1 && (RandomChatMap.length)%2==0 && check()==true)?
            FlatButton.icon(
                onPressed: () => {
                Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => RandomChatdetails(_shuffle(RandomChatMap))),
                (_) => false)
                    },
                icon: Icon(Icons.backup),
                label: Text('参加'))
                :Text('参加人数が2人以上で偶数でないと参加できません'),
          ],
        ),
      ),
    );
  }

  Future _LoadData() async {
    _fetch();
  }

  bool? check() {
    for(int i=0;i<RandomChatMap.length;i++){
      if(RandomChatMap[i]['name'] == username[0]){
        return true;
      }
    }
    return false;
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

  bool? Checkuser(user) {
    for(int i=0;i<RandomChatMap.length;i++) {
      if(RandomChatMap[i]['name'] == user) {
        print('Checkuser: エントリー済みです');
        return true;
      }
    }
    print('Checkuser: エントリーしていません');
    return false;
  }

  void _create() async {
    try {
      String graphQLDocument =
          '''mutation CreateRandomChatList(\$name: String, \$count: Int!) {
              createRandomChatList(input: {name: \$name, count: \$count}) {
                id
                name
                count
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
      for(int i=0;i<RandomChatMap.length;i++) {
        if (RandomChatMap[i]['name'] == username) {
          print('エントリー済みです。_createmethod');
          break;
        } else {
          print('エントリーしていません。_createmethod');
        }
      }
      var variables = {
        "name": str[0],
        "count": count,
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

  void _fetch() async {
    try {
      String graphQLDocument = '''query ListRandomChatLists {
      listRandomChatLists {
        items {
          id
          name
          count
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
      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listRandomChatLists']['items'].length;
      RandomChatMap = [];
      setState(() {
        RandomChatMap = map['listRandomChatLists']['items'];
        print('ソート前: ${RandomChatMap}');
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _delete() async {
    try {
      String graphQLDocument = '''mutation deleteRandomChatList(\$id: ID!) {
          deleteRandomChatList(input: { id: \$id }) {
            id
            name
            count
          }
    }''';

      for (int i = 0; i < RandomChatMap.length; i++) {
        if (RandomChatMap[i]['name'] == username[0]) {
          deleteid = RandomChatMap[i]['id'];
        }
      }

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {'id': deleteid}));
      var response = await operation.response;
      var data = response.data;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('エントリー情報を削除しました!'),
      ));
      print("Success-delete_item: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete_item: ${e}");
    }
  }

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateRandomChatList {
        onCreateRandomChatList {
          id
          name
          count
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

  void _subscribeUpdate() async {
    try {
      String graphQLDocument = '''subscription OnUpdateRandomChatList {
        onUpdateRandomChatList {
                id
                name
                count
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
      String graphQLDocument = '''subscription OnDeleteRandomChatList {
        onDeleteRandomChatList {
            id
            name
            count
          }
    }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            _fetch();
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

  String _shuffle(List items) {
    var random = new Random();
    /*for (int j = 0; j <items.length; j++) {
      if(items[j]['name'] == username[0]) {
        print('items.removeAt(i): ${items[j]['name']}');
        items.removeAt(j);
      }
    }*/

    final chunkSize = 2;
    final chunkedItems = partition(items, chunkSize);

    /*for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }*/

    final list = chunkedItems.toList();
    var index;
    var jndex;
    var send_index;
    var send_jndex;
    print('chunkedItems: $chunkedItems');
    for(int i=0;i<2;i++) {
      for (int j=0;j<2;j++) {
        if(list[i][j]['name']==username[0]){
          index = i;
          jndex = j;
          send_index = index;
          if(jndex == 0) {
            send_jndex = 1;
          }else {
            send_jndex = 0;
          }
        }
        print('ランダムチャット組み合わせ${i}: ${list[i][j]['name']}');
      }
    }
    print('own: ${index}, ${jndex}');
    print('random_chat-partner: ${send_index}, ${send_jndex}');
    return list[send_index][send_jndex]['name'];
  }
}
