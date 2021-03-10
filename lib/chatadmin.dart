import 'dart:async';

import 'package:flutter/material.dart';



import 'package:speedywriter/common/page_titles.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:speedywriter/common/appbar.dart';
import 'package:speedywriter/common/colors.dart';
import 'package:flutter/services.dart';



class ChatAdmin extends StatefulWidget {




  _ChatAdminState createState() => _ChatAdminState();
}

class   _ChatAdminState extends State<ChatAdmin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isLoading;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();




  @override
  void initState() {
    // TODO: implement initState
  //  _totalCost = widget.model.totalCost;
    _isLoading = false;

    super.initState();
  }





  @override
  Widget build(BuildContext context) {

 

  String url ="https://lastminutessay.us/web/pay/chat.php";
    // String url ="http://www.onlinechatcenters.com/chat/?SESSID=107a02gapell2lhk7n18iefsr8&action=prechat";


    return Scaffold(
       backgroundColor: speedySurfacebackground,
      key: _scaffoldKey,
   
            appBar: buildAppBar(PageTitles.chatwithadmin),
       

    
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
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
                if (request.url.startsWith('https://www.mylivechat.com')) {
                  // print('blocking navigation to $request}');
                   return NavigationDecision.navigate;
                } 
                else if (request.url.endsWith("thankyou.php")) {
                  //update payment after success 
                // _editOrderPayment( _token,id.toString());
                  // print("Payment successfull");

                  return NavigationDecision.navigate;
                } 

                else if (request.url.endsWith("paypal_app.php")) {
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
    );
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
