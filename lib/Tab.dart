import 'package:fluamp/Chat.dart';
import 'package:fluamp/video/Zoomindex.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'CalendarScreen.dart';
import 'Configuration.dart';
import 'Board.dart';
import 'RandomChat.dart';
import 'RandomChatSetting.dart';
import 'RandomChatSettings.dart';

class TabPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      Board(),
      MyChat(),
      RandomChat(),
      RandomChatSetting(),
      Zoomindex(),
      Configuration(),
    ];

    final _kTabs = <Tab>[
      const Tab(icon: Icon(MdiIcons.bulletinBoard), height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(Icons.chat), height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(MdiIcons.chatOutline), height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(MdiIcons.chatAlert), height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(Icons.videocam), height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
      const Tab(icon: Icon(Icons.person_outline), height: 55, iconMargin: EdgeInsets.only(bottom: 1.0)),
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