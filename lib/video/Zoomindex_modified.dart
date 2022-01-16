import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:fluamp/sqlite/MeetingId_sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_sdk/zoom_options.dart';
import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluamp/sqlite/Channel_sql_helper.dart' as Channel;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluamp/sqlite/MeetingId_sql_helper.dart' as Meeting;

class Zoomindex_modified extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<Zoomindex_modified> {
  final nameController = TextEditingController();
  late  TextEditingController meetingIdController = TextEditingController();
  late  TextEditingController meetingPasswordController = TextEditingController();
  bool _validateError = false;
  List<Map<String, dynamic>> _journals = []/*..length=3*/;
  List<Map<String, dynamic>> _idjournals = []/*..length=3*/;

  void _refreshJournals() async {
    final data = await Channel.SQLHelper.getItems();
    print(data);
    setState(() {
      _journals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getMeetingid();
      _refreshJournals();
      meetingIdController.text =  _idjournals.length == 0?"":_idjournals[0]['meetingid'];
      meetingPasswordController.text =  _idjournals.length == 0?"":_idjournals[0]['pass'];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        title: Text("ミーティング"),
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 500,
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    _launchURL("https://marketplace.zoom.us/"); //agora.io短縮URL
                  },
                  child: Text("zoom Cloud meetings",
                    style: TextStyle(color: Colors.red,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child:
                      TextFormField(
                        controller: meetingIdController,
                        decoration: InputDecoration(
                          errorText:
                          _validateError ? 'idが存在しません' : null,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          icon: Icon(Icons.account_balance),
                          hintText: 'ミーティングID',
                        ),
                      )
                  ),
                ],
              ),
              Column(
                children: [
                  TextFormField(
                    controller: meetingPasswordController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      icon: Icon(Icons.vpn_key),
                      hintText: 'パスコード',
                    ),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      icon: Icon(Icons.person_pin_circle),
                      hintText: '名前',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          joinMeeting();
                          _addItem();
                          deleteMeetingid();
                        },
                        child: Text('Zoomミーティングに参加'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                            foregroundColor: MaterialStateProperty.all(Colors.white)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.history, semanticLabel: '履歴'),
          onPressed: () => _showForm(null)
      ),
    );
  }

  void _showForm(id) async {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      context: context,
      elevation: 10,
      builder: (_) => ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          elevation: 30,
          color: Colors.orange[200],
          margin: EdgeInsets.all(15),
          child: ListTile(
              title: SelectableText('${_journals[index]['meetingid']}', style: TextStyle(color: Colors.black)),
              subtitle: SelectableText('${_journals[index]['passcode']}', style: TextStyle(color: Colors.black)),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _Inputitem(_journals[index]),
                    ),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(_journals[index]['id'])
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  // Insert a new journal to the database
  Future<void> _addItem() async {
    await Channel.SQLHelper.createItem(
        meetingIdController.text, meetingPasswordController.text, nameController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await Channel.SQLHelper.deleteItem(id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('履歴を削除しました!'),
    ));
    setState(() {
      _refreshJournals();
    });
  }

  void _deleteAllItem() async {
    await Channel.SQLHelper.deleteAllItem();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('履歴を全削除しました!'),
    ));
    setState(() {
      _refreshJournals();
    });
  }

  void getMeetingid() async {
    final data = await Meeting.SQLHelper.getmeetingid();
    setState(() {
      _idjournals = data as List<Map<String, dynamic>>;
      meetingIdController.text =  _idjournals.length == 0?"":_idjournals[0]['meetingid'];
      meetingPasswordController.text =  _idjournals.length == 0?"":_idjournals[0]['pass'];
    });
    print('meetinginfo: $_idjournals');
    print('meetinginfolength: ${_idjournals.length}');
  }

  void deleteMeetingid() async {
    await Meeting.SQLHelper.deleteAllmeetingid();
  }

  void _Inputitem(item) async {
    setState(() {
      meetingIdController.text = item['meetingid'];
      meetingPasswordController.text = item['passcode'];
      nameController.text = item['name'];
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('履歴を反映しました。'),
    ));
    _refreshJournals();
  }

  _launchURL(uri) async {
    final url = uri;
    if (await canLaunch(url!)) {
      await launch(url);
      print("$urlへ接続します。");
    } else {
      throw 'Could not launch $url';
    }
  }

  void joinMeeting() async {
    bool _isMeetingEnded(String status) {
      var result = false;
      return result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    }
    if(meetingIdController.text.isNotEmpty && meetingPasswordController.text.isNotEmpty){
      ZoomOptions zoomOptions = new ZoomOptions(
        domain: "zoom.us",
        appKey: "58SMuLgTkyUGTwdzVjhmTlKwDCz4RbZ8zX0M", //API KEY FROM ZOOM
        appSecret: "miSXIG3EeuzgJGFg5qp4DVy4dplrQYCdDudP", //API SECRET FROM ZOOM
      );
      var meetingOptions = new ZoomMeetingOptions(
          userId: nameController.text, //pass username for join meeting only --- Any name eg:- EVILRATT.
          meetingId: meetingIdController.text, //pass meeting id for join meeting only
          meetingPassword: meetingPasswordController.text, //pass meeting password for join meeting only
          disableDialIn: "true",
          disableDrive: "true",
          disableInvite: "true",
          disableShare: "true",
          disableTitlebar: "false",
          viewOptions: "true",
          noAudio: "false",
          noDisconnectAudio: "false"
      );

      var zoom = ZoomView();
      zoom.initZoom(zoomOptions).then((results) {
        if(results[0] == 0) {
          zoom.onMeetingStatus().listen((status) {
            print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
            if (_isMeetingEnded(status[0])) {
              print("[Meeting Status] :- Ended");
            }
          });
          print("listen on event channel");
          zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
            var timer = Timer.periodic(new Duration(seconds: 2), (timer) {
              zoom.meetingStatus(meetingOptions.meetingId!)
                  .then((status) {
                print("[Meeting Status Polling] : " + status[0] + " - " + status[1]);
              });
            });
          });
        }
      }).catchError((error) {
        print("[Error Generated] : " + error);
      });
    }else{
      if(meetingIdController.text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Enter a valid meeting id to continue."),
        ));
      }
      else if(meetingPasswordController.text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Enter a meeting password to start."),
        ));
      }
    }
  }
}
