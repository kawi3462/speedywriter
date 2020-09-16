import 'package:flutter/material.dart';
import 'package:speedywriter/common/drawer.dart';

/// A responsive scaffold for our application.
/// Displays the navigation drawer alongside the [Scaffold] if the screen/window size is large enough
class AppScaffold extends StatefulWidget {
  const AppScaffold({@required this.body, @required this.pageTitle, Key key})
      : super(key: key);

  final Widget body;

  final String pageTitle;

  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
 final GlobalKey<ScaffoldState> _appscaffoldState = new GlobalKey();

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
            key:_appscaffoldState,
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
          ),
        )
      ],
    );
  }
}
