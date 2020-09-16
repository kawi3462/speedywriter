import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speedywriter/appscaffold.dart';

import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';
import 'package:speedywriter/ordering/ordermodel.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PayPal extends StatefulWidget {
  final OrderModel model;
  PayPal({Key key, @required this.model}) : super(key: key);

  static const routeName = '/paypal';
  _PayPalState createState() => _PayPalState();
}

class _PayPalState extends State<PayPal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  double _totalCost;
  bool _isLoading;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    // TODO: implement initState
    _totalCost = widget.model.totalCost;
    _isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final FinalOrderDetails _finalOrderDetails =
        ModalRoute.of(context).settings.arguments;
    int id = _finalOrderDetails.id;

    String email = _finalOrderDetails.email;
    String subject = _finalOrderDetails.subject;
    String doc = _finalOrderDetails.document;
    String pages = _finalOrderDetails.pages;
    String urgency = _finalOrderDetails.urgency;

    String url =
        '''https://speedywriters.us/manageorders/paypal_app.php?id=$id&total=$_totalCost&email=$email&subject=$subject&doc=$doc&pages=$pages&urgency=$urgency''';

    return AppScaffold(
   pageTitle: PageTitles.payPalPayment,
    
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              // TODO(iskakaushik): Remove this when collection literals makes it to stable.
              // ignore: prefer_collection_literals
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $request}');
                  return NavigationDecision.prevent;
                } else if (request.url.endsWith("thankyou.php")) {
                  print("Payment successfull");
                  return NavigationDecision.prevent;
                } else if (request.url.endsWith("paypal_app.php")) {
                  Navigator.pushNamed(context, "/myorders");
                }

                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
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
