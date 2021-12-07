import 'package:fluamp/video/index.dart';
import 'package:flutter/material.dart';
import 'Home.dart';
import 'Chat.dart';

class TabPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      IndexPage(),
      MyChat(),
      Home(),
    ];
    final _kTabs = <Tab>[
      const Tab(icon: Icon(Icons.cloud), text: 'ビデオ通話'),
      const Tab(icon: Icon(Icons.chat_bubble_outline), text: '掲示板'),
      const Tab(icon: Icon(Icons.settings), text: 'マイページ'),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.orangeAccent,
          bottom: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }
}