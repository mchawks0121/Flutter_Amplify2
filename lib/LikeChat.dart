import 'dart:async';
import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:fluamp/sqlite/MeetingId_sql_helper.dart';
import 'package:fluamp/video/Zoomindex_modified.dart';
import 'package:flutter/material.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ChatSettings.dart';
import 'Detailchat.dart';
import 'Thread.dart';

class LikeChat extends StatefulWidget {
  @override
  _LikeChatState createState() => _LikeChatState();
}

class _LikeChatState extends State<LikeChat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int len;
  var user;
  var meetingurl;
  var meetingid;
  var meetingpass;
  late Map<String, String> _getUrlResult = {};
  List<dynamic> itemMap = [];
  List<dynamic> itemLike = [];
  List<dynamic> Liked = [];
  Set<dynamic> ownerMap = {};
  Set<dynamic> likedMap = {};
  final defaultStyle = TextStyle(
    color: Colors.black,
  );
  final highlightStyle = TextStyle(
    color: Colors.blue,
  );

  @override
  void initState() {
    super.initState();
    getLiked();
    getAlluser();
    _currentuser();
    getUrlall();
    _fetch();
    LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this._scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("お気に入り"),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ChatSettings()))
              },
            ),
          ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              print('Loading');
              LoadData();
            },
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: Liked.length,
              itemBuilder: (context, index) => GestureDetector(
                  child: Card(
                    elevation: 100,
                    color: Colors.amber[200],
                    margin: EdgeInsets.all(15),
                    child: Column(children: [
                      (Liked != null)
                          ? Row(
                              children: [
                                Padding(padding: const EdgeInsets.all(10.0)),
                                Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: (_getUrlResult[Liked[index]
                                                    ['name']] ==
                                                null)
                                            ? NetworkImage(
                                                'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                            : NetworkImage(_getUrlResult[
                                                    Liked[index]['name']]
                                                as String)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50.0)),
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.all(10.0)),
                                Column(
                                  children: [
                                    Text((Liked[index]['name']),
                                        style: TextStyle(color: Colors.black)),
                                    SelectableText(Liked[index]['createdAt'],
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                                Padding(padding: const EdgeInsets.all(40.0)),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        iconSize: 20,
                                        onPressed: () => {
                                              _deleteLike(
                                                  itemLike[0][index]['id']),
                                              print(
                                                  "index: ${itemLike[0][index]['id']}"),
                                            }),
                                  ],
                                ),
                              ],
                            )
                          : Row(children: [
                              Padding(padding: const EdgeInsets.all(10.0)),
                              Container(child: Text("お気に入りはありません")),
                            ]),
                      ListTile(
                        title: SubstringHighlight(
                          text: Liked[index]['description'],
                          term: getSplittedURL(Liked[index]['description']) ==
                                  null
                              ? ""
                              : getSplittedURL(Liked[index]['description']),
                          textStyle: defaultStyle,
                          textStyleHighlight: highlightStyle,
                        ),
                        trailing: SizedBox(
                          width: 10,
                        ),
                      ),
                      (_launchZoom(Liked[index]['description']) == 'true')
                          ? IconButton(
                              icon: Icon(Icons.videocam),
                              iconSize: 20,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Zoomindex_modified()),
                                );
                                LoadData();
                                meetingid = getSplittedZoomURL(
                                    Liked[index]['description']);
                                meetingpass = getSplittedZoomPass(
                                    Liked[index]['description']);
                                setZoomid();
                                //_confirminfo();
                              })
                          : IconButton(
                              icon: Icon(Icons.videocam_off),
                              iconSize: 0,
                              onPressed: () => {},
                            ),
                      SimpleUrlPreview(
                        isClosable: true,
                        bgColor: Colors.amber[200],
                        url: _URLLink(Liked[index]['description']).toString() !=
                                ""
                            ? _URLLink(Liked[index]['description']).toString()
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
                        onTap: () => _launchURL(Liked[index]['description']),
                      ),
                    ]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Detailchat(itemMap[index])),
                    );
                    print('detail: ${itemMap[index]}');
                  }),
            ),
          ),
        ),
      ]),
    );
  }

  void LoadData() async {
    getLiked();
    getUrlall();
    _fetch();
  }

  void getLiked() async {
    try {
      print('getLiked_start');
      String graphQLDocument = '''query listLikeds {
      listLikeds {
        items {
          id
          owner
          commentId
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
      len = map['listLikeds']['items'].length;
      likedMap = {};
      var Listowner;
      var Listid;
      setState(() {
        for (int i = 0; i < len; i++) {
          Listowner = map['listLikeds']['items'][i]['owner'];
          Listid = map['listLikeds']['items'][i]['commentId'];
          final List = map['listLikeds']['items'];
          likedMap.add(List);
        }
      });
      print('user: ${Listowner}\n id: ${Listid}\n');
    } on ApiException catch (e) {
      print('Query failed: $e');
    }
  }

  void _currentuser() async {
    var attributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in attributes) {
      if (attribute.userAttributeKey == 'email') {
        print("user's email is ${attribute.value}");
        setState(() {
          user = attribute.value;
        });
      }
    }
  }

  void _confirminfo() async {
    print("Zoom meetingの情報をコピーしました");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zoom meetingsの情報をコピーしました'),
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

  void _deleteLike(id) async {
    try {
      String graphQLDocument = '''mutation deleteLiked(\$id: ID!) {
          deleteLiked(input: { id: \$id }) {
            id
            owner
            commentId
          }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
              document: graphQLDocument, variables: {'id': id}));
      var response = await operation.response;
      var data = response.data;
      getLiked();
      _fetch();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('お気に入りを削除しました!'),
      ));
      print("Success-likedelete: ${data}");
    } on AuthException catch (e) {
      print("Faild-likedelete: ${e}");
    }
  }

  void _fetch() async {
    try {
      print("Fetch Start.....");
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
        if (attribute.userAttributeKey == 'email') {
          print("user's email is ${attribute.value}");
          user = attribute.value;
        }
      }

      Map<String, dynamic> map = jsonDecode(response.data);
      itemMap = [];
      itemLike = [];
      Liked = [];
      itemLike = likedMap.toList();
      var itemlikelen;
      var itemmaplen;
      List<String> userstr = user.split('@');
      setState(() {
        itemMap = map['listTodos']['items'];
        itemlikelen = itemLike[0].length;
        itemmaplen = itemMap.length;
        for (int i = 0; i < itemlikelen; i++) {
          if (userstr[0] == itemLike[0][i]['owner']) {
            for (int j = 0; j < itemmaplen; j++) {
              print("itemMap: ${itemMap[j]['id']}");
              if (itemMap[j]['id'] == itemLike[0][i]['commentId']) {
                Liked.add(itemMap[j]);
              }
            }
          } else {}
        }
        Liked.sort((a, b) => -a['count'].compareTo(b['count']));
        print('Liked: $Liked');
        //itemMap.sort( (a, b) => -a['count'].compareTo(b['count']) ); //要素countで逆順ソート
      });
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

  void setAlluser() async {
    try {
      String graphQLDocument = '''mutation CreateOwner(\$owner: String!) {
              createOwner(input: {owner: \$owner}) {
                owner
              }
        }''';

      var attributes = await Amplify.Auth.fetchUserAttributes();
      var user = "";
      List<String> str = [];
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == 'email') {
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
}
