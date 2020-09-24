import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:speedywriter/account/usermodel.dart';


import 'package:speedywriter/common/page_titles.dart';
import 'package:speedywriter/network_utils/api.dart';
import 'package:speedywriter/ordering/finalorderdetails.dart';
import 'package:speedywriter/ordering/ordermodel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:speedywriter/common/appbar.dart';
import 'package:speedywriter/common/colors.dart';


class PayPal extends StatefulWidget {
  final OrderModel model;
  PayPal({Key key, @required this.model}) : super(key: key);

  static const routeName = '/paypal';
  _PayPalState createState() => _PayPalState();
}

class _PayPalState extends State<PayPal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  double _totalCost=1.12;
  bool _isLoading;
  String _token;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    // TODO: implement initState
  //  _totalCost = widget.model.totalCost;
    _isLoading = false;

    super.initState();
  }

//Show message dialog
  _showMsg(String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(label: 'Close', onPressed: () {}),
    );
_scaffoldKey.currentState.showSnackBar(snackbar);
  }

//end message dialog



//update order after successful payment 

 void _editOrderPayment( String token, String id) async {
  
  Map _data = {
        'status':'Waiting Approval',
        'payment':'Paid',
    
      };

      String _orderJson = jsonEncode(_data);


    try {
      var apiUrl = '/updateorderpayment/' + id;

      var response = await  Network().submitData(_orderJson, apiUrl, token);

      if (response.statusCode == 200) {
        
        ScopedModel.of<UserModel>(context, rebuildOnChange: true)
            .loadUserOrders();
      }
      else{
 _showMsg("Payment not updated");

      }
      }
         catch (e) {
    
      _showMsg("Payment not updated");
    }

 }
 //End order update after success in payment 



  @override
  Widget build(BuildContext context) {

    final FinalOrderDetails _finalOrderDetails =
        ModalRoute.of(context).settings.arguments;
 _token=  ScopedModel.of<UserModel>(context, rebuildOnChange: true).token;

    int id = _finalOrderDetails.id;

    String email = _finalOrderDetails.email;
    String subject = _finalOrderDetails.subject;
    String doc = _finalOrderDetails.document;
    String pages = _finalOrderDetails.pages;
    String urgency = _finalOrderDetails.urgency;

    String url =
        '''https://lastminutessay.us/web/pay/paypal_app.php?id=$id&total=$_totalCost&email=$email&subject=$subject&doc=$doc&pages=$pages&urgency=$urgency''';

    return Scaffold(
       backgroundColor: speedySurfacebackground,
      key: _scaffoldKey,
   
            appBar: buildAppBar(PageTitles.payPalPayment),
       

    
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
                } 
                else if (request.url.endsWith("thankyou.php")) {
                  //update payment after success 
                _editOrderPayment( _token,id.toString());
                  print("Payment successfull");

                  return NavigationDecision.navigate;
                } 

                else if (request.url.endsWith("paypal_app.php")) {
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
