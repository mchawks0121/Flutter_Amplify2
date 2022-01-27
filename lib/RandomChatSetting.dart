import 'dart:convert';

//import 'dart:js';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:intl/intl.dart';

import 'Clock.dart';

class RandomChatSetting extends StatefulWidget {
  @override
  _RandomChatSettingPageState createState() => _RandomChatSettingPageState();
}

class _RandomChatSettingPageState extends State<RandomChatSetting> {
  bool _time = false;
  bool _pcountflag = false;
  late var len;
  List<dynamic> Timesets = [];
  List<Map<String, dynamic>> _timesettingsjournals = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _datetimes;
  var _datetime;
  var _pcounts;
  var _pcount;
  var _datetimeid;
  var hour;
  var minute;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    _subscribeCreate();
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("ランダムチャットの詳細設定"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Text('ランダムチャット機能の統括的管理画面になります'),
          Clock(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("時間指定", style: TextStyle(color: Colors.black, fontSize: 15)),
            Card(
              color: Colors.orange[100],
              margin: EdgeInsets.all(10),
              child: Text(
                _datetime == null
                    ? DateFormat('HH:mm', 'ja').format(DateTime.now())
                    : _datetime,
                style: TextStyle(fontSize: 30),
              ),
            ),
            Switch(
              value: _time,
              onChanged: (bool value) {
                timechange(value);
                this._scaffoldKey.currentState;
                ;
                setState(() => _time = value);
                if (Timesets.length != 0) {
                  _datetimeid = Timesets[0]['id'];
                }
              },
            ),
          ]),
          (_time == true)
              ? Text('上記の時間で自動的にランダムチャットが動作します')
              : Text('上記時間を設定すると自動的にランダムチャットが動作します'),
          Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("人数指定", style: TextStyle(color: Colors.black, fontSize: 15)),
            Text(
                _pcount == null
                    ? ''
                    : _pcount,
                style: TextStyle(fontSize: 30)),
            Switch(
              value: _pcountflag,
              onChanged: (bool value) {
                this._scaffoldKey.currentState;
                setState(() => _pcountflag = value);
              },
            ),
          ]),
          (_pcountflag==true)
          ? ListTile(
            title: const Text('人数選択'),
            trailing: DropdownButton(
              value: _pcount,
              hint: const Text('Choose'),
              onChanged: (newValue) {
                setState(() {
                  _pcount = newValue;
                });
              },
              items: _dropDownMenuItems,
            ),
          )
          :SizedBox.shrink(),
          RaisedButton(
              onPressed: () => _create(),
              child: Text(
                '設定',
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
        ],
      ),
    );
  }

  void timechange(value) async {
    if (value == true) {
      showModalBottomSheet(
          context: context,
          elevation: 10,
          builder: (_) => TextButton(
                child: Text('編集',
                    style: TextStyle(decoration: TextDecoration.underline)),
                onPressed: () async {
                  Picker(
                    adapter: DateTimePickerAdapter(
                        type: PickerDateTimeType.kHM,
                        value: _datetimes,
                        yearBegin: 2021,
                        yearEnd: 2030,
                        customColumnType: [3, 4]),
                    title: Text("時間指定"),
                    confirmTextStyle: TextStyle(debugLabel: '設定'),
                    onConfirm: (Picker picker, List value) {
                      setState(() => {
                            //_datetime = DateTime.utc(0, 0, 0, value[0], value[1], 0),
                            hour = value[0],
                            minute = value[1],
                            _datetime = '$hour:$minute',
                          });
                    },
                  ).showModal(context);
                },
              ));
    }
  }

  void _Fetchlockstatus() async {
    setState(() {
      if (Timesets.length > 0) {
        if (Timesets[0]['time'] != null && Timesets[0]['limit'] != null) {
          _time = true;
          _pcountflag = true;
        } else if (Timesets[0]['time'] != null && Timesets[0]['limit'] == null) {
          _time = true;
          _pcountflag = false;
        } else if (Timesets[0]['time'] == null && Timesets[0]['limit'] != null) {
          _time = false;
          _pcountflag = true;
        }else {
          _time = false;
          _pcountflag = false;
        }
      }else {
        _time = false;
        _pcountflag = false;
      }
    });
    print('sqliteから取得');
    print(_timesettingsjournals);
  }

  static const menuItems = <String>[
    '2',
    '4',
    '6',
    '8',
  ];

  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems
      .map(
        (String value) => DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    ),
  )
      .toList();

  void _fetch() async {
    print('start fetch');
    try {
      String graphQLDocument = '''query ListRandomChatTimesets {
      listRandomChatTimesets {
        items {
                id
                owner
                time
                limit
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
      Map<String, dynamic> map = jsonDecode(response.data);
      len = map['listRandomChatTimesets']['items'].length;
      setState(() {
        Timesets = map['listRandomChatTimesets']['items'];
        _datetime = map['listRandomChatTimesets']['items'][0]['time'];
        _pcount = map['listRandomChatTimesets']['items'][0]['limit'].toString();
        print('Timesets.length: ${Timesets.length}');
        _Fetchlockstatus();
      });
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _create() async {
    if (Timesets.length != 0) {
      _datetimeid = Timesets[0]['id'];
      _delete(_datetimeid);
    }
    try {
      String graphQLDocument =
          '''mutation CreateRandomChatTimeset(\$owner: String, \$time: String, \$count: Int!, \$limit: Int,\$createdAt: String) {
              createRandomChatTimeset(input: {owner: \$owner, time: \$time, count: \$count, limit: \$limit, createdAt: \$createdAt}) {
                id
                owner
                time
                limit
                count
                createdAt
              }
        }''';
      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('yyyy-MM-dd-H:m');
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
      var variables = {
        "owner": str[0],
        "time": '${hour}' + ':' + '${minute}',
        "limit": int.parse(_pcount),
        "count": 1,
        "createdAt": date,
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;
      _sucess();
      print('result: ' + data);
    } on ApiException catch (e) {
      print('failed: $e');
    }
  }

  void _delete(id) async {
    try {
      String graphQLDocument = '''mutation deleteRandomChatTimeset(\$id: ID!) {
          deleteRandomChatTimeset(input: { id: \$id }) {
                id
                owner
                time
                limit
                count
                createdAt
          }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {'id': id}));
      var response = await operation.response;
      var data = response.data;
      print("Success-delete_item: ${data}");
    } on AuthException catch (e) {
      print("Faild-delete_item: ${e}");
    }
  }

  void _subscribeCreate() async {
    try {
      String graphQLDocument = '''subscription OnCreateRandomChatTimeset {
        onCreateRandomChatTimeset {
                id
                owner
                time
                limit
                count
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
  void _sucess() async {
    print("ようこそ管理者さん");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('設定が保存されました'),
      ),
    );
  }
}
