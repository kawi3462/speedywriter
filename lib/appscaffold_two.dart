import 'package:flutter/material.dart';
import 'package:speedywriter/common/bottomnav.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/presentation/custom_icons.dart';
import 'package:speedywriter/common/floatingbottombutton.dart';
import 'package:speedywriter/common/routenames.dart';
import 'package:speedywriter/common/contactsbottomsheet.dart';
import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';

/// A responsive scaffold for our application.
/// Displays the navigation drawer alongside the [Scaffold] if the screen/window size is large enough
///
///
class AppScaffoldTwo extends StatefulWidget {
  const AppScaffoldTwo(
      {this.index, @required this.body, @required this.pageTitle, Key key})
      : super(key: key);

  final Widget body;
  final int index;

  final String pageTitle;

  _AppScaffoldTwoState createState() => _AppScaffoldTwoState();
}

class _AppScaffoldTwoState extends State<AppScaffoldTwo> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();

  String _lastSelected = 'TAB: 0';
  int index;
  bool _isIndex = false;

  @override
  void initState() {
    index = widget.index;
    if (index != null) {
      _isIndex = true;
    }
    // TODO: implement initState
    super.initState();
  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      if (index == 0) {
        Navigator.pushNamed(context, RouteNames.getquote);
      } else if (index == 3) {
        Navigator.pushNamed(context, RouteNames.chatAdmin);
      } else if (index == 2) {
        showModalBottomSheet(
            isDismissible: true,
            useRootNavigator: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            context: context,
            builder: (BuildContext context) {
              return  ContactsBottomSheetState();
            });
      }
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;
    return Row(
      children: [
        if (!displayMobileLayout)
          const SimpleDrawer(
            permanentlyDisplay: true,
          ),
        Expanded(
            child: Scaffold(
                key: _scaffoldState,
                appBar: AppBar(
                  // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
                  automaticallyImplyLeading: displayMobileLayout,
                  title: Text(widget.pageTitle),
                ),
                drawer: displayMobileLayout
                    ? const SimpleDrawer(
                        permanentlyDisplay: false,
                      )
                    : null,
                body: widget.body,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingButton(),
                bottomNavigationBar: FABBottomAppBar(
                  centerItemText: 'Order Now',
                  onTabSelected: _selectedTab,
                  selectedColor: _isIndex ? Color(0xFFFF7E7E) : null,
                  notchedShape: CircularNotchedRectangle(),
                  items: [
                    FABBottomAppBarItem(
                        iconData: MyFlutterApp.calculator, text: 'Get Quote'),
                    FABBottomAppBarItem(
                        iconData: MyFlutterApp.wallet, text: 'Wallet'),
                    FABBottomAppBarItem(iconData: Icons.call, text: 'Contact'),
                    FABBottomAppBarItem(
                        iconData: Icons.chat, text: 'Live Chat'),
                  ],
                ))),
      ],
    );
  }
}

