import 'package:flutter/material.dart';
import 'package:speedywriter/common/bottomnav.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/common/floatingbottombutton.dart';
import 'package:speedywriter/presentation/custom_icons.dart';

/// A responsive scaffold for our application.
/// Displays the navigation drawer alongside the [Scaffold] if the screen/window size is large enough
///
///
///
//
class AppScaffoldHomeTabs extends StatefulWidget {
  const AppScaffoldHomeTabs(
      {
      @required this.tabBar,
      @required this.pageTitle,
      @required this.tabBarView,
      Key key})
      : super(key: key);


  final TabBar tabBar;
  final TabBarView tabBarView;

  final String pageTitle;

  _AppScaffoldHomeTabsState createState() => _AppScaffoldHomeTabsState();
}

class _AppScaffoldHomeTabsState extends State<AppScaffoldHomeTabs> {
 //Start adding bottom nav==========
  String _lastSelected = 'TAB: 0';

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      if (index == 0) {
        Navigator.pushNamed(context, '/getquote');
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
            child: DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: Color(0xFFFAF0E6),
            appBar: AppBar(
              bottom: widget.tabBar,
              // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
              automaticallyImplyLeading: displayMobileLayout,
              title: Text(widget.pageTitle),
            ),
            drawer: displayMobileLayout
                ? const SimpleDrawer(
                    permanentlyDisplay: false,
                  )
                : null,
            body: widget.tabBarView,
              floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingButton(),
                bottomNavigationBar: FABBottomAppBar(
                  centerItemText: 'Order Now',
                  onTabSelected: _selectedTab,
                  selectedColor: null, //Color(0xFFFF7E7E),

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
                )



          ),
        ))
      ],
    );
  }
}
