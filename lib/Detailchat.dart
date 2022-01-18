import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class Detailchat extends StatefulWidget {
  Map<String, dynamic> itemMap;

  Detailchat(this.itemMap);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<Detailchat> {
  late int len;
  var user;
  var username = [];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("詳細画面"),
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
                color: Colors.white10,
                margin: EdgeInsets.all(10),
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
                              image: (_getUrlResult[widget.itemMap['name']] ==
                                  null)
                                  ? NetworkImage(
                                  'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png')
                                  : NetworkImage(
                                  _getUrlResult[widget.itemMap['name']]
                                  as String)),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          color: Colors.amberAccent[200],
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
                    bgColor: Colors.white38,
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
                ]),
                //height: 400,
                //width: 600,
              ),
            ),
            Text('こちらではテキストの選択、コピーができます'),
          ],
        ),
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
      for (int i = 0; i < widget.itemMap.length; i++) {
        GetUrlResult result =
        await Amplify.Storage.getUrl(key: '${widget.itemMap['name']}.jpeg');
        setState(() {
          _getUrlResult
              .addAll({widget.itemMap['name']: '${result.url}' as String});
        });
        print(_getUrlResult[widget.itemMap['name']] as String);
      }
      print('imageurl: $_getUrlResult');
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }
}
