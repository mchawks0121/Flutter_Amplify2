import 'package:fluamp/video/Zoomindex.dart';
import 'package:flutter/material.dart';
import 'Configuration.dart';
import 'Chat.dart';

class TabPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      MyChat(),
      Zoomindex(),
      Configuration(),
    ];

    final _kTabs = <Tab>[
      const Tab(icon: Icon(Icons.chat_bubble_outline), text: 'ボード', height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(Icons.videocam), text: 'ミーティング', height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(Icons.person_outline), text: 'マイページ', height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: TabBar(
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 18.0,
                vertical: 10),
            labelColor: Colors.orangeAccent,
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