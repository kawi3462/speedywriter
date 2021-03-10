import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speedywriter/common/page_titles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:speedywriter/presentation/custom_icons.dart';
import 'package:speedywriter/common/floatingbottombutton.dart';
import 'package:speedywriter/common/drawer.dart';
import 'package:speedywriter/common/bottomnav.dart';
import 'package:speedywriter/common/routenames.dart';

import 'package:speedywriter/common/contactsbottomsheet.dart';

import 'package:speedywriter/common/policiespagearguments.dart';

class Policy extends StatefulWidget {
//   Policy({
// Key key,
//   @required this.url,
//   @required this.title  }) : super(key: key);

//   final String url;
//   final String title;

  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {
  final GlobalKey<ScaffoldState> _scaffoldPolicyKey = GlobalKey();
  static const routeName = RouteNames.policy;

  bool _isIndex = false;
  //Start adding bottom nav==========
  String _lastSelected = 'TAB: 0';
  bool _isPhoneempty = false;
  bool _isLoading = false;

  String _phone;

  bool _isEnabled = true;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

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
              return ContactsBottomSheetState();
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
  void initState() {
    // TODO: implement initState
    //  _totalCost = widget.model.totalCost;
    _isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PolicyArguments args = ModalRoute.of(context).settings.arguments;

    final bool displayMobileLayout = MediaQuery.of(context).size.width < 600;

    String url = args.url;
    // String url ="http://www.onlinechatcenters.com/chat/?SESSID=107a02gapell2lhk7n18iefsr8&action=prechat";

    return Row(children: [
      if (!displayMobileLayout)
        const SimpleDrawer(
          permanentlyDisplay: true,
        ),
      Expanded(
          child: Scaffold(
              key: _scaffoldPolicyKey,
              appBar: AppBar(
                // when the app isn't displaying the mobile version of app, hide the menu button that is used to open the navigation drawer
                automaticallyImplyLeading: displayMobileLayout,
                title: Text(
                 args.title
                ),
              ),
              drawer: displayMobileLayout
                  ? const SimpleDrawer(
                      permanentlyDisplay: false,
                    )
                  : null,
              body: Builder(builder: (BuildContext context) {
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
              
                    WebView(
                      initialUrl: url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },

                      // ignore: prefer_collection_literals
                      javascriptChannels: <JavascriptChannel>[
                        _toasterJavascriptChannel(context),
                      ].toSet(),
                      navigationDelegate: (NavigationRequest request) {
                        if (request.url
                            .startsWith('https://www.mylivechat.com')) {
                          // print('blocking navigation to $request}');
                          return NavigationDecision.navigate;
                        } else if (request.url.endsWith("thankyou.php")) {
                          //update payment after success
                          // _editOrderPayment( _token,id.toString());
                          // print("Payment successfull");

                          return NavigationDecision.navigate;
                        } else if (request.url.endsWith("paypal_app.php")) {
                          Navigator.pushNamed(context, "/myorders");
                        }

                        print('allowing navigation to $request');
                        return NavigationDecision.navigate;
                      },
                      onPageStarted: (String url) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        // print('Page started loading: $url');
                        setState(() {
                          _isLoading = true;
                        });
                      },
                      onPageFinished: (String url) {
                        // print('Page finished loading: $url');
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      gestureNavigationEnabled: true,
                    ),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Container()
                  ],
                );
              }),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterDocked,
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
                  FABBottomAppBarItem(iconData: Icons.chat, text: 'Live Chat'),
                ],
              )))
    ]);
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
