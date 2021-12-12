import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'settings.dart';
import './call.dart';
import 'package:fluamp/sqlite/sql_helper.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  final _channelController = TextEditingController();
  final _appidController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _validateError = false;
  ClientRole? _role = ClientRole.Broadcaster;
  late bool _switchvideo = true;
  List<Map<String, dynamic>> _journals = []/*..length=3*/;
  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    print(data);
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

    @override
    void initState() {
      super.initState();
      _refreshJournals();
    }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("ビデオ通話"),
        automaticallyImplyLeading: false,
    ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 500,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextFormField(
                        controller: _channelController,
                        decoration: InputDecoration(
                          errorText:
                          _validateError ? 'チャンネルが存在しません' : null,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          icon: Icon(Icons.account_balance),
                          hintText: 'チャンネル名',
                        ),
                      )),
                ],
              ),
              Column(
                children: [
                  TextFormField(
                    controller: _appidController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'AppId',
                        icon: Icon(Icons.perm_identity),
                    ),
                  ),
                  TextFormField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      icon: Icon(Icons.vpn_key),
                      hintText: 'Token',
                    ),
                  ),
                  const Text("ビデオ"),
                  Switch(
                      value: _switchvideo,
                      onChanged: (bool value) {
                        print('video: ${_switchvideo}');
                        setState(() => _switchvideo=value);
                      },
                  ),
                  ListTile(
                    title: Text("ビデオ通話"),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      onChanged: (ClientRole? value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  ),
                  /*ListTile(
                    title: Text("単方向ビデオ通話"),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole? value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  )*/
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoin,
                        child: Text('入室!'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                            foregroundColor: MaterialStateProperty.all(Colors.white)
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _deleteAllItem(),
                        child: Text('履歴削除'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                            foregroundColor: MaterialStateProperty.all(Colors.white)
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.history),
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
                title: SelectableText('${_journals[index]['channel']}'),
                subtitle: SelectableText('${_journals[index]['createdAt']}'),
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

  Future<void> onJoin() async {
    _addItem();
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
      APP_ID = _appidController.text;
      Token = _tokenController.text;
    });
    if (_channelController.text.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            video: _switchvideo,
            role: _role,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  // Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _channelController.text, _appidController.text, _tokenController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _channelController.text, _appidController.text, _tokenController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('履歴を削除しました!'),
    ));
    setState(() {
      _refreshJournals();
    });
  }

  void _deleteAllItem() async {
    await SQLHelper.deleteAllItem();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('履歴を全削除しました!'),
    ));
    setState(() {
      _refreshJournals();
    });
  }

  void _Inputitem(item) async {
    setState(() {
      _channelController.text = item['channel'];
      _appidController.text = item['appid'];
      _tokenController.text = item['token'];
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('履歴を反映しました。'),
    ));
    _refreshJournals();
  }
}
