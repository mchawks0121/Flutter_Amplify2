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
      const Tab(icon: Icon(Icons.cloud_queue), text: 'ビデオ通話'),
      const Tab(icon: Icon(Icons.chat_bubble_outline), text: '掲示板'),
      const Tab(icon: Icon(Icons.person_outline), text: 'マイページ'),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: TabBar(
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: _kTabPages,
        ),
      ),
    );
  }
}