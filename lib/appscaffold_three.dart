import 'package:flutter/material.dart';
import 'package:speedywriter/common/bottomnav.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/presentation/custom_icons.dart';

/// A responsive scaffold for our application.
/// Displays the navigation drawer alongside the [Scaffold] if the screen/window size is large enough
///
///
class AppScaffoldTwo extends StatefulWidget {
  const AppScaffoldTwo({@required this.body, @required this.pageTitle, Key key})
      : super(key: key);

  final Widget body;

  final String pageTitle;

  _AppScaffoldTwoState createState() => _AppScaffoldTwoState();
}

class _AppScaffoldTwoState extends State<AppScaffoldTwo> {
String _lastSelected = 'TAB: 0';

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      if(index==0){
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
          child: Scaffold(
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
              
      bottomNavigationBar: FABBottomAppBar(

      onTabSelected: _selectedTab,
        selectedColor:  null ,//Color(0xFFFF7E7E),

    
  
        notchedShape: CircularNotchedRectangle(),

        items: [
    FABBottomAppBarItem(iconData: MyFlutterApp.calculator, text: 'Get Quote'),
    FABBottomAppBarItem(iconData: MyFlutterApp.wallet, text: 'Wallet'),
    
    FABBottomAppBarItem(iconData: Icons.call, text: 'Contact'),
    FABBottomAppBarItem(iconData: Icons.chat, text: 'Live Chat'),
  ],
      )
              )),
        
      ],
    );
  }
}
